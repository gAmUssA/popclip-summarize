---
# popclip-summarize-knw3
title: Pass the selection via stdin, not only environment
status: draft
type: task
priority: low
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-dazt
---

Cloud engines allow 400K characters, but environment size limits can fail the exec before our guards run. Verify the real ceiling; if lower, read selection from stdin in wrappers/engines.
