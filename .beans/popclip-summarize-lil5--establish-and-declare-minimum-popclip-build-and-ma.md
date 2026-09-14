---
# popclip-summarize-lil5
title: Establish and declare minimum PopClip build and macOS version
status: todo
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-ctrs
---

Config declares build 4586 with no test; README claims macOS 10.15; `symbol:apple.logo` needs 11+; users compile with whatever Swift toolchain they have.

- [ ] Pick baseline (likely PopClip 6221 / macOS 13+), test it
- [ ] Add `macos version` (quoted) to Config
- [ ] Document supported Xcode/CLT; detect unsupported toolchain with a clear message
- [ ] Align README
