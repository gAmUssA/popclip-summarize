#!/bin/bash
#
# PopClip action: summarize the selection with OpenAI, then present the result.
#
set -euo pipefail

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "${EXT_DIR}/lib.sh"

# Experimental: summarize through the user's own signed-in Codex CLI instead of
# the API. Opt-in via the Backend setting; the API path below is the default.
if [[ "${POPCLIP_OPTION_OPENAIBACKEND:-api}" == "codex" ]]; then
    cli_engine="$(build_cached "${EXT_DIR}/cli-summarize.swift")"
    summary="$(run_engine "$cli_engine" "" --cli codex)"
    deliver "Codex" "$summary"
    exit 0
fi

model="${POPCLIP_OPTION_OPENAICUSTOMMODEL:-}"
[[ -n "$model" ]] || model="${POPCLIP_OPTION_OPENAIMODEL:-gpt-5.6-luna}"

# Kept as separate assignments: a failing command substitution nested in an
# argument would not trip `set -e`, and the engine would run with no binary.
engine="$(build_cached "${EXT_DIR}/responses-summarize.swift")"
summary="$(run_engine "$engine" "OPENAIKEY OPENAIMODEL OPENAICUSTOMMODEL" --provider openai)"
deliver "OpenAI · ${model}" "$summary"
