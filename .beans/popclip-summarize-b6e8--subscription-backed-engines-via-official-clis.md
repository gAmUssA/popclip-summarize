---
# popclip-summarize-b6e8
title: Subscription-backed engines via official CLIs
status: completed
type: epic
priority: normal
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:49:00Z
parent: popclip-summarize-l96p
---

Shared subprocess adapter + per-provider backends. Normalize to the existing engine contract (stdout summary, stderr error, exit 0/1/2).

## Summary of Changes

Shipped experimental, off-by-default plan backends in 0.6.0: Claude via Claude Code (9zs3) and OpenAI via Codex (nrt4), on a shared hardened CLI runner (gshg). Grok via Grok Build failed the isolation gate (hw0p) and moved to the Later epic.
