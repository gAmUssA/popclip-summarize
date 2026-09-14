---
# popclip-summarize-h3m0
title: 'Consistency checks: Config defaults vs wrappers vs engines'
status: todo
type: task
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:23:52Z
parent: popclip-summarize-1sh3
---

Model defaults live in Config.yaml, each wrapper, and the engine provider table. Fail `make check` when they drift.

- [ ] Ruby/shell check comparing defaults and option ids
- [ ] Wire into CI
