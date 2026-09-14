---
# popclip-summarize-nrt4
title: ChatGPT backend via Codex CLI (ChatGPT plan)
status: completed
type: feature
priority: high
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:19:19Z
parent: popclip-summarize-b6e8
blocked_by:
    - popclip-summarize-gshg
---

First subscription backend. Settings: ChatGPT › Backend = API key | Codex CLI (ChatGPT plan).

Sketch: `codex exec --skip-git-repo-check --sandbox read-only --ephemeral --json -c developer_instructions=<TOML-encoded prompt block> -` with framed selection on stdin; accept only the final completed agent message from JSONL; `codex login status` for auth checks (don't read auth files).

- [x] Disable web search, shell, apps/MCP, hooks, memory via supported config; verify an adversarial selection ("read ~/.ssh…") causes no tool use
- [x] Reasoning effort low; measure cold/warm latency vs API engine
- [x] Consistency check covers the shared prompt in this backend
- [x] README/settings: install + `codex login`, plan limits, training opt-out note

## Summary of Changes

Shipped as an **experimental, off-by-default** backend: **OpenAI › Backend** = API key (default) | Codex CLI with your ChatGPT plan. Wrapper `summarize-openai.sh` branches to `cli-summarize.swift --cli codex`; window title "OpenAI · Codex (ChatGPT plan)". Pre-flight `codex login status` (0.1 s): not signed in → clear message; API-key mode → refused (exit 2) so it never silently bills the API. Locked-down exec per the spike (no tools; capability-tested). Live: 3 styles OK (6–8 s incl. first compile), adversarial file-read selection summarized with no leak (2/2), DEL in Extra Instructions OK. Consistency checker covers the prompt block and the second engine call in the wrapper; macOS 13 floor typecheck includes the engine. Docs: package README section + privacy/troubleshooting, root README setting row, CHANGELOG.

Not verified: a real plan usage-limit message (message matching is heuristic: "usage limit"/"rate limit"/"429"/"quota").
