---
# popclip-summarize-9zs3
title: Claude backend via Claude Code CLI (Claude plan)
status: completed
type: feature
priority: normal
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:39:39Z
parent: popclip-summarize-b6e8
blocked_by:
    - popclip-summarize-jp52
---

Blocked. Anthropic's legal page: "Anthropic does not permit third-party developers to offer Claude.ai login into their own applications, or to route requests through Free, Pro, or Max plan credentials on behalf of their users." Running Claude Code inside a product requires the Commercial Terms and an unmodified binary.

A PopClip extension driving the user's own `claude -p` plausibly falls under the prohibition. Do not build until Anthropic confirms in writing.

If approved: `claude -p --output-format json --system-prompt-file <private file> --tools "" --no-session-persistence` in an empty cwd; **not** `--bare` (bare mode ignores subscription credentials).

## Summary of Changes

Built as an **experimental, off-by-default** backend after the user's decision (2026-09-14): a PopClip extension running on the user's own Mac with their own subscription is personal use of the unmodified Claude Code binary, which Anthropic's legal page explicitly does not prevent ("Nor does it prevent an end user from signing in to the unmodified Claude Code binary with their own Claude subscription"). Distribution via the public directory remains the gray part; docs say it's meant for your own plan and provider terms apply.

**Claude › Backend** = API key (default) | Claude Code with your Claude plan. `cli-summarize.swift --cli claude`:
- Pre-flight `claude auth status --json`: requires loggedIn and authMethod == claude.ai (API-key/Console logins refused, exit 2).
- `claude -p --output-format json --no-session-persistence --model <Claude Model setting> --system-prompt <shared prompt> --tools "" --setting-sources "" --strict-mcp-config --mcp-config {"mcpServers":{}} --disable-slash-commands`, selection on stdin, cwd = empty private dir.
- Child env gains USER/LOGNAME (Claude Code needs them to find its Keychain login; without them auth status says loggedIn:false). ANTHROPIC_API_KEY never passed.

Verified: capability gate (system prompt orders a file read: control leaked in 38 s with hooks/plugins; locked 2/2 NO-TOOLS in ~3.4 s); live 3 styles; Sonnet 5 3.3–4.2 s vs Haiku 4.5 4.8–7.5 s; adversarial selection no leak (2/2); real bad-model wording matched (exit 2); fake CLIs for logged out, apiKey auth, usage limit, bad model, auth failure, non-JSON, hang (90 s, 0 leftovers). Codex review: P2 addchdir SDK compatibility + P3 checker first-match gap — both fixed; re-review clean.
