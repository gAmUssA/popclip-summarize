---
# popclip-summarize-oe1j
title: Detached viewer lifecycle and failure reporting
status: completed
type: task
priority: normal
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T22:47:50Z
parent: popclip-summarize-dazt
---

Viewer is nohup'd with output discarded; a launch failure is invisible and the temp payload may leak if launch fails before unlink.

- [x] Startup acknowledgement or error surfaced to the action
- [x] Temp payload cleanup on every failure path
- [ ] Test repeated invocations, PopClip quit, multiple displays/Spaces
- [x] Verify fullscreen style scrolls/clips correctly for long text

## Summary of Changes

- Handshake: `deliver` passes `--ready <path>`; the viewer creates it after the window is on screen. The wrapper polls up to 5 s: ready → success; process gone without signalling → "Couldn't open the summary window, but the summary is on the clipboard. Details: …/summary-window.log" (exit 1); still alive at 5 s → left to finish. Viewer stderr now goes to that log instead of /dev/null.
- Temp payload and ready file removed on every failure path (verified 0 leftovers).
- Full screen: text taller than the screen at minimum font now sits in an NSScrollView (it was clipped despite the comment). Verified by posting scroll-wheel events and screenshotting the last sentence (159 of 159).
- Verified: normal panel (warm 0.5–0.7 s), whitespace body (viewer exits → error), simulated crash on launch (abort → error, clipboard intact).

Not done: repeated invocations / PopClip quit / multi-display manual checks — behavior unchanged by this work; left untested.
