---
# popclip-summarize-ztc8
title: License and third-party notices inside the package
status: completed
type: task
priority: high
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:18:34Z
parent: popclip-summarize-japp
---

Directory ZIPs exclude README and dot/underscore paths, so notices must be real files inside `AISummarize.popclipext` (e.g. `LICENSE`, `THIRD_PARTY_NOTICES.txt` with OpenUsage's MIT text and exact upstream paths/modifications for the SVGs).

Overlaps v0.5.0 "Bundle LICENSE and notices" — do it once, in the package itself rather than a staging copy.

## Summary of Changes

`AISummarize.popclipext/LICENSE` (identical to root) and `THIRD_PARTY_NOTICES.txt`: OpenUsage MIT text, each SVG's upstream path + last-changing commit, the exact modifications (currentColor→#000000; Grok viewBox squared), and a trademark/non-affiliation statement. `make check` fails if either file is missing, LICENSE drifts from root, or any bundled SVG isn't listed. Verified both files are inside the built .popclipextz. README License section points to the notices file.
