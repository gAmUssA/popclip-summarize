---
# popclip-summarize-c2f2
title: 'Decision: keep native architecture for the directory'
status: completed
type: task
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-ir6x
---

The audit's preferred path is porting cloud engines to JavaScript (built-in large type, no compiler) and splitting on-device into a separate package. We are **not** doing that: the native panel, shared viewer across engines, and on-device FoundationModels engine are the product.

Plan instead: honest `shellScriptRationale`, hardening epic, clear toolchain docs. Revisit only if review rejects the architecture — fallback options: JS engines + `runShellScriptFile` bridge to the viewer (PopClip 6221+), or a Shortcut-based on-device action.
