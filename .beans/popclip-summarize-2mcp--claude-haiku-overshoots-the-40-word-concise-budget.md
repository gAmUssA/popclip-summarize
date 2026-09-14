---
# popclip-summarize-2mcp
title: Claude Haiku overshoots the 40-word concise budget on dense text
status: todo
type: bug
priority: low
created_at: 2026-09-14T21:38:16Z
updated_at: 2026-09-14T21:38:16Z
parent: popclip-summarize-xngr
---

On a ~120-word news paragraph, claude-haiku-4-5 returns 50–53 words for the concise style (pre-existing; same before and after the prompt-fidelity change). OpenAI/Grok/Apple stay within budget.

Ideas: max_tokens tuned per style, or restate the cap at the end of the user turn.
