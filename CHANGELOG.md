# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Experimental: summarize with your ChatGPT plan.** Set **OpenAI › Backend**
  to *Codex CLI* to use the Codex CLI you've installed and signed in to with
  ChatGPT, instead of an API key. Codex runs with every tool disabled, in an
  empty temporary folder, and the extension never touches your sign-in; it only
  checks that you're signed in with ChatGPT (not an API key, which would bill
  the API). Slower than the API (about 5 seconds) and counts against your plan's
  Codex limits. Off by default.

### Fixed

- If the summary window fails to open, the action now says so (the summary is
  still on the clipboard) instead of silently showing nothing. Launch errors are
  logged next to the compiled helpers.
- Full-screen large type now scrolls when a summary is taller than the screen;
  the rest used to be cut off.

### Changed

- Declares macOS 13 as the minimum (the cloud engines need it; the README's
  10.15 claim was wrong), and `make check` verifies the engines still build for
  it.
- Adds directory search keywords.
- **The ChatGPT action is now "Summarize (OpenAI)"**, since it calls OpenAI's
  API rather than ChatGPT. Saved keys and settings carry over.
- The extension has its own original icon, instead of borrowing the Claude
  action's. The Apple Intelligence action uses an original on-device icon:
  Apple restricts the Apple logo symbol to Sign in with Apple.

## [0.5.0] - 2026-09-14

### Added

- **Automatic retries for cloud engines.** Claude, ChatGPT, and Grok retry
  network hiccups, rate limits (429), overload (529), and server errors up to
  three attempts, honoring the server's `Retry-After`, within a 45-second
  overall limit. Bad keys, unknown models, billing problems, and OpenAI's
  out-of-credit 429 are never retried. When a server asks for a long wait, the
  message says roughly how long.
- The extension settings end with a heading showing the installed version, so a
  bug report can name the build. `make release` and the release workflow refuse
  a tag that doesn't match it.
- On Intel Macs or macOS before 26, the Apple Intelligence action now says so
  immediately instead of compiling its helper first.

### Changed

- **Summaries no longer answer or obey the selected text.** The prompt now
  frames the selection as material inside `<source>` tags and forbids facts the
  source doesn't contain. On a question like "What is the capital of Australia,
  and why…?", every cloud engine used to answer it, inventing dates; all now
  describe what it asks. Selected requests ("write a haiku…") are summarized
  instead of carried out, on all four engines. Apple Intelligence still tends to
  answer direct questions.
- Clearer Claude failures: a refusal now says Claude declined (with the reason
  when given), and a non-JSON or malformed response is reported as such instead
  of "Claude returned an empty summary." ChatGPT and Grok report malformed
  responses the same way, and every cloud engine says when a provider didn't respond
  in time.
- The Apple Intelligence prompt now matches the cloud engines' exactly (it was
  missing the no-surrounding-quotes rule). `make check` now fails when option
  names, default models, or the prompt drift between Config, wrappers, and
  engines.

### Security

- **Each engine now sees only its own provider's API key.** PopClip passes every
  setting — all three API keys — to the action, and the compiler, every engine,
  and the detached summary window used to inherit all of it. Now the compiler
  and window get a minimal environment with no PopClip values, and each engine
  gets the selection, the shared settings, and its own provider's options only.
- Cloud engines refuse HTTP redirects, so neither the API key nor the selection
  can be forwarded to another host.
- The compiled-helper cache is now private to your user and rebuilds when Xcode,
  the Command Line Tools, or macOS change, not only when the extension does. A
  helper built before an OS upgrade could otherwise stay compiled without
  Apple Intelligence support.

### Packaging

- The extension now carries its own `LICENSE` and a `THIRD_PARTY_NOTICES.txt`
  (icon sources, exact modifications, trademark notice), so both survive in
  downloads that omit the README.
- The extension now includes its own user guide (`README.md`) covering setup,
  privacy — what each cloud action sends and to whom — and troubleshooting.
- `Config.yaml` declares a `shellScriptRationale` explaining why the actions are
  shell scripts (a native AppKit panel and on-device FoundationModels). Comments
  and docs no longer claim PopClip's JavaScript can't start a subprocess.

## [0.4.0] - 2026-09-14

### Added

- **Summarize (Grok)** — a fourth action backed by xAI's Responses API, with a
  Keychain-stored key, a model picker (Grok 4.3, 4.5, 4.6; 4.3 by default), a
  custom model override, and a **Show Grok action** setting. xAI's flat error
  bodies and its HTTP 400 for a bad key or unknown model open the settings pane
  like the other engines.

### Fixed

- **Apple Intelligence no longer summarizes only part of a long selection.**
  Selections over 6,000 characters used to be cut silently, so the summary
  looked complete while later text was ignored. The action now refuses them
  and suggests selecting less or using a cloud engine.
- `make release` now refuses a tree with staged-only or untracked changes
  (`git diff --quiet` missed both), a malformed version, or an existing tag.

### Changed

- The OpenAI engine is now `responses-summarize.swift --provider openai|xai`,
  shared by the ChatGPT and Grok actions.
- The Claude and ChatGPT actions use the Anthropic and OpenAI marks as their
  icons (from OpenUsage, MIT) instead of generic SF Symbols; Grok uses xAI's.

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

[Unreleased]: https://github.com/gAmUssA/popclip-summarize/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/gAmUssA/popclip-summarize/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/gAmUssA/popclip-summarize/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/gAmUssA/popclip-summarize/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/gAmUssA/popclip-summarize/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/gAmUssA/popclip-summarize/releases/tag/v0.1.0
