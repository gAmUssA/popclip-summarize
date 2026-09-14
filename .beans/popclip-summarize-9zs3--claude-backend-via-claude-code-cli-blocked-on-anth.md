---
# popclip-summarize-9zs3
title: Claude backend via Claude Code CLI — blocked on Anthropic permission
status: draft
type: feature
priority: deferred
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T22:22:38Z
parent: popclip-summarize-b6e8
blocked_by:
    - popclip-summarize-jp52
---

Blocked. Anthropic's legal page: "Anthropic does not permit third-party developers to offer Claude.ai login into their own applications, or to route requests through Free, Pro, or Max plan credentials on behalf of their users." Running Claude Code inside a product requires the Commercial Terms and an unmodified binary.

A PopClip extension driving the user's own `claude -p` plausibly falls under the prohibition. Do not build until Anthropic confirms in writing.

If approved: `claude -p --output-format json --system-prompt-file <private file> --tools "" --no-session-persistence` in an empty cwd; **not** `--bare` (bare mode ignores subscription credentials).
