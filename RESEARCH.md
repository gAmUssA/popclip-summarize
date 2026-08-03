# Research: PopClip Extension — Summarize Selected Text with Claude Haiku (+ Apple Intelligence bonus)

> Handoff document for implementation. Researched 2026-08-03 using PopClip developer docs (popclip.app/dev),
> the pilotmoon/PopClip-Extensions repo, Anthropic API docs, and Apple Foundation Models documentation.

## 1. Goal

A PopClip extension that summarizes the currently selected text:

- **Primary engine:** Anthropic Claude via the Messages API, defaulting to the Haiku model.
- **Configurable:** API key and model must be user-configurable in the extension's settings UI.
- **Bonus:** an alternative action (or engine option) that uses Apple's native on-device AI
  (Apple Intelligence / Foundation Models) — no API key, no network, free.

---

## 2. PopClip extension architecture (what to build)

PopClip (macOS, pilotmoon) extensions come in two forms:

| Form | What it is | Limits |
|---|---|---|
| **Snippet** | Plain YAML text (≤5000 chars) starting with `#popclip`; installable by selecting the text | No external files, no shell-script packaging for older versions, no signing |
| **Package** (`.popclipext` folder / `.popclipextz` zip) | Folder with a config file + icons/source/readme | Full power; recommended here |

