# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-09-14

### Added

- **Summarize (ChatGPT)** — a third action backed by OpenAI's Responses API, with
  its own Keychain-stored API key, a model picker (GPT-5.6 Luna, Terra, Sol, and
  GPT-6 Astra; Luna by default), and a custom model ID override. Reasoning
  effort is pinned to the lowest each model allows, requests are sent with
  `store: false`, and it shares the Style, Extra Instructions, and Result
  settings and the summary window with the other engines. Hide it with the new
  **Show ChatGPT action** setting.
- `make check` now fails when an action requires an option that `Config.yaml`
  does not declare — PopClip silently hides such an action instead of erroring.

## [0.2.0] - 2026-08-03

### Added

- **Summary window** — both engines now show their result in a native floating
  `NSPanel` next to the pointer, with the standard popover material: selectable
  and scrollable text, a Copy button, resize, and Escape / ⌘W to dismiss. It
  replaces PopClip's 160-character popup.
- **Full screen** result mode — large type, drawn by the extension rather than
  by PopClip: the summary scaled up to fill the display it is shown on, above
  the menu bar, dismissed with Escape, Return, Space, or a click. This replaces
  PopClip's own Large Type, which only a `javascript file` action can open.
- `make prebuild` compiles the Swift helpers into the cache ahead of first use.

### Changed

- The Claude action moved from JavaScript to Swift (`URLSession` in place of
  `axios`). PopClip's JavaScript environment has no subprocess API, so a JS
  action cannot launch the window; the API key still arrives from the Keychain
  as `$POPCLIP_OPTION_APIKEY`. Both actions are now `shell script file` actions.
- **Claude Result** is now **Result** and applies to both engines. Its values are
  *Summary window* (default), *Full screen*, and *Copy to clipboard only*.
- The Swift sources are compiled once into
  `~/Library/Caches/io.gamov.popclip.extension.ai-summarize` and reused, keyed on
  a hash of the source. This also made the Apple Intelligence action faster
  (~1.5s warm, down from ~2s as an interpreted script).
- **Summarization prompt rewritten**, identically for both engines, after an A/B
  of four variants over 80 runs. The *concise* style now asks for a word budget
  instead of "one short paragraph", and every style is told to rewrite rather
  than reuse source sentences and to drop background and repetition.

  The old prompt did not reliably summarize on-device: it reproduced 64% of its
  output verbatim from the source, and on technical text returned 101% of the
  input length — longer than what it was given. Measured on-device, the new
  prompt cuts length to 58% of source from 86% for *concise* and verbatim copying
  to 24% from 51% for *bullets*. *TL;DR* is unchanged, which the experiment
  explains: it already carried a word cap, and that is precisely what works.

  Sentence caps were tested and rejected. "No more than 3 sentences" was violated
  in 31 of 40 runs across both engines and made on-device copying worse (64% to
  85%), the model padding with copied sentences to reach the requested shape.

### Removed

- The **Popup** and **Replace the selection** result modes, which depended on
  PopClip's built-in handlers. The window supersedes the popup; for replacing the
  selection, the summary is always staged on the clipboard, so ⌘V pastes it.
  Large Type is not lost — it is now the *Full screen* mode above.

### Requirements

- The Xcode Command Line Tools are now needed for **both** engines, not just the
  Apple Intelligence one. A missing toolchain reports how to install it.

## [0.1.0] - 2026-08-03

### Added

- **Summarize (Claude)** action calling the Anthropic Messages API, with the
  model selectable in settings (Haiku 4.5 by default) and a custom-model override.
- **Summarize (Apple Intelligence)** action running Apple's on-device Foundation
  Models on macOS 26+ — no API key, no network, no cost.
- Shared **Style** (concise / bullets / TL;DR) and **Extra Instructions**
  settings, honored by both engines.
- **Claude Result** setting: Large Type (default), popup with click-to-paste,
  copy, or replace the selection. Large Type avoids PopClip's 160-character
  popup truncation and stages the summary on the clipboard.
- API key stored via PopClip's `secret` option type, which uses the macOS Keychain.
- Settings-aware error handling: a missing or rejected API key sends the user
  straight to the extension's settings pane.
- `make check` validation of the config, both scripts, and the executable bit,
  wired into CI.

[Unreleased]: https://github.com/gAmUssA/popclip-summarize/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/gAmUssA/popclip-summarize/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/gAmUssA/popclip-summarize/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/gAmUssA/popclip-summarize/releases/tag/v0.1.0
