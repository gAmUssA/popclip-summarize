---
# popclip-summarize-06q4
title: Verify Claude Sonnet 5 / Opus 5 presets with max_tokens 1024
status: completed
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:13:50Z
parent: popclip-summarize-dazt
---

Sonnet 5 has adaptive thinking on by default; thinking may consume the 1024-token budget and truncate/empty summaries on non-Haiku presets.

- [x] Live-test both presets
- [x] If needed, disable/limit thinking for known models or raise budget — not needed

## Summary of Changes

No code change needed. Live results (2026-09-14): Sonnet 5 and Opus 5 both return complete summaries within budget via the real action (concise 35/39 words, bullets 89/79 words, 2–3 s). Raw API: Opus 5 emits a thinking block (empty display), Sonnet 5 none. On a 3,900-word selection with bullets, Opus 5 used 262 output tokens including thinking and Sonnet 5 207 — far below max_tokens 1024. The engine already reports a budget-exhausted-before-text case distinctly if it ever happens.
