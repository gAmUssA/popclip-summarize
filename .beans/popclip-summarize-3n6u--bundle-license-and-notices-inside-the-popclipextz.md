---
# popclip-summarize-3n6u
title: Bundle LICENSE and notices inside the .popclipextz
status: scrapped
type: task
priority: normal
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:26:17Z
parent: popclip-summarize-1sh3
---

The package only zips AISummarize.popclipext; LICENSE and the icon provenance note stay outside.

- [ ] Stage a copy of the extension with LICENSE (+ notices) for packaging
- [ ] CI step lists archive contents and fails if LICENSE is missing

## Reasons for Scrapping

Duplicate of popclip-summarize-ztc8 (v1.0.0). The directory needs the license and notices as real files inside the package, not a staging copy at package time, so the work moved there.
