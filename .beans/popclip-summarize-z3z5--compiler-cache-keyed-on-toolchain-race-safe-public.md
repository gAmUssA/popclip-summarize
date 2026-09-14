---
# popclip-summarize-z3z5
title: Compiler cache keyed on toolchain, race-safe publication
status: todo
type: task
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-dazt
---

Cache identity is the source hash only. A toolchain/SDK upgrade can leave a stale binary (e.g. Apple helper built without FoundationModels); fixed names race across concurrent runs and versions.

- [ ] Key on source hash + `swiftc --version` + SDK + arch
- [ ] Per-key output paths, atomic publish, private dir perms
- [ ] Cleanup of stale entries
