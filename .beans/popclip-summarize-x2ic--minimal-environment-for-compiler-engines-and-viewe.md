---
# popclip-summarize-x2ic
title: Minimal environment for compiler, engines, and viewer
status: completed
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:17:41Z
parent: popclip-summarize-dazt
---

All `POPCLIP_OPTION_*` (every provider's API key) and the selection are inherited by swiftc, every engine, and the detached viewer.

- [x] swiftc and viewer launched with an explicit minimal env
- [x] Each engine receives only its own key + needed options
- [x] Verify with `ps eww` / env dump that keys don't leak

## Summary of Changes

`lib.sh`: `BASE_ENV` (HOME, TMPDIR, PATH, LANG, plus DEVELOPER_DIR if the user set one). swiftc and the detached viewer run under `env -i` with only that (+ SUMMARY_* for the viewer). `run_engine <binary> "<OPTION IDS>" [args]` gives an engine the selection, STYLE, EXTRA, the loopback test URL if set, and only the options its wrapper names.

Verified: env dump per engine with canary keys for all three providers — each engine sees only its own key; `ps eww` on the live viewer shows 0 canaries; forced rebuild compiles under the minimal env; live Apple/OpenAI(terra model option)/Grok(custom model option)/missing-key paths work; wrappers still reach the fake server.

`scripts/check-consistency.rb` now fails when a wrapper doesn't pass an option its engine reads (mutation-tested: dropped custom model, dropped key, unknown provider).
