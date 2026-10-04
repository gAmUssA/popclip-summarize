---
# popclip-summarize-l1hg
title: Summarize a selected link
status: completed
type: feature
priority: normal
created_at: 2026-10-04T19:14:43Z
updated_at: 2026-10-04T19:26:37Z
---

From steipete/summarize (its core job: link in, summary out). When the whole selection is one http(s) link, fetch the page, extract readable text (article/main, drop nav/header/footer/aside/script), and summarize that instead of the URL. PDFs via PDFKit, plain text as is. Every engine, behind a setting. Privacy: fetching is a request to the linked site only; for Apple Intelligence still nothing goes to an AI provider.

- [x] fetch-page.swift helper (http/https only, 20 s timeout, 10 MB cap, ephemeral session)
- [x] Wrapper hook in lib.sh; window title names the host
- [x] Setting, README, CHANGELOG
- [x] Live test: blog, Wikipedia, GitHub README, news homepages, arXiv PDF, raw text, example.com (too short), 404, X (login wall)

## Summary of Changes

Found while testing: NSXMLDocument's HTML tidy deletes HTML5 tags (nav, main, article, footer…) and keeps their contents, so they are renamed to div data-h5=… before tidying. Class/id furniture markers match whole words only (GitHub's README lives in SharedMarkdownContent). Known gaps: JS-rendered pages and login walls (X shows its logged-out shell); Apple Intelligence refuses most pages at its 6,000-character limit.
