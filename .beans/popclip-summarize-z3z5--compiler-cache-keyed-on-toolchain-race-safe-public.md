---
# popclip-summarize-z3z5
title: Compiler cache keyed on toolchain, race-safe publication
status: completed
type: task
priority: normal
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:21:24Z
parent: popclip-summarize-dazt
---

Cache identity is the source hash only. A toolchain/SDK upgrade can leave a stale binary (e.g. Apple helper built without FoundationModels); fixed names race across concurrent runs and versions.

- [x] Key on source hash + `swiftc --version` + SDK + arch
- [x] Per-key output paths, atomic publish, private dir perms
- [x] Cleanup of stale entries

## Summary of Changes

`build_cached` keys on sha256(source) + resolved swiftc path + its mtime + `uname -rm` (~35 ms per run; `swiftc --version` 136 ms and `xcrun --show-sdk-version` 462 ms were too slow). Binaries are `<name>-<key>`, published by atomic rename; stale builds of the same helper and legacy unkeyed `<name>`/`<name>.hash` files are removed after a successful build, in-progress `.tmp` files left alone. Cache dir chmod 700. Still compiles via the /usr/bin/swiftc shim (calling the toolchain binary directly loses the SDK: "unable to load standard library").

Verified: legacy cache migrated on first run; cache hit 0.69 s; 3 concurrent cold builds converge on one binary with no leftovers.
