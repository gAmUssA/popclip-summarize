---
# popclip-summarize-7mb7
title: Provider-neutral top-level extension icon
status: completed
type: feature
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T23:04:46Z
parent: popclip-summarize-ctrs
---

Without a top-level `icon`, the first action's Claude mark becomes the extension's icon — reads as affiliation. Add an original neutral icon; keep provider marks only on individual actions.

## Summary of Changes

`icon: summarize.svg` at top level — original artwork (faded source lines → chevron → bold summary line), monochrome for PopClip templates. Rejected drafts: sparkle accent (collides with Google Gemini's four-point star), plain lines (reads as a list icon), funnel (reads as a lightbulb). Also replaced the Apple Intelligence action's `symbol:apple.logo` with original `on-device.svg` (chip) — see 7zav. Both listed as original in THIRD_PARTY_NOTICES.txt.

Not yet seen inside PopClip's bar/extension list.
