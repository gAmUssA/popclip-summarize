---
# popclip-summarize-7zav
title: Trademark review of bundled provider marks
status: completed
type: task
priority: normal
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T23:04:46Z
parent: popclip-summarize-ctrs
---

OpenUsage's MIT covers the SVG files, not the Anthropic/OpenAI/xAI trademarks. OpenAI and xAI guidelines require unaltered official assets and no implied affiliation; we recolored and (Grok) re-framed.

- [ ] Check each vendor's terms; prefer official assets used unaltered, or
- [ ] Fall back to text labels / neutral glyphs
- [ ] Check SF Symbols restrictions for `apple.logo`

## Summary of Changes

Review (Codex, primary sources, 2026-09-14; report: scratchpad trademark-review.md):
- **Apple:** SF Symbols 7.2 inspector for `apple.logo`: "This symbol may not be modified and may only be used to refer to Sign in with Apple." → replaced with original on-device.svg. Added "Apple Intelligence is a trademark of Apple Inc." to credits.
- **OpenAI:** logo OK only unaltered from the official kit (https://cdn.openai.com/brand/OpenAI-Logos-2025.zip → OpenAI-black-monoblossom.svg); action renamed to Summarize (OpenAI) since it calls the API.
- **Anthropic:** no public permission found for the Claude spark on third-party buttons; official kit has no black standalone spark.
- **xAI:** logos "without any alteration or adjustment" (our Grok viewBox was squared); official kit returned 403; guidelines ask for "Created with Grok" attribution on distributed output.

**Decision (user, 2026-09-14): keep the current OpenUsage logos on the Claude/OpenAI/Grok actions** despite the Anthropic and modified-Grok findings, relying on PopClip Directory precedent/disclaimer. Revisit if the reviewer or a vendor objects — fallback options recorded in the report (official unaltered OpenAI mark; neutral glyphs).
