---
# popclip-summarize-mqz6
title: Keywords, apps metadata, and OpenAI wording
status: completed
type: task
priority: normal
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T23:04:46Z
parent: popclip-summarize-ctrs
---

- [ ] `keywords`: summary summarize summarise ai anthropic claude openai grok xai apple intelligence
- [ ] Optional `apps` links per provider
- [ ] Decide action label: "ChatGPT" vs "OpenAI" (API ≠ ChatGPT product); viewer titles + README follow

## Summary of Changes

- `keywords` (space-separated string, per top-level-properties doc): summary summarize summarise tldr ai llm claude anthropic chatgpt openai gpt grok xai apple intelligence on-device.
- `apps` skipped: that field describes desktop apps an action works with; the cloud actions call APIs and need no app.
- Label kept as "ChatGPT": settings and README already say "OpenAI API key" / billed separately from ChatGPT plans, and the planned Codex backend (v0.7.0) makes "ChatGPT plan" literally accurate. Revisit if the directory reviewer objects.

## Update

Label changed after the trademark review (user decision): the action is now **Summarize (OpenAI)**; heading, show-toggle, viewer title, engine messages, and docs follow. Option identifiers unchanged, so saved keys survive.
