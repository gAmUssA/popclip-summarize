---
# popclip-summarize-kjrm
title: 'Spike: Codex CLI as a ChatGPT-plan backend'
status: completed
type: task
created_at: 2026-09-14T23:08:59Z
updated_at: 2026-09-14T23:08:59Z
parent: popclip-summarize-b6e8
---

Gate check before implementing (2026-09-14, codex-cli 0.154.0, ChatGPT login).

**Gate 1 — tool isolation: PASS.** Flags: `codex exec --skip-git-repo-check --ephemeral --ignore-user-config --ignore-rules -s read-only -C <empty tmp> --json` + `--disable` for shell_tool, unified_exec(_tty), apps, browser_use(_external), computer_use, hooks, plugins, remote_plugin, multi_agent, image_generation, view_image, goals, skill_search, tool_suggest, in_app_browser, sleep_tool, code_mode_host, workspace_dependencies, skill_mcp_dependency_install, shell_snapshot, personality; `-c web_search="disabled"`. Capability test (developer instructions *ask* it to read a marker file): unlocked control ran 2 command_execution items and leaked the marker; locked runs (2/2) had no tool items, replied NO-TOOLS, marker never appeared. Prompt-injection selection (2/2): summarized the request instead of obeying.

**Gate 2 — speed: acceptable for an opt-in.** Warm 4.4–5.1 s (5 runs), first runs 6–10 s; API engines ~1–4 s. Each run ≈11.7K input tokens (Codex system prompt) against the plan.

**Findings for the implementation:**
- npm-installed codex needs `node` on PATH (`env: node: No such file`) — child PATH must include the CLI's dir.
- Disabling code mode emits a harmless `item.type=error` "Code Mode is unavailable…" — must not count as failure.
- Success = `item.completed` agent_message + `turn.completed`.
- Signed out: `codex exec` burns 16.6 s on 401 reconnects; `codex login status` answers in 0.11 s (exit 1 "Not logged in") → pre-flight it.
- Summary quality matched API engines on the fidelity prompt.
