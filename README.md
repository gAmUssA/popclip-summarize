# AI Summarize — a PopClip extension

Select text anywhere on macOS, click **Summarize**, get a summary.

Two engines, one extension:

| Action | Engine | Needs | Cost | Privacy |
|---|---|---|---|---|
| **Summarize (Claude)** | Anthropic Messages API | API key, network | ~$0.002 / summary on Haiku 4.5 | Text is sent to Anthropic |
| **Summarize (Apple Intelligence)** | On-device Foundation Models | macOS 26+, Apple silicon | Free | Nothing leaves the Mac |

Both actions honor the same **Style** and **Extra Instructions** settings and show
their result in the same native floating panel, so you can switch engines without
relearning anything.

---

## Requirements

- macOS 10.15+ and [PopClip](https://www.popclip.app/) build **4586** or later.
- The **Xcode Command Line Tools** (`xcode-select --install`). Both engines and
  the result window are Swift, compiled once into `~/Library/Caches` on first use.
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
| **Result** | Summary window | The floating panel, full-screen large type, or clipboard-only. Applies to both engines. |
| **Show Apple Intelligence action** | On | Turn off to hide the second action on Macs without Apple Intelligence. |

### Reading the summary

Neither of PopClip's built-in result handlers is much good for a paragraph of
prose: the compact popup **truncates at 160 characters**, and Large Type takes
over the whole screen. So both actions instead open a small native panel next to
the pointer — an `NSPanel` with the standard popover material, floating above
whatever app you are in.

You can select text in it, resize it, scroll it if the summary is long, hit
**Copy**, or dismiss it with **Escape**, ⌘W, or the close button. The summary is
put on the clipboard either way, so ⌘V works after the panel is gone.

**Full screen** is the large-type alternative: the summary scaled up to fill the
display, above the menu bar, dismissed with Escape, Return, Space, or a click.
The font size is fitted to the text, so a one-line TL;DR really does fill the
screen. This is drawn by the extension — PopClip's own Large Type is reachable
only from a `javascript file` action, which cannot launch a window at all.

Set **Result** to *Copy to clipboard only* if you would rather have no window at all.

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

**The first summary after installing or updating is slow** — the Swift helpers
compile into `~/Library/Caches/io.gamov.popclip.extension.ai-summarize` on first
use (~3s, once per extension update). Run `make prebuild` to get it out of the way.

**The first Apple Intelligence summary is slow (~15s), later ones are fast (~1.5s)** —
that is the on-device model loading into memory on first use. It stays warm afterwards.

**No window appears** — check that **Result** is set to *Summary window*, and that
`xcode-select -p` prints a path. Build errors are logged next to the binaries in
`~/Library/Caches/io.gamov.popclip.extension.ai-summarize/`.

**"Selection is too long for the on-device model"** — the on-device context window
is small (4K tokens on macOS 26). The script caps input at 6,000 characters. Use
the Claude action for long documents; Haiku 4.5 has a 200K-token window.

## How it works

```
AISummarize.popclipext/
├── Config.yaml               # extension metadata, settings, and the two actions
├── summarize-claude.sh       # action → build, run the Claude engine, present
├── summarize-apple.sh        # action → build, run the on-device engine, present
├── lib.sh                    # shared: build cache + result delivery
├── claude-summarize.swift    # engine → Anthropic Messages API
├── apple-intelligence.swift  # engine → FoundationModels (on-device)
└── summary-window.swift      # the result panel and large type (AppKit)
```

Both actions are `shell script file` actions. That is forced by the window:
PopClip's JavaScript environment has **no subprocess API**, so a JS action cannot
launch the panel, and PopClip's own result handlers cannot draw one. The Claude
engine was JavaScript until the window arrived; it is now Swift using
`URLSession`, and the Keychain-backed API key still reaches it as
`$POPCLIP_OPTION_APIKEY`.

Each action wrapper does three things: compile the engine and the viewer if their
sources changed, run the engine, then deliver the result. The viewer owns an
AppKit run loop and lives until you close it, so it is launched **detached** —
PopClip waits on the action process, and an attached window would hang the
extension until dismissed.

The Swift sources are compiled to `~/Library/Caches/io.gamov.popclip.extension.ai-summarize`
and reused, keyed on a SHA-256 of the source. Interpreting them with `swift` on
every invocation would re-typecheck AppKit and FoundationModels each time.
Shipping a prebuilt binary would trip Gatekeeper quarantine on download instead.

Contracts worth knowing if you edit these files:

- **Action wrapper:** PopClip runs it directly, so it needs both a shebang and
  its executable bit. `make check` verifies this.
- **Engine:** reads `$POPCLIP_TEXT` and `$POPCLIP_OPTION_<IDENTIFIER>`
  (identifiers upper-cased); stdout is the summary, stderr is the error message;
  exit `0` = success, `2` = open settings, anything else = failure. The wrapper
  passes all three through to PopClip unchanged.
- **Viewer:** body text on stdin, `--title` for the titlebar, `--style
  panel|fullscreen`. Exits when closed.

## Development

```sh
make check        # validate YAML, shell syntax, Swift syntax, and file permissions
make check-full   # adds a Swift typecheck and a live on-device smoke test
make prebuild     # compile the Swift helpers now instead of on first use
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
