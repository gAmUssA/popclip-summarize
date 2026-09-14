---
# popclip-summarize-h3m0
title: 'Consistency checks: Config defaults vs wrappers vs engines'
status: completed
type: task
priority: normal
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:53:34Z
parent: popclip-summarize-1sh3
---

Model defaults live in Config.yaml, each wrapper, and the engine provider table. Fail `make check` when they drift.

- [x] Ruby/shell check comparing defaults and option ids
- [x] Wire into CI

## Summary of Changes

`scripts/check-consistency.rb`, run by `make check` (and so by CI): every option read by an engine/wrapper/provider table is declared in Config.yaml; each provider's default model agrees across Config, wrapper, and engine and is one of the picker values; the prompt block is identical in all three engines.

First run caught real drift: Apple's final prompt line lacked "and no surrounding quotation marks" — aligned. Mutation-tested against 7 injected drifts (wrapper/engine/provider-table default, undeclared option, option-id typo, default not in values, one-engine prompt edit); all caught.
