---
# popclip-summarize-lja4
title: Pass source app name as prompt context
status: draft
type: feature
priority: normal
created_at: 2026-10-04T18:42:16Z
updated_at: 2026-10-04T19:14:43Z
parent: popclip-summarize-s09a
---

From steipete/summarize's <context> block (URL, title, site). Pass the source app name (e.g. Slack, Mail) so the model picks a thread/email structure; browser URL/title opt-in only for cloud engines since it's extra data leaving the Mac. Verify PopClip's environment variable names for app name and browser URL/title first; none are read today.



Verified variable names (popclip.app/dev/script-variables): POPCLIP_APP_NAME, POPCLIP_BUNDLE_IDENTIFIER, POPCLIP_BROWSER_TITLE, POPCLIP_BROWSER_URL (supported browsers only), POPCLIP_URLS. run_engine passes none of them today.
