---
# popclip-summarize-92zp
title: make release misses staged-only and untracked changes
status: completed
type: bug
priority: high
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T21:25:08Z
parent: popclip-summarize-tnvg
---

The `release` target's `git diff --quiet` ignores staged-only and untracked files, so a release can be tagged from a tree that doesn't match what's committed.

- [x] Use `git status --porcelain`
- [x] Validate V is X.Y.Z and the tag does not already exist
- [x] Verify with an untracked file present

## Summary of Changes

`make release` now checks `git status --porcelain`, requires V to match X.Y.Z, and refuses an existing tag. Verified in a throwaway clone: bad V, existing tag, untracked file, and staged-only change are all rejected (the old `git diff --quiet` passed the staged-only case).
