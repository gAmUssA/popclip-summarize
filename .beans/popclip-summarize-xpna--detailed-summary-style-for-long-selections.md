---
# popclip-summarize-xpna
title: Detailed summary style for long selections
status: draft
type: feature
created_at: 2026-10-04T18:42:16Z
updated_at: 2026-10-04T18:42:16Z
parent: popclip-summarize-s09a
---

Model on steipete/summarize's length presets (packages/core/src/prompts/summary-lengths.ts): character target + min/max + matching max_tokens, headings only above ~6k characters, never longer than the source. Trigger for streaming (xduw).
