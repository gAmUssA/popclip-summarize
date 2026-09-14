#!/bin/bash
#
# PopClip action: summarize the selection with ChatGPT, then present the result.
#
set -euo pipefail

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "${EXT_DIR}/lib.sh"

model="${POPCLIP_OPTION_OPENAICUSTOMMODEL:-}"
[[ -n "$model" ]] || model="${POPCLIP_OPTION_OPENAIMODEL:-gpt-5.6-luna}"

# Kept as separate assignments: a failing command substitution nested in an
# argument would not trip `set -e`, and the engine would run with no binary.
engine="$(build_cached "${EXT_DIR}/openai-summarize.swift")"
summary="$(run_engine "$engine")"
deliver "ChatGPT · ${model}" "$summary"
