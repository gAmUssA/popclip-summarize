---
# popclip-summarize-e2ga
title: Same-provider model fallback on overload
status: draft
type: feature
created_at: 2026-10-04T18:42:16Z
updated_at: 2026-10-04T18:42:16Z
parent: popclip-summarize-s09a
---

steipete/summarize tries the next candidate model on request errors (docs/model-auto.md). For us: after retries are exhausted on 429/529, optionally try the next model of the same provider (Haiku -> Sonnet). Never fall back from Apple Intelligence to a cloud engine.
