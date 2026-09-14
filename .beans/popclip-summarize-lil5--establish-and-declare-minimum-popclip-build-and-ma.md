---
# popclip-summarize-lil5
title: Establish and declare minimum PopClip build and macOS version
status: completed
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:44:13Z
parent: popclip-summarize-ctrs
---

Config declares build 4586 with no test; README claims macOS 10.15; `symbol:apple.logo` needs 11+; users compile with whatever Swift toolchain they have.

- [x] Pick baseline (likely PopClip 6221 / macOS 13+), test it
- [x] Add `macos version` (quoted) to Config
- [x] Document supported Xcode/CLT; detect unsupported toolchain with a clear message
- [x] Align README

## Summary of Changes

- `macos version: "13.0"`: cloud engines use Duration/ContinuousClock (typecheck fails at 12.0, passes at 13.0); viewer passes at 12.0; Apple engine is macOS 26 by design and gated pre-compile in its wrapper.
- `popclip version: 4586` kept: every config feature used predates it per PopClip's changelog (secret 4508; description/value labels/SVG icons 3510; YAML + shell script 3785); `shellScriptRationale` (6159) and `keywords` (6221) are directory metadata. Verified working on installed PopClip 2025.9.2 (build 5155, Setapp).
- `make check` typechecks cloud engines + viewer against the declared floor (proved by injecting a macOS 14 API → FAIL).
- READMEs state macOS 13+ and what was tested.
- Toolchain: missing CLT and missing swiftc already produce clear messages (lib.sh). An old Xcode (Swift < 5.7) is not detected — untestable here; noted.
