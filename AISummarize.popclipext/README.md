# AI Summarize

Select text anywhere, click **Summarize**, and read a short summary in a floating
panel next to the pointer. Choose Claude, OpenAI, or Grok in the cloud, or Apple
Intelligence on your Mac.

## Requirements

- The **Xcode Command Line Tools**. Install them with `xcode-select --install`.
  The extension is readable Swift source, compiled on your Mac the first time
  each action runs. No prebuilt programs are included.
- For each cloud action you use, an API key from that provider:
  - **Claude:** [Anthropic Console](https://console.anthropic.com/settings/keys)
  - **OpenAI:** [OpenAI Platform](https://platform.openai.com/api-keys). API use
    is billed separately from a ChatGPT Plus or Pro subscription.
  - **Grok:** [xAI Console](https://console.x.ai)
- For **Apple Intelligence:** macOS 26 or later on Apple silicon, with Apple
  Intelligence turned on in *System Settings › Apple Intelligence & Siri*.

Needs macOS 13 or later for the cloud actions. Tested on macOS 26.

## Actions

| Action | Runs on | Cost |
|---|---|---|
| Summarize (Claude) | Anthropic's servers | ~$0.002 per 1,000-word article on Claude Haiku 4.5 |
| Summarize (OpenAI) | OpenAI's servers | ~$0.0004 on GPT-5.6 Luna |
| Summarize (Grok) | xAI's servers | ~$0.002 on Grok 4.3 |
| Summarize (Apple Intelligence) | Your Mac | Free |

Hide the actions you don't use in the settings.

## Setup

1. Open **PopClip › Extensions › AI Summarize › Settings**.
2. Paste an API key into the section for each cloud provider you want. Keys are
   stored in your macOS Keychain.
3. Optionally pick a model, a summary **Style** (concise paragraph, bullet
   points, or a one-line TL;DR), and **Extra Instructions** such as
   `Reply in French.`
4. Select some text and click an action.

The first run of each action takes a few extra seconds while it compiles.

## The result

By default the summary opens in a floating panel. You can select text in it,
resize it, or click **Copy**. Press Escape or ⌘W to close it. Set **Result** to
*Full screen* for large type that fills the display, or to *Copy to clipboard
only* for no window at all. Every setting also puts the summary on the
clipboard.

## Privacy

- **Cloud actions** send the selected text, your Extra Instructions, the chosen
  model name, and that provider's API key to that provider only. Nothing is sent
  anywhere else, and one provider's key is never given to another provider's
  engine.
- OpenAI and Grok requests ask the provider not to store the request
  (`store: false`). Each provider's own data-retention policy still applies.
- **Apple Intelligence** runs entirely on your Mac. Nothing leaves it.
- The extension keeps no history. The summary is placed on the clipboard, and a
  temporary copy used to open the panel is deleted as soon as the panel reads it.

## Troubleshooting

- **"Add your … API key"** or **"… rejected the API key"**: PopClip opens the
  settings. Paste a valid key for that provider.
- **"… out of credit"** or **"billing problem"**: add credit in that provider's
  console.
- **"Unknown model"**: the Custom Model ID is mistyped, or your account can't use
  that model.
- **"Rate limited"** or **"having trouble"**: short hiccups are retried
  automatically. If the message still appears, wait as long as it suggests.
- **"Selection is too long for the on-device model"**: Apple Intelligence handles
  up to 6,000 characters. Select less, or use a cloud action.
- **"Apple Intelligence is turned off"**: turn it on in System Settings.
- **"AI Summarize needs the Xcode Command Line Tools"**: run
  `xcode-select --install`, then try again.
- **The first summary is slow:** each action compiles once after installing or
  updating. The first Apple Intelligence summary also waits for the on-device
  model to load (around 15 seconds).

Your installed version is shown at the bottom of the settings.

## Credits

By [Viktor Gamov](https://github.com/gAmUssA). Source, issues, and changelog:
[github.com/gAmUssA/popclip-summarize](https://github.com/gAmUssA/popclip-summarize).

Provider icons come from [OpenUsage](https://github.com/robinebers/openusage)
(MIT); see `THIRD_PARTY_NOTICES.txt`. Claude, OpenAI, Grok, and Apple
Intelligence are trademarks of their owners. They are named here only to
identify which service each action uses. Apple Intelligence is a trademark of
Apple Inc. This extension is not affiliated with, sponsored, or endorsed by
Anthropic, OpenAI, xAI, Apple, or Pilotmoon Software. The extension icon and the
on-device icon are original artwork.

MIT License. See `LICENSE`.
