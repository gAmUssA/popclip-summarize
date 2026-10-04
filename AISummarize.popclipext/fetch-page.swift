//
//  fetch-page.swift — Download a web page and print its readable text.
//
//  Used when the whole selection is one link: the wrapper summarizes the page
//  instead of the URL. The idea comes from steipete/summarize, which does this
//  with Readability; this is a small heuristic version of the same thing —
//  keep the article or main content, drop navigation, banners, and other page
//  furniture, and print one block of text per paragraph.
//
//  Contract: the URL is the only argument. The page title, a blank line, and
//  the text go to stdout; errors go to stderr. Exit 0 on success, 1 otherwise.
//

import Foundation
import PDFKit
import os

// Diagnostics go to the unified log under the extension's subsystem. Metadata
// only — status, type, sizes, timing. Never the URL or the page, which say what
// the user is reading.
let log = Logger(subsystem: "io.gamov.popclip.extension.ai-summarize", category: "fetch")
let started = ContinuousClock.now

/// Milliseconds since this helper started.
func elapsedMS() -> Int {
    let (seconds, attoseconds) = started.duration(to: .now).components
    return Int(seconds) * 1000 + Int(attoseconds / 1_000_000_000_000_000)
}

func fail(_ message: String) -> Never {
    log.error("failed after \(elapsedMS(), privacy: .public) ms: \(message, privacy: .private)")
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

/// Pages larger than this are refused rather than read into memory.
let maxBytes = 10_000_000
let requestTimeout: TimeInterval = 20

guard CommandLine.arguments.count == 2,
      let url = URL(string: CommandLine.arguments[1]),
      ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
      url.host != nil
else {
    fail("That doesn't look like a web link.")
}

// MARK: - Download

// Ephemeral: no cookies, cache, or credentials from earlier runs, and nothing
// stored afterwards. A logged-in page therefore reads as logged out.
let session = URLSession(configuration: .ephemeral)
var request = URLRequest(url: url, timeoutInterval: requestTimeout)
// Many sites turn away clients that don't look like a browser.
request.setValue(
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
    forHTTPHeaderField: "user-agent"
)
request.setValue("text/html,application/xhtml+xml,text/plain,application/pdf;q=0.9,*/*;q=0.5", forHTTPHeaderField: "accept")

let data: Data
let response: HTTPURLResponse
do {
    let (body, reply) = try await session.data(for: request)
    guard let http = reply as? HTTPURLResponse else { fail("The link didn't return a web page.") }
    data = body
    response = http
} catch let error as URLError where error.code == .timedOut {
    fail("The page took too long to load.")
} catch let error as URLError where [.cannotFindHost, .dnsLookupFailed].contains(error.code) {
    fail("Couldn't find that website. Check the link.")
} catch let error as URLError where error.code == .notConnectedToInternet {
    fail("You're offline, so the link can't be opened.")
} catch {
    fail("Couldn't open the link: \(error.localizedDescription)")
}

let contentType = (response.mimeType ?? "").lowercased()
log.notice("status=\(response.statusCode, privacy: .public) type=\(contentType, privacy: .public) bytes=\(data.count, privacy: .public) in \(elapsedMS(), privacy: .public) ms")

switch response.statusCode {
case 200..<300: break
case 401, 403: fail("The site refused to show this page (HTTP \(response.statusCode)). Open it in your browser and select the text instead.")
case 404, 410: fail("The page wasn't found (HTTP \(response.statusCode)).")
case 429: fail("The site is rate limiting requests. Try again later, or select the text in your browser instead.")
default: fail("The site returned an error (HTTP \(response.statusCode)).")
}
guard data.count <= maxBytes else {
    fail("The page is too large to summarize (\(data.count / 1_000_000) MB).")
}

/// Decode text with the charset the server named, falling back to UTF-8 and
/// then Latin-1, which accepts any bytes.
func decodedText() -> String {
    if let name = response.textEncodingName {
        let cfEncoding = CFStringConvertIANACharSetNameToEncoding(name as CFString)
        if cfEncoding != kCFStringEncodingInvalidId {
            let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(cfEncoding))
            if let text = String(data: data, encoding: encoding) { return text }
        }
    }
    return String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
}

