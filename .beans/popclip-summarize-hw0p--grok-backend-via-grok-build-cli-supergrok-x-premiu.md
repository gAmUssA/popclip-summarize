---
# popclip-summarize-hw0p
title: 'Grok backend via Grok Build CLI — blocked: tools can''t be disabled'
status: draft
type: feature
priority: deferred
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:49:00Z
parent: popclip-summarize-s09a
blocked_by:
    - popclip-summarize-gshg
---

Second subscription backend. Settings: Grok › Backend = API key | Grok Build CLI.

Sketch: `grok --no-auto-update -p … --output-format json`, or ACP (`grok agent stdio`) to keep the selection off the command line (argv is visible to other local processes). No documented system-prompt flag — instructions go in the user turn; re-run the prompt-fidelity eval for this path.

- [ ] Confirm the binary is official Grok Build (not an unrelated `grok`)
- [ ] Deny tools via settings; no `--always-approve`
- [ ] 403 = entitlement (plan lacks access) vs 401 = login; weekly shared pool exhaustion message
- [ ] README/settings: plan requirement, training/coding-data controls

## Spike result (2026-09-14, grok 1.0.25, SuperGrok login): gate 1 FAILED — not shipped

Sign-in check works: `grok models` (0.7 s) prints "You are logged in with grok.com" and the plan's models (grok-4.6 default, grok-4.5 — **not** grok-4.3).

Isolation attempts (all with `--prompt-file`, `--output-format json`, empty `--cwd`, `--system-prompt-override`, `--disable-web-search --no-subagents --no-plan`, and env GROK_{CLAUDE,CURSOR}_{SKILLS,RULES,AGENTS,MCPS,HOOKS}_ENABLED=0, GROK_MEMORY=0, GROK_SUBAGENTS=0, GROK_WRITE_FILE=0, GROK_LSP_TOOLS=0, GROK_WEB_FETCH=0, GROK_SANDBOX=strict). System prompt orders a read of a marker file:

| Variant | Result |
|---|---|
| Unlocked control | leaked; ran user hooks (Bartender claude-event-hook, jq) and DaVinci Resolve MCP |
| + `--tools ""` + `--max-turns 1` | no leak, but only because the turn was cancelled after the tool call |
| + `--tools ""` (no turn cap) | **leaked 2/2** via read_file |
| + `--deny read/edit/write/bash/grep/glob/mcp/webfetch/websearch/task` | **leaked 2/2** |
| + `--tools <nonexistent>` (allow-list of nothing) | **leaked 2/2**; ResolveMCP spawned in 1 run |
| + guessed `--disallowed-tools` list | session init error: search_replace requires read_file |

Conclusion: in headless mode Grok Build doesn't enforce its tool allow-list or deny rules for built-in tools, and native-config MCP servers still start. No documented way to skip user config (GROK_HOME also moves credentials).

Retry when: Grok Build adds a bare/no-user-config mode or enforces --tools; or try ACP (`grok agent stdio`) where the client declares no fs/terminal capabilities — verify with the same marker test and process monitor before shipping.
