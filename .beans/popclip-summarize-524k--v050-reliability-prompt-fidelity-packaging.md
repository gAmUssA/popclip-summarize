---
# popclip-summarize-524k
title: v0.5.0 — reliability, prompt fidelity, packaging
status: completed
type: milestone
priority: normal
created_at: 2026-09-14T21:23:52Z
updated_at: 2026-09-14T22:31:36Z
---

Ideas adopted after comparing with another PopClip AI extension (ideas only; our architecture — native Swift engines + AppKit panel — stays). Focus: fewer transient failures, more faithful summaries, a self-describing package.

## Summary of Changes

Released as v0.5.0 (2026-09-14): bounded retries + clearer failures, prompt fidelity, version heading, consistency checks; plus v1.0.0 groundwork that landed before the tag — shellScriptRationale, per-engine key isolation, redirect refusal, private toolchain-keyed cache, in-package LICENSE/notices/README, Apple pre-compile gating. Leftover low-priority items moved to the Later epic.
