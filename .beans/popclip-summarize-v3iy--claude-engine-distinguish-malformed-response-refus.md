---
# popclip-summarize-v3iy
title: 'Claude engine: distinguish malformed response, refusal, and empty output'
status: todo
type: feature
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:23:52Z
parent: popclip-summarize-n1n1
---

Today malformed JSON or a missing `content` array both surface as "Claude returned an empty summary."

- [ ] Separate decode failure / wrong shape / refusal (stop_reason) / genuinely empty
- [ ] Match the messages the Responses engine already gives
- [ ] Fixture-check each case
