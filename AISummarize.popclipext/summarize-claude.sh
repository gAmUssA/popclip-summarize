#!/bin/bash
#
# PopClip action: summarize the selection with Claude, then present the result.
#
set -euo pipefail

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "${EXT_DIR}/lib.sh"

# Experimental: summarize through the user's own logged-in Claude Code instead
# of the API. Opt-in via the Backend setting; the API path below is the default.
if [[ "${POPCLIP_OPTION_CLAUDEBACKEND:-api}" == "claude-code" ]]; then
    cli_engine="$(build_cached "${EXT_DIR}/cli-summarize.swift")"
    summary="$(run_engine "$cli_engine" "MODEL CUSTOMMODEL" --cli claude)"
    deliver "Claude Code · ${POPCLIP_OPTION_CUSTOMMODEL:-${POPCLIP_OPTION_MODEL:-claude-haiku-4-5}}" "$summary"
    exit 0
fi

model="${POPCLIP_OPTION_CUSTOMMODEL:-}"
[[ -n "$model" ]] || model="${POPCLIP_OPTION_MODEL:-claude-haiku-4-5}"

# Kept as separate assignments: a failing command substitution nested in an
# argument would not trip `set -e`, and the engine would run with no binary.
engine="$(build_cached "${EXT_DIR}/claude-summarize.swift")"
summary="$(run_engine "$engine" "APIKEY MODEL CUSTOMMODEL")"
deliver "Anthropic · ${model}" "$summary"
