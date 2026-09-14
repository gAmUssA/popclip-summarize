---
# popclip-summarize-hw0p
title: Grok backend via Grok Build CLI (SuperGrok / X Premium Plus)
status: todo
type: feature
priority: normal
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T22:22:49Z
parent: popclip-summarize-b6e8
blocked_by:
    - popclip-summarize-gshg
---

Second subscription backend. Settings: Grok › Backend = API key | Grok Build CLI.

Sketch: `grok --no-auto-update -p … --output-format json`, or ACP (`grok agent stdio`) to keep the selection off the command line (argv is visible to other local processes). No documented system-prompt flag — instructions go in the user turn; re-run the prompt-fidelity eval for this path.

- [ ] Confirm the binary is official Grok Build (not an unrelated `grok`)
- [ ] Deny tools via settings; no `--always-approve`
- [ ] 403 = entitlement (plan lacks access) vs 401 = login; weekly shared pool exhaustion message
- [ ] README/settings: plan requirement, training/coding-data controls
