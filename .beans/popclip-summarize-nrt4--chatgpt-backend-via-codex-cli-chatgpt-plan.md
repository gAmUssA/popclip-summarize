---
# popclip-summarize-nrt4
title: ChatGPT backend via Codex CLI (ChatGPT plan)
status: in-progress
type: feature
priority: high
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:08:59Z
parent: popclip-summarize-b6e8
blocked_by:
    - popclip-summarize-gshg
---

First subscription backend. Settings: ChatGPT › Backend = API key | Codex CLI (ChatGPT plan).

Sketch: `codex exec --skip-git-repo-check --sandbox read-only --ephemeral --json -c developer_instructions=<TOML-encoded prompt block> -` with framed selection on stdin; accept only the final completed agent message from JSONL; `codex login status` for auth checks (don't read auth files).

- [ ] Disable web search, shell, apps/MCP, hooks, memory via supported config; verify an adversarial selection ("read ~/.ssh…") causes no tool use
- [ ] Reasoning effort low; measure cold/warm latency vs API engine
- [ ] Consistency check covers the shared prompt in this backend
- [ ] README/settings: install + `codex login`, plan limits, training opt-out note
