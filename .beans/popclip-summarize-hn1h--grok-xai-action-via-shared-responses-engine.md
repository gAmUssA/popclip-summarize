---
# popclip-summarize-hn1h
title: Grok / xAI action via shared Responses engine
status: completed
type: feature
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:23:52Z
parent: popclip-summarize-tnvg
---

Fourth action backed by xAI's Responses API. `openai-summarize.swift` became `responses-summarize.swift --provider openai|xai`.

- [x] Provider table (URL, option ids, default model, reasoning-effort floor)
- [x] Config options: key, model picker (grok-4.3/4.5/4.6), custom model, show toggle
- [x] xAI quirks: flat error bodies, HTTP 400 for bad key / unknown model open settings
- [x] Live-tested all models + error paths; Codex review clean
- [x] README / CHANGELOG
