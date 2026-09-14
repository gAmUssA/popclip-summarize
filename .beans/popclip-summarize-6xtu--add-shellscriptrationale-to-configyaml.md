---
# popclip-summarize-6xtu
title: Add shellScriptRationale to Config.yaml
status: todo
type: task
priority: critical
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-japp
---

Automatic rejection without it: shell-script actions require a `shellScriptRationale` (≥20 chars). Config comments don't count.

Also correct the outdated justification everywhere ("PopClip JS has no subprocess API"): PopClip 6221 added `popclip.runShellScript*`. The honest rationale is native capabilities — AppKit floating panel, FoundationModels on-device inference, one compiled engine per provider sharing that viewer.

- [ ] Draft rationale; add to Config.yaml
- [ ] Fix claims in Config.yaml comments, lib.sh header, README "How it works"
- [ ] make check asserts the field exists when any action is a shell script
