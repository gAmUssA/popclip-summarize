---
# popclip-summarize-33ll
title: 'Decision: never extract or reuse provider OAuth tokens'
status: completed
type: task
created_at: 2026-09-14T22:22:38Z
updated_at: 2026-09-14T22:22:38Z
parent: popclip-summarize-b6e8
---

Subscription support goes only through the provider's official CLI/protocol with authentication kept inside that CLI. No reading auth files or Keychain items of other apps, no copying another app's OAuth client ID, no private/consumer endpoints, no account rotation, no silent paid fallback. Anthropic explicitly prohibits collecting/intermediating Claude.ai credentials; OpenAI and xAI have no general grant for third-party token reuse.
