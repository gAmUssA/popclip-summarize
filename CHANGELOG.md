# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/gAmUssA/popclip-summarize/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/gAmUssA/popclip-summarize/releases/tag/v0.1.0
