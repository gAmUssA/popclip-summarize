---
# popclip-summarize-06q4
title: Verify Claude Sonnet 5 / Opus 5 presets with max_tokens 1024
status: todo
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-dazt
---

Sonnet 5 has adaptive thinking on by default; thinking may consume the 1024-token budget and truncate/empty summaries on non-Haiku presets.

- [ ] Live-test both presets
- [ ] If needed, disable/limit thinking for known models or raise budget
