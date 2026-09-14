---
# popclip-summarize-d4rq
title: Apple Intelligence still answers selected questions
status: todo
type: bug
priority: low
created_at: 2026-09-14T21:38:16Z
updated_at: 2026-09-14T21:38:16Z
parent: popclip-summarize-xngr
---

After the prompt-fidelity change, the on-device model still answers a selected question (4/4) instead of summarizing what it asks — sometimes with wrong facts. Cloud engines are fixed.

Tried: rule in instructions only; rule restated in user turn (fixed commands, not questions); `@Generable` classify-then-summarize (regressed injection resistance 3/3 — rejected).

Ideas: few-shot example pair in instructions; Apple-specific style wording ("Describe the text:"); check newer on-device model versions.
