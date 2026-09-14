---
# popclip-summarize-6xtu
title: Add shellScriptRationale to Config.yaml
status: completed
type: task
priority: critical
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:15:06Z
parent: popclip-summarize-japp
---

Automatic rejection without it: shell-script actions require a `shellScriptRationale` (≥20 chars). Config comments don't count.

Also correct the outdated justification everywhere ("PopClip JS has no subprocess API"): PopClip 6221 added `popclip.runShellScript*`. The honest rationale is native capabilities — AppKit floating panel, FoundationModels on-device inference, one compiled engine per provider sharing that viewer.

- [x] Draft rationale; add to Config.yaml
- [x] Fix claims in Config.yaml comments, lib.sh header, README "How it works"
- [x] make check asserts the field exists when any action is a shell script

## Summary of Changes

Top-level `shellScriptRationale` (232 chars): native AppKit panel + on-device FoundationModels, which PopClip's JavaScript API can't do; readable Swift compiled locally, no binaries shipped. Removed the outdated "JavaScript has no subprocess API" claim from Config comments, lib.sh, both cloud engine headers, summary-window.swift, and README — replaced with the honest reason (6221's JS→shell bridge would only add a hop in front of the same native code; Swift cloud engines keep one contract and one viewer). `make check` fails without a ≥20-char rationale when any action is a shell script (verified by removing it).

Pending: confirm PopClip accepts the key without complaint on install.
