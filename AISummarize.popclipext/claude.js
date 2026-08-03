// claude.js — Summarize the selected text with Anthropic's Messages API.
//
// PopClip runs this file as a JavaScript action. The selected text arrives as
// `popclip.input.text` and the extension settings as `popclip.options.<id>`.
// Network access requires the `network` entitlement (set in Config.yaml).

const axios = require("axios");

const API_URL = "https://api.anthropic.com/v1/messages";
const API_VERSION = "2023-06-01";
const MAX_TOKENS = 1024;
const REQUEST_TIMEOUT_MS = 60000;

// Haiku 4.5 has a 200K-token context (~800K characters). Stay well inside it so
// a runaway selection fails fast and locally instead of burning a round trip.
const MAX_INPUT_CHARS = 400000;

const STYLE_INSTRUCTIONS = {
  concise: "Write a concise summary of one short paragraph.",
  bullets:
    "Summarize as 3-6 bullet points, one line each, using '- ' as the bullet marker.",
  tldr: "Write a single-sentence TL;DR of no more than 25 words.",
};

/** Build the system prompt from the user's style and extra-instruction settings. */
function buildSystemPrompt(options) {
  const parts = [
    "You are a summarization engine.",
    STYLE_INSTRUCTIONS[options.style] || STYLE_INSTRUCTIONS.concise,
    "Preserve the key facts, names, and numbers of the source text.",
    "Reply with the summary only: no preamble, no heading, no commentary, and no surrounding quotation marks.",
  ];

  const extra = (options.extra || "").trim();
  if (extra) {
    parts.push(extra);
  }

  return parts.join(" ");
}

/** Concatenate the text blocks of a Messages API response. */
function extractText(data) {
  const blocks = (data && data.content) || [];
  return blocks
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("")
    .trim();
}

/**
 * Turn an axios failure into a message worth showing a human.
 * Messages beginning with "settings error" make PopClip open the settings UI.
 */
function describeError(error) {
  const response = error && error.response;

  if (!response) {
    return `Could not reach the Anthropic API. Check your internet connection. (${
      (error && error.message) || "unknown error"
    })`;
  }

  const status = response.status;
  const apiMessage =
    (response.data && response.data.error && response.data.error.message) || "";

  if (status === 401 || status === 403) {
    return `Settings error: Anthropic rejected the API key (HTTP ${status}). ${apiMessage}`;
  }
  if (status === 404) {
    return `Settings error: unknown model. Check the Model / Custom Model setting. ${apiMessage}`;
  }
  if (status === 429) {
    return "Rate limited by Anthropic. Wait a moment and try again.";
  }
  if (status >= 500) {
    return `Anthropic is having trouble (HTTP ${status}). Try again shortly.`;
  }
  return `Anthropic API error (HTTP ${status}). ${apiMessage}`.trim();
}

/** Deliver the summary according to the user's "Claude Result" setting. */
function deliver(summary, mode) {
  switch (mode) {
    case "copy":
      popclip.copyText(summary);
      break;
    case "paste":
      popclip.pasteText(summary);
      break;
    case "preview":
      // Compact popup with a click-to-paste button. PopClip truncates the
      // displayed text at 160 characters; the paste button still pastes it all.
      popclip.showText(summary, { preview: true });
      break;
    case "large":
    default:
      // Large Type: full screen, nothing truncated, easiest to read. It has no
      // paste button, so stage the summary on the clipboard silently — the user
      // can paste it after dismissing the overlay.
      popclip.copyText(summary, { notify: false });
      popclip.showText(summary, { style: "large" });
      break;
  }
}

// --- main ------------------------------------------------------------------

const options = popclip.options;
const apiKey = (options.apikey || "").trim();

if (!apiKey) {
  throw new Error(
    "Settings error: add your Anthropic API key in the AI Summarize settings.",
  );
}

const text = popclip.input.text.trim();
if (!text) {
  throw new Error("There is no text to summarize.");
}
if (text.length > MAX_INPUT_CHARS) {
  throw new Error(
    `Selection is too long to summarize (${text.length} characters, limit ${MAX_INPUT_CHARS}).`,
  );
}

const model = (options.custommodel || "").trim() || options.model;

try {
  const response = await axios.post(
    API_URL,
    {
      model: model,
      max_tokens: MAX_TOKENS,
      system: buildSystemPrompt(options),
      messages: [{ role: "user", content: text }],
    },
    {
      timeout: REQUEST_TIMEOUT_MS,
      headers: {
        "content-type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": API_VERSION,
      },
    },
  );

  const summary = extractText(response.data);
  if (!summary) {
    throw new Error("Claude returned an empty summary.");
  }

  if (response.data.stop_reason === "max_tokens") {
    // The summary is usable but was cut short; say so rather than pretend.
    deliver(`${summary}\n\n[truncated at ${MAX_TOKENS} tokens]`, options.output);
  } else {
    deliver(summary, options.output);
  }
} catch (error) {
  // Re-throw our own thrown Errors untouched; translate transport/API failures.
  throw error.isAxiosError ? new Error(describeError(error)) : error;
}
