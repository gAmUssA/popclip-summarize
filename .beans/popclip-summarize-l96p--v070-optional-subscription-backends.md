---
# popclip-summarize-l96p
title: v0.7.0 → shipped in 0.6.0 — optional subscription backends
status: completed
type: milestone
priority: normal
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T23:49:00Z
---

Let users who already pay for a consumer plan summarize without a pay-as-you-go API key, by driving the provider's **official, user-installed, user-logged-in CLI** — never by extracting or reusing OAuth tokens. API-key engines stay the default.

Research (2026-09-14, primary sources spot-checked):
- **OpenAI** — `codex exec` "reuses saved CLI authentication by default" (ChatGPT sign-in); docs recommend API keys for automation but document scripting and product embedding (App Server). Allowed route. https://learn.chatgpt.com/docs/non-interactive-mode
- **xAI** — Grok Build CLI (May 25, 2026): "Available now to all SuperGrok and X Premium Plus subscribers"; "Headless mode (-p) allows easily running agents inside scripts"; "full ACP support to build your own bots". Allowed route. https://x.ai/news/grok-build-cli
- **Anthropic** — "Anthropic does not permit third-party developers to offer Claude.ai login into their own applications, or to route requests through Free, Pro, or Max plan credentials on behalf of their users." Hosting the unmodified binary requires Commercial Terms. Blocked pending written permission. https://code.claude.com/docs/en/legal-and-compliance

Privacy differs from API: consumer-plan content may be used for training unless the user opts out — must be disclosed in settings/README.

Full report: scratchpad subscription-auth-research.md (copy kept as subscription-auth-research.keep.md).

## Summary of Changes

Released early as part of v0.6.0 (2026-09-14): Claude (Claude Code) and OpenAI (Codex) plan backends, experimental and off by default. Grok blocked on Grok Build tool isolation — see hw0p in Later.