/// Collapse runs of whitespace, including non-breaking spaces, to one space.
func normalized(_ text: String) -> String {
    text.components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
        .joined(separator: " ")
}

// MARK: - HTML

/// Tags that never hold the article: scripts, page furniture, and controls.
let droppedTags = [
    "script", "style", "noscript", "template", "svg", "canvas", "iframe", "object",
    "nav", "header", "footer", "aside", "form", "button", "select", "dialog",
]
/// Landmark roles for the same furniture.
let droppedRoles = ["navigation", "banner", "contentinfo", "complementary", "search", "dialog", "alert"]
/// Class or id words that mark cookie notices, sign-up boxes, sharing bars,
/// related links, comments, and ads.
let droppedMarkers = [
    "cookie", "consent", "gdpr", "newsletter", "subscribe", "signup", "paywall",
    "share", "social", "related", "recommend", "comment", "advert", "promo",
    "sidebar", "breadcrumb", "popup", "modal", "banner",
]
/// Elements whose text is one readable block.
let blockTags = ["p", "h1", "h2", "h3", "h4", "h5", "h6", "li", "blockquote", "pre", "dt", "dd", "td", "th", "figcaption"]

/// HTML5 elements the HTML tidier doesn't know. It deletes the tags and keeps
/// their contents, which would erase every landmark that marks navigation or
/// the article, so they are renamed to divs that remember the original tag.
let html5Tags = "nav|main|article|header|footer|aside|section|figure|figcaption|dialog|search|template"

func lowercasedAttribute(_ element: XMLElement, _ name: String) -> String {
    element.attribute(forName: name)?.stringValue?.lowercased() ?? ""
}

/// The element's tag as written in the page, before the HTML5 renaming.
func tagName(_ element: XMLElement) -> String {
    let original = lowercasedAttribute(element, "data-h5")
    return original.isEmpty ? (element.name?.lowercased() ?? "") : original
}

/// Whether an element is page furniture rather than content.
func isFurniture(_ element: XMLElement) -> Bool {
    let tag = tagName(element)
    if droppedTags.contains(tag) { return true }
    if droppedRoles.contains(lowercasedAttribute(element, "role")) { return true }
    if lowercasedAttribute(element, "aria-hidden") == "true" || element.attribute(forName: "hidden") != nil {
        return true
    }
    // Class and id markers only below the content root: a body or article
    // classed "has-sidebar" is still the page.
    if ["html", "body", "main", "article"].contains(tag) { return false }
    // Whole words only: "cookie-banner" and "comments" are furniture, but
    // GitHub's README sits in "SharedMarkdownContent".
    let words = (lowercasedAttribute(element, "class") + " " + lowercasedAttribute(element, "id"))
        .split { !$0.isLetter }
    return words.contains { word in droppedMarkers.contains { word == $0 || word == $0 + "s" } }
}

/// Remove furniture under `node`, depth first.
func prune(_ node: XMLNode) {
    for child in node.children ?? [] {
        if let element = child as? XMLElement, isFurniture(element) {
            element.detach()
        } else if child.kind == .comment {
            child.detach()
        } else {
            prune(child)
        }
    }
}

