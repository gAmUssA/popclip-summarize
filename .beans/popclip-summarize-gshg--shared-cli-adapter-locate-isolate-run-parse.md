---
# popclip-summarize-gshg
title: 'Shared CLI adapter: locate, isolate, run, parse'
status: completed
type: feature
priority: high
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:19:19Z
parent: popclip-summarize-b6e8
---

Swift helper (Process) used by subscription backends.

- [x] Resolve the CLI from known install paths (Homebrew arm/intel, ~/.local/bin, npm global) — PopClip has no login-shell PATH; never source shell rc files
- [x] Run in a private empty temp cwd; keep real HOME (credentials live there); strip POPCLIP_OPTION_* and provider key env vars so the CLI can't silently switch to API billing
- [x] Selection via stdin only; arguments as an array; no shell interpolation
- [x] Drain stdout/stderr concurrently; wall-clock deadline; kill process group on timeout
- [x] Error classes: not installed / not logged in / plan limit reached (with reset time if given) / entitlement denied / timeout / unexpected — exit 2 where settings can fix it
- [x] Never deliver partial text from a failed turn; never fall back to an API key automatically
- [x] Fixture tests with fake CLIs (missing, nonzero, malformed JSON, hang, huge output)

## Summary of Changes

`cli-summarize.swift --cli codex` (Grok can be added as another `--cli`). posix_spawn in its own process group; stdin writer with SIGPIPE ignored; concurrent drains keeping the last 4 MB per stream; 90 s deadline → SIGTERM/SIGKILL to the group, plus an unconditional group SIGKILL after exit so descendants can't hold pipes; lock-protected snapshots. Child env: HOME/TMPDIR/LANG + PATH built from the CLI's own dir (npm codex needs node). Private empty 0700 work dir, removed on every exit path. Test-only `AI_SUMMARIZE_TEST_CLI` accepted only inside TMPDIR by resolved path components.

Verified with fake CLIs: not signed in, API-key mode, usage limit, 401, crash, 10 MB output, hang (90 s, 0 leftover children), descendant holding pipes, CLI exiting without reading 150 KB stdin, nonzero exit after a summary, code-mode warning, override bypass via sibling dir and symlink (both ignored). Codex review: 5 findings (unbounded drain wait, SIGPIPE, override prefix/symlink, TOML DEL, success on nonzero exit) — all fixed and reproduced; re-review clean.
