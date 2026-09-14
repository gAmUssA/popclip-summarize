#!/bin/bash
#
# PopClip action: summarize the selection with Grok, then present the result.
#
set -euo pipefail

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "${EXT_DIR}/lib.sh"

model="${POPCLIP_OPTION_XAICUSTOMMODEL:-}"
[[ -n "$model" ]] || model="${POPCLIP_OPTION_XAIMODEL:-grok-4.3}"

# Kept as separate assignments: a failing command substitution nested in an
# argument would not trip `set -e`, and the engine would run with no binary.
engine="$(build_cached "${EXT_DIR}/responses-summarize.swift")"
summary="$(run_engine "$engine" --provider xai)"
deliver "Grok · ${model}" "$summary"
