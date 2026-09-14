---
# popclip-summarize-2i4q
title: Show installed version in extension settings
status: completed
type: feature
priority: normal
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:54:41Z
parent: popclip-summarize-1sh3
---

A heading in settings showing the build version (from the git tag at package time), plus author/support metadata, so bug reports identify the build.

- [x] Version heading in Config.yaml (committed, not generated — the PopClip Directory builds from source, so a package-time injection would never reach directory installs)
- [x] Keep the git tag the single version source (make release + release workflow refuse a tag that doesn't match the heading)

## Summary of Changes

`versionhead` heading at the end of the settings: "AI Summarize 0.4.0 · github.com/gAmUssA/popclip-summarize". `scripts/config-version.rb` reads it; `make release` and `release.yml` fail when it differs from the tag (verified in a throwaway clone). README release steps updated. Author metadata skipped — PopClip Config has no author field; the repo link in the heading serves support.

Not yet verified visually inside PopClip's settings pane.