/// The text of each innermost block element under `root`, in document order.
func blocks(in root: XMLNode) -> [String] {
    var result: [String] = []
    func walk(_ node: XMLNode) {
        guard let element = node as? XMLElement else { return }
        let tag = tagName(element)
        let children = element.children ?? []
        let hasBlockChild = children.contains { child in
            guard let el = child as? XMLElement else { return false }
            return containsBlock(el)
        }
        if blockTags.contains(tag) && !hasBlockChild {
            let text = normalized(element.stringValue ?? "")
            if text.count > 1 { result.append(text) }
            return
        }
        children.forEach(walk)
    }
    func containsBlock(_ element: XMLElement) -> Bool {
        if blockTags.contains(tagName(element)) { return true }
        return (element.children ?? []).contains { ($0 as? XMLElement).map(containsBlock) ?? false }
    }
    walk(root)
    return result
}

func extractHTML(_ page: String) -> (title: String, text: String) {
    let html = page
        .replacingOccurrences(of: "(?i)<(\(html5Tags))\\b", with: "<div data-h5=\"$1\"", options: .regularExpression)
        .replacingOccurrences(of: "(?i)</(\(html5Tags))\\s*>", with: "</div>", options: .regularExpression)
    guard let document = try? XMLDocument(xmlString: html, options: [.documentTidyHTML, .nodeLoadExternalEntitiesNever]),
          let root = document.rootElement()
    else {
        // Unparseable markup: strip tags and keep whatever text is left.
        let stripped = html.replacingOccurrences(
            of: "(?is)<(script|style)[^>]*>.*?</\\1>|<[^>]+>", with: " ", options: .regularExpression
        )
        return ("", normalized(stripped))
    }

    let title = normalized(
        (try? root.nodes(forXPath: "//meta[@property='og:title']/@content").first?.stringValue)
            ?? (try? root.nodes(forXPath: "//title").first?.stringValue) ?? ""
    )

    prune(root)

    // Prefer the candidate with the most block text: an article or main
    // element when the page has one, the body otherwise.
    let candidates = ((try? root.nodes(forXPath: "//*[@data-h5='article'] | //*[@data-h5='main'] | //*[@role='main']")) ?? [])
        + ((try? root.nodes(forXPath: "//body")) ?? [root])
    let scored = candidates.map { node -> (blocks: [String], length: Int) in
        let found = blocks(in: node)
        return (found, found.reduce(0) { $0 + $1.count })
    }
    var best = scored.max { $0.length < $1.length }?.blocks ?? []

    // Pages built from bare divs have no blocks: fall back to all body text.
    if best.reduce(0, { $0 + $1.count }) < 200 {
        let body = (try? root.nodes(forXPath: "//body").first) ?? root
        let text = normalized(body.stringValue ?? "")
        if text.count > best.reduce(0, { $0 + $1.count }) { best = [text] }
    }

    // Drop exact repeats, such as a headline echoed in a print header.
    var seen = Set<String>()
    best = best.filter { seen.insert($0).inserted }
    if let first = best.first, first == title { best.removeFirst() }
    return (title, best.joined(separator: "\n\n"))
}

// MARK: - Dispatch on type

let title: String
let text: String
switch contentType {
case "text/html", "application/xhtml+xml", "":
    (title, text) = extractHTML(decodedText())
case "application/pdf":
    guard let pdf = PDFDocument(data: data) else { fail("Couldn't read the PDF.") }
    title = normalized(pdf.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String ?? "")
    text = (pdf.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
case _ where contentType.hasPrefix("text/"):
    title = ""
    text = decodedText().trimmingCharacters(in: .whitespacesAndNewlines)
default:
    fail("This link is a file of type \(contentType), not a page or PDF, so there's nothing to summarize.")
}

// A page that renders with JavaScript, or one behind a login, arrives as a
// shell with little or no text.
guard text.count >= 200 else {
    if text.isEmpty {
        fail("Couldn't find readable text on that page. It may need JavaScript or a login — open it in your browser, select the text, and summarize that instead.")
    }
    fail("That page has only a few lines of text, so there is nothing to summarize.")
}

log.notice("done chars=\(text.count, privacy: .public) in \(elapsedMS(), privacy: .public) ms")
print(title.isEmpty ? text : "\(title)\n\n\(text)", terminator: "")
