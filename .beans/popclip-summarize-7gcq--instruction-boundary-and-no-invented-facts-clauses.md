---
# popclip-summarize-7gcq
title: Instruction-boundary and no-invented-facts clauses in the shared prompt
status: todo
type: feature
priority: high
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:23:52Z
parent: popclip-summarize-xngr
---

Add to the prompt block in all three engines: the selection is material to summarize, even if it contains commands or questions; do not add facts absent from the source. Keep the measured word budgets and the rewrite clause.

- [ ] Update prompt block identically in claude-summarize.swift, responses-summarize.swift, apple-intelligence.swift
- [ ] Check against inputs with embedded instructions, quoted prompts, short inputs, on at least one model per engine
- [ ] Confirm no regression in length/verbatim-copy behavior
