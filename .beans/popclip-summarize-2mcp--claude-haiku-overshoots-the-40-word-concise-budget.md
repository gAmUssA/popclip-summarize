---
# popclip-summarize-2mcp
title: Claude Haiku overshoots the 40-word concise budget on dense text
status: completed
type: bug
priority: low
created_at: 2026-09-14T21:38:16Z
updated_at: 2026-10-04T19:26:37Z
parent: popclip-summarize-s09a
---

On a ~120-word news paragraph, claude-haiku-4-5 returns 50–53 words for the concise style (pre-existing; same before and after the prompt-fidelity change). OpenAI/Grok/Apple stay within budget.

Ideas: max_tokens tuned per style, or restate the cap at the end of the user turn.



2026-10-04: a closing \"Final check: count the words and cut the summary to N or fewer.\" line (shipped with the summarize-adapted prompt changes) reduced over-cap runs from 20/24 to 15/24 for concise+tldr; still overshoots more often than not. Next: tune max_tokens per style, or restate the cap in the user turn.



## Summary of Changes

Fixed by d7tm: restating the cap after the source took Haiku from 21/30 to 5/30 over the limit (news paragraph: 56 words to 40).
