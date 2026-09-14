---
# popclip-summarize-xn16
title: Bounded retries with Retry-After for cloud engines
status: todo
type: feature
priority: high
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:23:52Z
parent: popclip-summarize-n1n1
---

Retry transport errors, 429 and 5xx a small number of times with exponential backoff + jitter, honoring Retry-After (seconds and HTTP-date), within a hard overall deadline that also shrinks each attempt's timeout.

Never retry: auth failures, unknown model, insufficient quota / 402, refusals, malformed 200s, truncation.

- [ ] Shared retry policy in claude-summarize.swift and responses-summarize.swift
- [ ] Overall deadline (monotonic clock); per-attempt timeout = min(remaining, default)
- [ ] Verify with a local fake server: recovery, Retry-After both forms, deadline exhaustion, non-retryables
