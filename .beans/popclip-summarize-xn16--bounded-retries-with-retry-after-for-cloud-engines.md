---
# popclip-summarize-xn16
title: Bounded retries with Retry-After for cloud engines
status: completed
type: feature
priority: high
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:51:53Z
parent: popclip-summarize-n1n1
---

Retry transport errors, 429 and 5xx a small number of times with exponential backoff + jitter, honoring Retry-After (seconds and HTTP-date), within a hard overall deadline that also shrinks each attempt's timeout.

Never retry: auth failures, unknown model, insufficient quota / 402, refusals, malformed 200s, truncation.

- [x] Shared retry policy in claude-summarize.swift and responses-summarize.swift
- [x] Overall deadline (monotonic clock); per-attempt timeout = min(remaining, default)
- [x] Verify with a local fake server: recovery, Retry-After both forms, deadline exhaustion, non-retryables

## Summary of Changes

Both cloud engines (claude-summarize.swift, responses-summarize.swift — same policy, kept in step):
- Up to 3 attempts within a 45 s overall deadline (ContinuousClock). Each request races the deadline in a task group, so a trickling response can't outlive it (URLSession's timeout only bounds inactivity).
- Retries 408/409/429/5xx/529 and transient URLErrors; never 4xx otherwise, 402, or OpenAI's `insufficient_quota` 429. Offline isn't retried.
- Retry-After as seconds or HTTP-date, clamped to a day; a wait past the deadline fails fast with a hint ("about 2 minutes" / "later"). Exponential backoff with jitter otherwise.
- Redirects are refused (key + selection must not follow a 3xx).
- Loopback-only `AI_SUMMARIZE_TEST_API_URL` override for tests.

Verified with a local fake server (~30 scenarios across both engines: recovery, both Retry-After forms, exhaustion, quota, 401/402/404/400/flat-xAI-400, hang, 503-then-hang, trickle, redirect-to-thief (0 requests leaked), huge Retry-After, final-attempt Retry-After, refused port) plus live calls on Claude/OpenAI/xAI. Codex review: 4 findings (trickle, overflow, redirect, stale hint) fixed; re-review clean.
