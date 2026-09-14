---
# popclip-summarize-v3iy
title: 'Claude engine: distinguish malformed response, refusal, and empty output'
status: completed
type: feature
priority: normal
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:51:53Z
parent: popclip-summarize-n1n1
---

Today malformed JSON or a missing `content` array both surface as "Claude returned an empty summary."

- [x] Separate decode failure / wrong shape / refusal (stop_reason) / genuinely empty
- [x] Match the messages the Responses engine already gives
- [x] Fixture-check each case

## Summary of Changes

Claude engine now distinguishes non-JSON 200 ("isn't JSON … proxy or captive portal"), missing `content`, `stop_reason: "refusal"` (with `stop_details.explanation`), budget exhausted before any text, and genuinely empty output. 402 billing and 529 overload get their own messages. Responses engine got the same non-JSON / missing-`output` checks. Each case exercised against the fake server.
