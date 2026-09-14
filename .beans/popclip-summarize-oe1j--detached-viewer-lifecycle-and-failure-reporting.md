---
# popclip-summarize-oe1j
title: Detached viewer lifecycle and failure reporting
status: todo
type: task
created_at: 2026-09-14T21:26:05Z
updated_at: 2026-09-14T21:26:05Z
parent: popclip-summarize-dazt
---

Viewer is nohup'd with output discarded; a launch failure is invisible and the temp payload may leak if launch fails before unlink.

- [ ] Startup acknowledgement or error surfaced to the action
- [ ] Temp payload cleanup on every failure path
- [ ] Test repeated invocations, PopClip quit, multiple displays/Spaces
- [ ] Verify fullscreen style scrolls/clips correctly for long text
