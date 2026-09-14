---
# popclip-summarize-8cdm
title: Gate the Apple Intelligence action on unsupported Macs
status: completed
type: feature
priority: normal
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:24:06Z
parent: popclip-summarize-ctrs
---

`showapple` defaults on, so Intel/pre-26 Macs see an action that compiles then fails.

- [x] Choose: default off, a cheap pre-compile OS/arch check in the wrapper, or both — pre-compile check; default left on (your call)
- [x] Keep graceful model-not-ready errors

## Summary of Changes

`summarize-apple.sh` checks `uname -m` = arm64 and `sw_vers` major ≥ 26 before compiling, and fails instantly with a message pointing to cloud engines or the show-toggle. Engine-side availability errors (not enabled, model not ready, not eligible) unchanged. Verified on this Mac (works) and with fake uname/sw_vers for Intel and macOS 15.4 (exit 1 in <1 s, no compile). `showapple` still defaults on — changing the default is a product decision left open.
