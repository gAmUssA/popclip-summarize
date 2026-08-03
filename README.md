# AI Summarize — a PopClip extension

Select text anywhere on macOS, click **Summarize**, get a summary.

Two engines, one extension:

| Action | Engine | Needs | Cost | Privacy |
|---|---|---|---|---|
| **Summarize (Claude)** | Anthropic Messages API | API key, network | ~$0.002 / summary on Haiku 4.5 | Text is sent to Anthropic |
| **Summarize (Apple Intelligence)** | On-device Foundation Models | macOS 26+, Apple silicon | Free | Nothing leaves the Mac |

Both actions honor the same **Style** and **Extra Instructions** settings, so you can
switch engines without relearning anything.

---

## Requirements

- macOS 10.15+ and [PopClip](https://www.popclip.app/) build **4586** or later.
- **Claude action:** an [Anthropic API key](https://console.anthropic.com/settings/keys).
- **Apple Intelligence action:** macOS **26** or later on Apple silicon, with
  Apple Intelligence enabled in *System Settings › Apple Intelligence & Siri*.
  On any other Mac, turn the action off in the extension settings.

## Install

**From source** (what you have here):

```sh
make install     # hands the package to PopClip, which prompts to install
```

Or double-click `AISummarize.popclipext` in Finder.

**From a release:** download the latest `.popclipextz` from
[Releases](https://github.com/gAmUssA/popclip-summarize/releases) and double-click it.

PopClip will warn that the extension is not signed — that is expected for a
self-built extension. Signing is only available to Pilotmoon.

## Configure

Open **PopClip → Extensions → AI Summarize → Settings** (the gear icon).

| Setting | Default | Notes |
|---|---|---|
| **API Key** | — | Stored in the macOS Keychain, not in preferences. Syncs via iCloud Keychain. Claude action only. |
| **Model** | `claude-haiku-4-5` | Haiku 4.5 is the fastest and cheapest; Sonnet 5 and Opus 5 are available for harder source material. |
| **Custom Model** | — | Any Anthropic model ID. Overrides **Model**. |
| **Style** | Concise paragraph | Also: bullet points, or a one-line TL;DR. Applies to both engines. |
| **Extra Instructions** | — | Appended to the prompt for both engines. e.g. `Reply in French.` |
| **Claude Result** | Large Type | Large Type (full screen), popup with click-to-paste, copy, or replace the selection. |
| **Show Apple Intelligence action** | On | Turn off to hide the second action on Macs without Apple Intelligence. |

### Reading the summary

PopClip's compact popup **truncates at 160 characters**, which cuts off most
paragraph-length summaries. So the Claude action defaults to **Large Type** —
a full-screen overlay that truncates nothing and is readable across the room.
It also copies the summary to the clipboard silently, since Large Type has no
paste button; dismiss the overlay and paste wherever you need it.

The Apple Intelligence action always uses the compact popup: PopClip gives
shell-script actions a fixed set of result handlers and none of them opens
Large Type. If you want its output fully visible, pick the **Bullet points** or
**One-line TL;DR** style — both fit inside 160 characters. Click-to-paste always
pastes the untruncated text regardless of what is shown.

## Cost

Haiku 4.5 is $1.00 per million input tokens and $5.00 per million output tokens.
Summarizing a ~1,000-word article costs roughly **$0.002** — about 500 summaries
per dollar. The Apple Intelligence action is free.

## Troubleshooting

**"Settings error: add your Anthropic API key"** — PopClip opens the settings
pane automatically. Paste a key and try again.

**"Settings error: Anthropic rejected the API key"** — the key is wrong, revoked,
or out of credit. Check it at [console.anthropic.com](https://console.anthropic.com/settings/keys).

**"Apple Intelligence is turned off"** — enable it in *System Settings › Apple
Intelligence & Siri*, then try again.

**"This Mac does not support Apple Intelligence"** — you need macOS 26+ on Apple
silicon. Turn the action off in the extension settings and use Claude instead.

**The first Apple Intelligence summary is slow (~15s), later ones are fast (~2s)** —
that is the on-device model loading into memory on first use. It stays warm afterwards.

**"Selection is too long for the on-device model"** — the on-device context window
is small (4K tokens on macOS 26). The script caps input at 6,000 characters. Use
the Claude action for long documents; Haiku 4.5 has a 200K-token window.

## How it works

```
AISummarize.popclipext/
├── Config.yaml               # extension metadata, settings, and the two actions
├── claude.js                 # JavaScript action → Anthropic Messages API
└── apple-intelligence.swift  # shell-script action → FoundationModels (on-device)
```

`Config.yaml` is a declarative PopClip config whose `actions` array mixes two
action types: a `javascript file` action for Claude and a `shell script file`
action for Apple Intelligence. JavaScript cannot reach Foundation Models, and
Swift cannot call PopClip's JS API, so each engine uses the runtime that can
actually reach it.

The Swift file runs via `#!/usr/bin/env swift` and needs its executable bit set —
PopClip executes a `shell script file` directly only when it has both a shebang
and `chmod +x`. `make check` verifies this.

Contracts worth knowing if you edit these files:

- **JS action:** reads `popclip.input.text` and `popclip.options.<identifier>`;
  delivers results by calling `popclip.showText` / `copyText` / `pasteText`.
  Throwing an `Error` whose message starts with `settings error` opens the
  settings pane.
- **Swift action:** reads `$POPCLIP_TEXT` and `$POPCLIP_OPTION_<IDENTIFIER>`
  (identifiers upper-cased); stdout is the result, stderr is the error message;
  exit `0` = success, `2` = open settings, anything else = failure.

## Development

```sh
make check        # validate YAML, JS syntax, Swift syntax, and file permissions
make check-full   # adds a Swift typecheck and a live on-device smoke test
make install      # install into PopClip
make version      # print the version this build would produce
make package      # build dist/AISummarize-<version>.popclipextz
```

`make check` runs in CI on every push. `make check-full` requires macOS 26 with
Apple Intelligence enabled, so it is a local-only target.

### Releasing

The version comes from the git tag — PopClip's config format has no extension
version field, so there is nothing to bump in `Config.yaml`. Untagged builds are
named after the short commit sha so a local package is never mistaken for a release.

```sh
make release V=0.2.0
```

That checks the working tree is clean and that `CHANGELOG.md` has a matching
`## [0.2.0]` section, then tags and pushes. Pushing the tag triggers
`.github/workflows/release.yml`, which validates, builds
`AISummarize-0.2.0.popclipextz`, and publishes a GitHub Release with that
changelog section as the notes.

Releases rather than GitHub Packages: Packages only hosts container, npm, and
Maven-style artifacts, not arbitrary zips.

## License

MIT — see [LICENSE](LICENSE).

Not affiliated with Pilotmoon Software or Anthropic.
