---
# popclip-summarize-fitf
title: Privacy-aware diagnostics via the unified log
status: completed
type: task
priority: low
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-15T00:00:55Z
parent: popclip-summarize-dazt
---

README: unsigned extension, readable source, direct provider requests, local compilation. Optional diagnostics recording provider/status/request id/attempts/duration only — never selection, key, or summary.

- [ ] README section
- [ ] Decide whether diagnostics are worth it

## Summary of Changes

os.Logger in all engines + viewer (subsystem io.gamov.popclip.extension.ai-summarize; categories claude, responses, apple, cli, viewer) and `logger` from lib.sh with an "ai-summarize " prefix (unified log drops logger tags/subsystem). Logged: start (model/provider/style/selection length), each HTTP attempt (status, timing, request-id), transport errors, retry waits, done (attempts, stop/incomplete reason, output length, total ms), failures (exit code + message as <private>), CLI sign-in (loggedIn/method/plan or chatgpt yes/no) and exec exit/timing/bytes, builds (key, ok/failed, seconds), engine exit codes, viewer shown/ready/failed/closed. `make logs` / `make logs-recent`. READMEs document Console.app filtering.

Verified with a canary word in the selection and a canary API key across Claude API, OpenAI (401), Grok (window), Apple, and Claude Code: 35 log lines, 0 occurrences of either canary or the real key's tail; the 401 message shows as <private>. Typechecks at macOS 13.

Trust-model README section was already covered by the package README (privacy + readable source).
