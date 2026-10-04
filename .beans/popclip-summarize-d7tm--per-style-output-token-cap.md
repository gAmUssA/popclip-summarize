---
# popclip-summarize-d7tm
title: Per-style output-token cap
status: completed
type: task
priority: normal
created_at: 2026-10-04T19:14:43Z
updated_at: 2026-10-04T19:26:37Z
---

steipete/summarize sizes max_tokens per length preset; ours is a flat 1024. Caveat: the model never sees max_tokens, so a tighter cap truncates mid-sentence rather than shortening — it is a cost/runaway guard, not a fix for 2mcp. Size caps generously per style, and try restating the word cap next to the source in the user turn (the other 2mcp idea) as the actual length lever; measure both.



## Summary of Changes

Claude max_tokens per style: tldr 256, concise 384, bullets 768 (Responses engine keeps 2048 because reasoning tokens count against it). The word cap is restated after the source in the user turn (lengthReminder): over-cap runs, 30 per engine — Claude 21 to 5, Apple 1 to 0, OpenAI 4 to 1, Grok 3 to 0; no change in language, copying, or injection handling.
