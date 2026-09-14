#!/bin/bash
#
# PopClip action: summarize the selection on-device, then present the result.
#
set -euo pipefail

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
. "${EXT_DIR}/lib.sh"

# Refuse unsupported Macs before compiling anything: building the helper takes
# seconds, and it could only report the same thing afterwards.
if [[ "$(/usr/bin/uname -m)" != "arm64" ]]; then
    echo "Apple Intelligence needs a Mac with Apple silicon. Use a cloud engine instead, or turn off the Apple Intelligence action in the extension settings." >&2
    exit 1
fi
macos_major="$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d . -f 1)"
if (( macos_major < 26 )); then
    echo "Apple Intelligence summarization needs macOS 26 or later (this Mac runs $(/usr/bin/sw_vers -productVersion)). Use a cloud engine instead, or turn off the Apple Intelligence action in the extension settings." >&2
    exit 1
fi

# Kept as separate assignments: a failing command substitution nested in an
# argument would not trip `set -e`, and the engine would run with no binary.
engine="$(build_cached "${EXT_DIR}/apple-intelligence.swift")"
summary="$(run_engine "$engine" "")"
deliver "Apple Intelligence" "$summary"
