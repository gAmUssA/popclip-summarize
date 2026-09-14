---
# popclip-summarize-x2ic
title: Minimal environment for compiler, engines, and viewer
status: todo
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-dazt
---

All `POPCLIP_OPTION_*` (every provider's API key) and the selection are inherited by swiftc, every engine, and the detached viewer.

- [ ] swiftc and viewer launched with an explicit minimal env
- [ ] Each engine receives only its own key + needed options
- [ ] Verify with `ps eww` / env dump that keys don't leak
