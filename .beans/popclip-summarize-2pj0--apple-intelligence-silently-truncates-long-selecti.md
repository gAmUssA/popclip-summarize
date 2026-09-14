---
# popclip-summarize-2pj0
title: Apple Intelligence silently truncates long selections
status: completed
type: bug
priority: high
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:25:08Z
parent: popclip-summarize-tnvg
---

`apple-intelligence.swift` keeps the first 6,000 characters, writes a note to stderr nobody sees, and presents the summary as complete. Later facts vanish without notice.

Fix: reject over-limit input with a clear message pointing to a cloud engine; never auto-send to the cloud.

- [x] Replace truncation with a failure message
- [x] Verify boundary (6,000 ok, 6,001 rejected) without calling the model
- [x] Fix README wording

## Summary of Changes

`apple-intelligence.swift` now fails with "Selection is too long for the on-device model (N characters, limit 6000). Select less text, or use a cloud engine." instead of summarizing a prefix. Verified: 6,001 chars rejected in ~2s (no generation); 6,000 chars summarized. README troubleshooting + CHANGELOG updated.
