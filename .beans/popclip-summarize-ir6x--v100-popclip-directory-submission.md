---
# popclip-summarize-ir6x
title: v1.0.0 — PopClip Directory submission
status: in-progress
type: milestone
priority: normal
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:13:51Z
blocked_by:
    - popclip-summarize-524k
---

Get the extension accepted into the official PopClip Directory (https://www.popclip.app/extensions/submit). Submission is GitHub-driven: install the PopClip Directory app on the repo, add `popclip-directory.yaml`, push a new `v` tag; ingestion runs automated checks, then manual review.

Source: submission-readiness audit (2026-09-14). Architecture decision: keep native Swift engines + AppKit panel and defend it in the shell rationale (see decision bean) rather than porting cloud engines to JavaScript.

Depends on v0.5.0 (packaging items overlap).
