---
# popclip-summarize-dlvw
title: Local models via an OpenAI-compatible base URL
status: draft
type: feature
created_at: 2026-10-04T19:14:43Z
updated_at: 2026-10-04T19:14:43Z
parent: popclip-summarize-s09a
---

steipete/summarize supports Ollama and any OpenAI-compatible endpoint. A Custom Base URL (loopback or user-set) on the Responses engine would give a free, private engine on Macs without Apple Intelligence. Check first whether Ollama/LM Studio serve /v1/responses; if not, add a Chat Completions path. No API key required for loopback.