**Recommendation: build a package extension with a JavaScript module config (`Config.ts` or `Config.js`)**,
modeled directly on the official `OpenAIChat.popclipext` in the
[pilotmoon/PopClip-Extensions](https://github.com/pilotmoon/PopClip-Extensions) repo
(`source/OpenAIChat.popclipext/Config.ts`). That extension is the closest existing prior art —
it does exactly this pattern (options for API key + model, network call, paste/show result) against OpenAI.

Key facts about the module format (docs: popclip.app/dev/js-modules):

- `Config.js`/`Config.ts` starts with a YAML comment header (inverted-snippet syntax) defining static
  properties: `name`, `icon`, `identifier`, `description`, `popclipVersion`, `entitlements`.
- The module exports `options` and `actions` (CommonJS: `module.exports` / `exports.foo`).
- JavaScript actions that make HTTP requests need `entitlements: [network]` (enables `XMLHttpRequest`).
  PopClip bundles NPM modules — **`axios` is available** (OpenAIChat uses it).
- TypeScript is supported natively; PopClip ships a `popclip.d.ts` for types.

### Extension options (settings UI)

Option types (docs: popclip.app/dev/config → "Option types"):

| Type | UI | Notes |
|---|---|---|
| `string` | text field | |
| `boolean` | checkbox | |
| `multiple` | dropdown | requires `values` array; optional `value labels` |
| `secret` | concealed text field | **stored in macOS Keychain**, not the prefs plist — use this for the API key. Syncs via iCloud Keychain. May not have a default value. |
| `heading` | section heading | no value |

Proposed options array:

```ts
export const options = [
  {
    identifier: "apikey",
    label: "API Key",
    type: "secret",
    description: "Get a key from https://platform.claude.com/",
  },
  {
    identifier: "model",
    label: "Model",
    type: "multiple",
    defaultValue: "claude-haiku-4-5",
    values: ["claude-haiku-4-5", "claude-sonnet-5", "claude-opus-5"],
  },
  {
    identifier: "customModel",
    label: "Custom Model",
    type: "string",
    description: "Optional. Overrides 'Model' — any Anthropic model ID.",
  },
  {
    identifier: "style",
    label: "Summary Style",
    type: "multiple",
    defaultValue: "concise",
    values: ["concise", "bullets", "tldr"],
  },
] as const;
```

In JS actions, options are available as `options.apikey`, `options.model`, etc.
(In shell-script actions they arrive as env vars `POPCLIP_OPTION_<IDENTIFIER>`, uppercased.)

### Showing the result

- JS API: `popclip.showText(text)` (show in PopClip bar — supports "preview" style),
  `popclip.copyText(text)`, `popclip.pasteText(text)`. You can combine (e.g. copy AND show).
- Shell script / declarative equivalent: `after: show-result | preview-result | copy-result | paste-result`
  (only ONE `after` allowed; JS can chain multiple calls instead — prefer JS for this reason).
- For a summary, a good UX: `popclip.showText(summary, { preview: true })` and also copy to clipboard;
  or make paste-vs-show configurable. OpenAIChat's pattern: primary action pastes/appends, option to copy.

### Error handling (important for API-key UX)

- JS: throw `popclip.settingsRequiredError()` when the API key is empty → PopClip opens the extension's
  settings UI. There is also `popclip.signInRequiredError()`.
- Shell scripts: exit code `0` = success, non-zero = failure (shaking X), **exit code `2` = "settings
  error" → PopClip pops up the extension settings UI**.
- Handle HTTP 401 (bad key) by rethrowing as `settingsRequiredError()`; show a readable message for
  429/5xx.

---

## 3. Claude API integration (primary engine)

Everything goes through `POST https://api.anthropic.com/v1/messages`.

**Required headers:**

```
Content-Type: application/json
x-api-key: <user's key>
anthropic-version: 2023-06-01
```

**Request body (summarization, single call):**

```json
{
  "model": "claude-haiku-4-5",
  "max_tokens": 1024,
  "system": "You are a summarization assistant. Summarize the user's text concisely. Reply with only the summary, no preamble.",
  "messages": [
    { "role": "user", "content": "<POPCLIP SELECTED TEXT>" }
  ]
}
```

**Response:** `content` is an array of blocks; take blocks with `"type": "text"` and join their `.text`.
Check `stop_reason` (`end_turn` normal; `max_tokens` = truncated). Usage in `usage.input_tokens` /
`usage.output_tokens`.

**Current model IDs & pricing (verified against the claude-api skill, June 2026 cache):**

| Model | ID | Context | Input $/MTok | Output $/MTok | Notes |
|---|---|---|---|---|---|
| Claude Haiku 4.5 | `claude-haiku-4-5` | 200K | $1.00 | $5.00 | **Default** — fastest/cheapest, ideal for summarization |
| Claude Sonnet 5 | `claude-sonnet-5` | 1M | $3.00 | $15.00 | Higher quality option |
| Claude Opus 5 | `claude-opus-5` | 1M | $5.00 | $25.00 | Top quality option |

Implementation notes:

- **Do not hardcode the model** — read it from `options.customModel || options.model`.
- `max_tokens` of ~1024 is plenty for a summary; keep latency low.
- Haiku 4.5 still accepts `temperature` if desired, but the newest models (Opus 5 / Sonnet 5)
  **reject non-default `temperature`/`top_p`/`top_k` with a 400** — since the model is user-configurable,
  simply omit all sampling parameters.
- Also do NOT send `thinking` config — defaults are correct across all listed models.
- PopClip selection could exceed the context window only for absurdly large selections; optionally guard
  by truncating input above ~150K characters with a note, or just let the API return an error.
- Use `axios` (bundled) or `XMLHttpRequest` with `entitlements: [network]` in the header comment.

Sketch of the action:

```ts
import axios from "axios";

async function summarize(input, options) {
  if (!options.apikey) throw popclip.settingsRequiredError();
  const model = options.customModel.trim() || options.model;
  const response = await axios.post(
    "https://api.anthropic.com/v1/messages",
    {
      model,
      max_tokens: 1024,
      system: SYSTEM_PROMPTS[options.style],
      messages: [{ role: "user", content: input.text }],
    },
    {
      headers: {
        "x-api-key": options.apikey,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
    },
  );
  const summary = response.data.content
    .filter((b) => b.type === "text")
    .map((b) => b.text)
    .join("");
  popclip.copyText(summary);
  popclip.showText(summary, { preview: true });
}
```

(Wrap axios errors: 401 → `popclip.settingsRequiredError()`; other → rethrow with message.)

---

## 4. Bonus: Apple Intelligence (native on-device) integration

Apple's **Foundation Models framework** (macOS 26 "Tahoe"+) exposes the on-device Apple Intelligence
LLM via Swift: `import FoundationModels`, `LanguageModelSession().respond(to: prompt)`.

Facts (verified via Axiom axiom-ai skill / Apple docs):

- **Requirements:** Apple silicon Mac, macOS 26+, Apple Intelligence enabled in System Settings,
  supported region/language. Does NOT work in VMs. No Apple entitlement is needed for the **on-device**
  model (only Private Cloud Compute is entitlement-gated) — so it works from a plain CLI Swift script,
  not just app bundles.
- The on-device model is a 3B-parameter model **explicitly optimized for summarization**, extraction,
  and classification. Context: 4,096 tokens on macOS 26, 8,192 on the 27 cycle — long selections must
  be truncated/chunked.
- Availability must be checked at runtime: `SystemLanguageModel.default.availability` with cases
  `.available` / `.unavailable(.deviceNotEligible | .appleIntelligenceNotEnabled | .modelNotReady)`.
  Map unavailable cases to readable error messages (or auto-fallback to the Claude action).

### Integration route A (recommended): Shell Script action running a Swift script

PopClip shell-script actions officially support Swift via shebang (`#!/usr/bin/env swift` — there's a
Swift hello-world in the official docs at popclip.app/dev/shell-script-actions). So the package can
contain `summarize.swift`:

```swift
#!/usr/bin/env swift
import Foundation
import FoundationModels

let text = ProcessInfo.processInfo.environment["POPCLIP_TEXT"] ?? ""

guard case .available = SystemLanguageModel.default.availability else {
    FileHandle.standardError.write("Apple Intelligence unavailable on this Mac".data(using: .utf8)!)
    exit(1)
}

let session = LanguageModelSession(instructions:
    "Summarize the user's text concisely. Reply with only the summary.")

let semaphore = DispatchSemaphore(value: 0)
Task {
    do {
        let response = try await session.respond(to: text)
        print(response.content, terminator: "")
    } catch {
        FileHandle.standardError.write("\(error)".data(using: .utf8)!)
        exit(1)
    }
    semaphore.signal()
}
semaphore.wait()
```

Caveats for the implementer:

- `swift` script invocation JIT-compiles on each run (~1–3 s overhead on first run). If too slow,
  precompile to a small binary at install time or ship a compiled helper (a package extension can
  contain arbitrary files). Start with the script; optimize only if needed.
- Gate the whole action with `macos version: '26.0'` in the config so it doesn't appear on older systems.
- Requires Xcode Command Line Tools / macOS SDK with FoundationModels present for `#!/usr/bin/env swift`.
  If that's a concern, route B avoids it entirely.
- Handle guardrail refusals (`LanguageModelError.guardrailViolation`) and context overflow
  (`.contextSizeExceeded` — pre-truncate input to ~3,000 words) gracefully.

### Integration route B (zero-code fallback): Shortcuts action

macOS 26 Shortcuts has a **"Use Model"** action that runs the on-device Apple Intelligence model
(user-selectable: On-Device / Private Cloud Compute / ChatGPT). PopClip natively supports Shortcut
actions (`shortcut name: <name>`). So an alternative/companion action:

1. Ship (or document) a Shortcut "Summarize with Apple Intelligence" that takes Shortcut Input →
   Use Model (On-Device) with a summarize prompt → returns text.
2. PopClip action: `{ name: Summarize (Apple AI), shortcut name: Summarize with Apple Intelligence, macos version: '26.0' }`.
   PopClip pastes/shows the Shortcut's returned output.

This requires zero Swift and no dev tooling, but requires the user to install the Shortcut once.
Recommend implementing route A as the packaged action and documenting route B in the README as
an alternative.

### Engine selection UX

Two reasonable designs — implementer's choice:

1. **Two actions in one extension** (recommended): "Summarize (Claude)" and "Summarize (Apple AI)".
   PopClip shows both icons; each action can have its own `requirements`/`macos version`.
2. One action + an `engine` option (`multiple`: claude / apple). Simpler bar, but hides capability.

Note: a JavaScript action **cannot** call Foundation Models directly (JS engine has no bridge);
that's why the Apple AI path is a shell-script (Swift) or Shortcut action, while the Claude path is JS.
A single package extension can mix action types via the `actions` array.

---

## 5. Proposed package layout

```
ClaudeSummarize.popclipext/
├── Config.ts            # YAML header + options + Claude JS action (entitlements: [network])
├── summarize.swift      # Apple Intelligence shell-script action (macos version: '26.0')
├── claude-icon.svg      # icon for the Claude action (or use `icon: symbol:sparkles` / text icon)
├── apple-icon.svg       # or `icon: symbol:apple.intelligence`
└── README.md            # setup: API key, Apple Intelligence requirements, optional Shortcut
```

Config header essentials:

```
// #popclip
// name: AI Summarize
// identifier: io.gamov.popclip.extension.summarize
// description: Summarize selected text with Claude or Apple Intelligence.
// popclipVersion: 4586
// entitlements: [network]
```

- `popclipVersion: 4586`+ needed for current JS/module features (matches what OpenAIChat pins).
- The `secret` option type requires PopClip build ≥4481 (Mar 2024) — covered by the above pin.
- Unsigned extensions: user sees a warning on install; secrets in unsigned extensions live in a
  separate keychain keyspace from signed ones. Fine for personal use; signing is optional
  (via pilotmoon if ever distributed).

## 6. Implementation plan (for Claude Code)

1. Scaffold `ClaudeSummarize.popclipext` folder with `Config.ts` (copy structure from
   OpenAIChat.popclipext as reference — https://github.com/pilotmoon/PopClip-Extensions/blob/master/source/OpenAIChat.popclipext/Config.ts).
2. Implement options (apikey secret, model multiple + customModel, style) and the Claude action
   with axios; error mapping (empty key / 401 → settingsRequiredError, readable failures otherwise).
3. Implement `summarize.swift` shell-script action with availability check + input truncation;
   wire it as a second entry in `actions` with `macos version: '26.0'`.
4. Result UX: copy summary to clipboard + `showText(..., {preview: true})` for Claude action;
   `after: show-result` (or `preview-result`) for the Swift action.
5. Test: double-click the `.popclipext` folder to install; iterate. PopClip reloads on reinstall.
   Test error paths: no API key, bad key, Apple Intelligence disabled, huge selection.
6. Write README with setup instructions + the optional Shortcuts recipe.

## 7. Key references

- PopClip dev reference: https://www.popclip.app/dev
- Config / options spec: https://www.popclip.app/dev/config
- JS actions & environment: https://www.popclip.app/dev/js-actions , https://www.popclip.app/dev/js-environment
- Module extensions: https://www.popclip.app/dev/js-modules
- Shell script actions (incl. Swift example, exit codes): https://www.popclip.app/dev/shell-script-actions
- Snippets format: https://www.popclip.app/dev/snippets
- Prior art (OpenAI chat ext): https://github.com/pilotmoon/PopClip-Extensions/blob/master/source/OpenAIChat.popclipext/Config.ts
- Anthropic Messages API: https://platform.claude.com/docs/en/api (models: https://platform.claude.com/docs/en/about-claude/models/overview)
- Apple: Use Apple Intelligence in Shortcuts on Mac: https://support.apple.com/guide/mac-help/mchl91750563/mac
- Apple Foundation Models framework (WWDC25): https://developer.apple.com/documentation/foundationmodels
