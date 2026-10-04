---
# popclip-summarize-wbzy
title: Prompt ideas adapted from steipete/summarize
status: completed
type: feature
created_at: 2026-10-04T18:42:16Z
updated_at: 2026-10-04T18:42:16Z
---

Five prompt/wrapper ideas from steipete/summarize (commit ddbae2b, packages/core/src/prompts), measured old vs new: 8 cases x concise/tldr x 2 reps on Claude Haiku 4.5, GPT-5.6 Luna, Grok 4.3, and Apple Intelligence.

- [x] Output language: detected with NLLanguageRecognizer (>= 0.8 confidence) and named in the prompt; generic fallback otherwise. English replies to German/Chinese: 16/16 -> 0/16 (generic wording alone: 4/16). Extra "Reply in French." still wins.
- [x] Skip selections no longer than the summary (40 words, 25 for TL;DR), ICU word count so CJK works; "never pad" clause.
- [x] Thread/comment-chain clause: outcome and positions, not a recap.
- [x] Boilerplate (navigation, ads, cookie notices) added to the drop line; no engine repeated it before or after.
- [x] Escape <source / </source inside the selection (not every < or &: would leak entities like R&amp;D).
- [x] Final length check line (for 2mcp): Haiku over-cap 20/24 -> 15/24, Apple 5 -> 3, OpenAI/Grok within noise.
- [x] check-consistency.rb covers the new shared setup code.

Not taken: italic excerpts, slide/timestamp markers, sharer reactions, instructions-in-user-turn layout.
