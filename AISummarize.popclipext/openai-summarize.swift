//
//  openai-summarize.swift — Summarize the selected text with OpenAI's
//  Responses API.
//
//  A shell-script action like the Claude engine, for the same reason: only a
//  shell-script action can launch the native summary window. The API key
//  arrives from the Keychain-backed `secret` option as $POPCLIP_OPTION_OPENAIKEY.
//
//  Contract: the summary goes to stdout; errors go to stderr. Exit 0 on
//  success, 2 to send the user to the extension settings, 1 otherwise.
//

import Foundation

let apiURL = URL(string: "https://api.openai.com/v1/responses")!
let defaultModel = "gpt-5.6-luna"
let requestTimeout: TimeInterval = 60

// Reasoning tokens count against max_output_tokens. With effort "none" there
// are none, but a model whose floor is "low" spends some before it writes a
// word — so this budget is larger than the Claude engine's.
let maxTokens = 2048

// Stay well inside the context window so a runaway selection fails fast and
// locally instead of burning a round trip. Matches the Claude engine.
let maxInputCharacters = 400_000

// MARK: - Process plumbing

/// Write a message to stderr and exit. `settings: true` (exit code 2) makes
/// PopClip open this extension's settings pane.
func fail(_ message: String, settings: Bool = false) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(settings ? 2 : 1)
}

let environment = ProcessInfo.processInfo.environment

func option(_ name: String) -> String {
    (environment["POPCLIP_OPTION_\(name)"] ?? "")
        .trimmingCharacters(in: .whitespacesAndNewlines)
}

let selectedText = (environment["POPCLIP_TEXT"] ?? "")
    .trimmingCharacters(in: .whitespacesAndNewlines)
let apiKey = option("OPENAIKEY")

guard !apiKey.isEmpty else {
    fail(
        "Add your OpenAI API key in the AI Summarize settings.",
        settings: true
    )
}
guard !selectedText.isEmpty else {
    fail("There is no text to summarize.")
}
guard selectedText.count <= maxInputCharacters else {
    fail(
        "Selection is too long to summarize (\(selectedText.count) characters, limit \(maxInputCharacters))."
    )
}

let model = option("OPENAICUSTOMMODEL").isEmpty
    ? (option("OPENAIMODEL").isEmpty ? defaultModel : option("OPENAIMODEL"))
    : option("OPENAICUSTOMMODEL")

/// The lowest reasoning effort the model accepts, or nil to leave the
/// parameter out. Summarizing gains nothing from deliberation, and the default
/// (medium) adds seconds and cost. GPT-5.6 accepts "none"; GPT-6 bottoms out
/// at "low". Anything else — a custom ID for an older or non-reasoning model —
/// gets no reasoning field, because non-reasoning models reject it outright.
func reasoningEffort(for model: String) -> String? {
    if model.hasPrefix("gpt-6") { return "low" }
    if model.hasPrefix("gpt-5.6") { return "none" }
    return nil
}

// MARK: - Prompt

let styleInstruction: String
switch option("STYLE") {
case "bullets":
    styleInstruction =
        "Summarize as 3-6 bullet points, one line each, using '- ' as the bullet marker."
case "tldr":
    styleInstruction = "Write a single-sentence TL;DR of no more than 25 words."
default:
    styleInstruction = "Write a summary of no more than 40 words."
}

// See the note in claude-summarize.swift on why these are word budgets. Keep
// this block identical to the ones in claude-summarize.swift and
// apple-intelligence.swift.
var instructionLines = [
    "You are a summarization engine.",
    styleInstruction,
    "Do not reuse whole sentences from the source; rewrite in your own words.",
    "Keep only load-bearing facts: who, what, when, and any figures.",
    "Drop background, asides, and repetition.",
    "Reply with the summary only: no preamble, no heading, no commentary, and no surrounding quotation marks.",
]
let extraInstructions = option("EXTRA")
if !extraInstructions.isEmpty {
    instructionLines.append(extraInstructions)
}

// MARK: - Request

var request = URLRequest(url: apiURL, timeoutInterval: requestTimeout)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "content-type")
request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "authorization")

var payload: [String: Any] = [
    "model": model,
    "instructions": instructionLines.joined(separator: " "),
    "input": selectedText,
    "max_output_tokens": maxTokens,
    // A one-shot summary has no follow-up turn to thread, so don't ask OpenAI
    // to retain the selection server-side.
    "store": false,
]
if let effort = reasoningEffort(for: model) {
    payload["reasoning"] = ["effort": effort]
}

do {
    request.httpBody = try JSONSerialization.data(withJSONObject: payload)
} catch {
    fail("Could not encode the request: \(error.localizedDescription)")
}

let data: Data
let response: URLResponse
do {
    (data, response) = try await URLSession.shared.data(for: request)
} catch {
    fail(
        "Could not reach the OpenAI API. Check your internet connection. (\(error.localizedDescription))"
    )
}

let body = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
let status = (response as? HTTPURLResponse)?.statusCode ?? 0

// MARK: - Response

let apiError = body["error"] as? [String: Any] ?? [:]
let apiMessage = apiError["message"] as? String ?? ""
let apiCode = apiError["code"] as? String ?? ""

guard status == 200 else {
    switch (status, apiCode) {
    case (401, _), (403, _):
        fail(
            "OpenAI rejected the API key (HTTP \(status)). \(apiMessage)",
            settings: true
        )
    case (_, "model_not_found"), (404, _):
        fail(
            "Unknown model '\(model)'. Check the ChatGPT Model / Custom Model setting. \(apiMessage)",
            settings: true
        )
    // OpenAI reports an exhausted balance as a 429 too, but waiting won't fix it.
    case (429, "insufficient_quota"):
        fail("Your OpenAI account is out of credit. \(apiMessage)")
    case (429, _):
        fail("Rate limited by OpenAI. Wait a moment and try again.")
    case (500...599, _):
        fail("OpenAI is having trouble (HTTP \(status)). Try again shortly.")
    default:
        fail("OpenAI API error (HTTP \(status)). \(apiMessage)")
    }
}

// `output` interleaves reasoning items with the assistant message; only the
// message's `output_text` parts are the answer. (`output_text` at the top level
// is an SDK convenience, absent from the raw response.)
let contents = (body["output"] as? [[String: Any]] ?? [])
    .filter { $0["type"] as? String == "message" }
    .flatMap { $0["content"] as? [[String: Any]] ?? [] }

var summary = contents
    .filter { $0["type"] as? String == "output_text" }
    .compactMap { $0["text"] as? String }
    .joined()
    .trimmingCharacters(in: .whitespacesAndNewlines)

let refusal = contents
    .filter { $0["type"] as? String == "refusal" }
    .compactMap { $0["refusal"] as? String }
    .joined(separator: " ")

let incompleteReason = (body["incomplete_details"] as? [String: Any])?["reason"] as? String

guard !summary.isEmpty else {
    if !refusal.isEmpty {
        fail("ChatGPT declined to summarize this text: \(refusal)")
    }
    if incompleteReason == "max_output_tokens" {
        fail("The model used its whole \(maxTokens)-token budget before writing a summary. Try a faster model.")
    }
    fail("ChatGPT returned an empty summary.")
}

if incompleteReason == "max_output_tokens" {
    // The summary is usable but was cut short; say so rather than pretend.
    summary += "\n\n[truncated at \(maxTokens) tokens]"
}

print(summary, terminator: "")
