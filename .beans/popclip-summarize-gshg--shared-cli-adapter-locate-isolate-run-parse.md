---
# popclip-summarize-gshg
title: 'Shared CLI adapter: locate, isolate, run, parse'
status: in-progress
type: feature
priority: high
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:08:59Z
parent: popclip-summarize-b6e8
---

Swift helper (Process) used by subscription backends.

- [ ] Resolve the CLI from known install paths (Homebrew arm/intel, ~/.local/bin, npm global) — PopClip has no login-shell PATH; never source shell rc files
- [ ] Run in a private empty temp cwd; keep real HOME (credentials live there); strip POPCLIP_OPTION_* and provider key env vars so the CLI can't silently switch to API billing
- [ ] Selection via stdin only; arguments as an array; no shell interpolation
- [ ] Drain stdout/stderr concurrently; wall-clock deadline; kill process group on timeout
- [ ] Error classes: not installed / not logged in / plan limit reached (with reset time if given) / entitlement denied / timeout / unexpected — exit 2 where settings can fix it
- [ ] Never deliver partial text from a failed turn; never fall back to an API key automatically
- [ ] Fixture tests with fake CLIs (missing, nonzero, malformed JSON, hang, huge output)
