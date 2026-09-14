# lib.sh — shared plumbing for the action wrappers. Sourced, never run.
#
# PopClip's own result handlers can't draw a selectable, resizable panel, so the
# result window is a small AppKit program we compile on first use and launch
# detached.

CACHE_DIR="${HOME}/Library/Caches/io.gamov.popclip.extension.ai-summarize"

# The environment every child process starts from. PopClip hands the action
# every option as $POPCLIP_OPTION_* — including all three providers' API keys —
# and children inherit all of it by default. Children get this instead, plus
# only what each one needs.
BASE_ENV=(
    "HOME=${HOME}"
    "TMPDIR=${TMPDIR:-/tmp}"
    "PATH=/usr/bin:/bin:/usr/sbin:/sbin"
    "LANG=${LANG:-en_US.UTF-8}"
)
# Honor a toolchain the user selected per-process rather than with xcode-select.
[[ -z "${DEVELOPER_DIR:-}" ]] || BASE_ENV+=("DEVELOPER_DIR=${DEVELOPER_DIR}")

# Compile a Swift source into a cached binary, rebuilding only when something
# that affects the build changes. Prints the binary's path.
#
# Running the sources through `swift` on every invocation would re-parse and
# re-typecheck AppKit and FoundationModels each time, adding seconds to every
# summary. The cache key covers the source, the compiler (path and timestamp, so
# an Xcode or Command Line Tools update rebuilds), and the OS release and CPU —
# a helper built before an OS upgrade may have compiled without FoundationModels.
# Each key gets its own file, so concurrent runs and different extension
# versions never overwrite each other's binary mid-use.
build_cached() {
    local source="$1"
    local name swiftc key binary scratch old
    # Absolute paths throughout: PopClip does not promise the action a login
    # shell's PATH, and a summary failing on a missing `cut` would be baffling.
    name="$(/usr/bin/basename "$source" .swift)"

    # /usr/bin/swiftc is a shim that exists even with no toolchain behind it, so
    # its presence proves nothing — ask xcode-select whether one is installed.
    if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
        echo "AI Summarize needs the Xcode Command Line Tools. Install them with: xcode-select --install" >&2
        exit 1
    fi
    if ! swiftc="$(/usr/bin/env -i "${BASE_ENV[@]}" /usr/bin/xcrun --find swiftc 2>/dev/null)"; then
        echo "The selected developer tools have no Swift compiler. Reinstall them with: xcode-select --install" >&2
        exit 1
    fi

    key="$(
        {
            /usr/bin/shasum -a 256 "$source"
            printf '%s\n' "$swiftc" "$(/usr/bin/stat -f %m "$swiftc")" "$(/usr/bin/uname -rm)"
        } | /usr/bin/shasum -a 256 | /usr/bin/cut -c 1-16
    )"
    binary="${CACHE_DIR}/${name}-${key}"

    if [[ -x "$binary" ]]; then
        printf '%s' "$binary"
        return 0
    fi

    # Private: the cache holds executables that later run with your privileges.
    /bin/mkdir -p "$CACHE_DIR"
    /bin/chmod 700 "$CACHE_DIR"
    scratch="${binary}.$$.tmp"
    # Through the /usr/bin shim, not "$swiftc": the shim is what supplies the SDK.
    if ! /usr/bin/env -i "${BASE_ENV[@]}" /usr/bin/swiftc -O -o "$scratch" "$source" \
        2>"${CACHE_DIR}/${name}.build.log"; then
        /bin/rm -f "$scratch"
        echo "Could not build the ${name} helper. Details: ${CACHE_DIR}/${name}.build.log" >&2
        exit 1
    fi
    # Publish with a rename, which is atomic, so no run ever sees a half-written
    # binary. Then drop this helper's older builds, including the unkeyed ones
    # earlier versions wrote. Another run's in-progress `.tmp` is left alone.
    /bin/mv -f "$scratch" "$binary"
    for old in "${CACHE_DIR}/${name}" "${CACHE_DIR}/${name}.hash" "${CACHE_DIR}/${name}"-*; do
        [[ "$old" == "$binary" || "$old" == *.tmp || ! -e "$old" ]] || /bin/rm -f "$old"
    done
    printf '%s' "$binary"
}

# Run a summarization engine and print its summary, preserving its exit status
# so PopClip still sees exit code 2 (open settings) and the stderr message.
#
#   run_engine <binary> "<OPTION IDS>" [engine arguments...]
#
# The engine sees the selection, the settings every engine shares, and only the
# options named in the second argument — its own provider's key and model — so
# one provider's engine never holds another provider's key.
run_engine() {
    local binary="$1" own_options="$2" output status id
    shift 2
    local -a engine_env=("${BASE_ENV[@]}" "POPCLIP_TEXT=${POPCLIP_TEXT:-}")
    for id in STYLE EXTRA $own_options; do
        local var="POPCLIP_OPTION_${id}"
        [[ -z "${!var+set}" ]] || engine_env+=("${var}=${!var}")
    done
    [[ -z "${AI_SUMMARIZE_TEST_API_URL:-}" ]] || engine_env+=("AI_SUMMARIZE_TEST_API_URL=${AI_SUMMARIZE_TEST_API_URL}")
    set +e
    output="$(/usr/bin/env -i "${engine_env[@]}" "$binary" "$@")"
    status=$?
    set -e
    [[ $status -eq 0 ]] || exit $status
    printf '%s' "$output"
}

# Show the summary according to the Result setting.
deliver() {
    local title="$1" summary="$2"
    local mode="${POPCLIP_OPTION_OUTPUT:-window}"

    # Stage the summary on the clipboard whichever mode is set. For the two
    # window modes this mirrors what Large Type used to do: dismiss it and ⌘V
    # still works.
    printf '%s' "$summary" | /usr/bin/pbcopy

    local viewer_style
    case "$mode" in
        window) viewer_style=panel ;;
        fullscreen) viewer_style=fullscreen ;;
        *) return 0 ;;  # copy-only
    esac

    local viewer payload ready log pid
    viewer="$(build_cached "${EXT_DIR}/summary-window.swift")"
    payload="$(/usr/bin/mktemp "${TMPDIR:-/tmp}/ai-summarize.XXXXXX")"
    ready="$(/usr/bin/mktemp -u "${TMPDIR:-/tmp}/ai-summarize-ready.XXXXXX")"
    log="${CACHE_DIR}/summary-window.log"
    printf '%s' "$summary" >"$payload"

    # The viewer owns an AppKit run loop and lives until the user closes it, so
    # it must outlive this action — PopClip waits on the action process. Detach
    # it, and unlink the payload as soon as stdin is open on it so nothing is
    # left in the temp directory whether or not the viewer exits cleanly.
    # It gets no PopClip values at all: the summary arrives on stdin.
    /usr/bin/env -i "${BASE_ENV[@]}" \
        SUMMARY_VIEWER="$viewer" SUMMARY_TITLE="$title" SUMMARY_PAYLOAD="$payload" \
        SUMMARY_STYLE="$viewer_style" SUMMARY_READY="$ready" \
        /usr/bin/nohup /bin/sh -c \
        'exec <"$SUMMARY_PAYLOAD"; rm -f "$SUMMARY_PAYLOAD"; exec "$SUMMARY_VIEWER" --title "$SUMMARY_TITLE" --style "$SUMMARY_STYLE" --ready "$SUMMARY_READY"' \
        >/dev/null 2>"$log" &
    pid=$!
    disown 2>/dev/null || true

    # Wait for the window to report in. Detached, the viewer can't pass an
    # error back, so a window that crashes on launch would otherwise just never
    # appear. A viewer still starting after 5 s is left alone — it is alive and
    # will show — but one that exited without signalling failed.
    local tries
    for ((tries = 0; tries < 100; tries++)); do
        if [[ -e "$ready" ]]; then
            /bin/rm -f "$ready"
            return 0
        fi
        /bin/kill -0 "$pid" 2>/dev/null || break
        /bin/sleep 0.05
    done
    if /bin/kill -0 "$pid" 2>/dev/null; then
        return 0
    fi
    /bin/rm -f "$payload" "$ready"
    echo "Couldn't open the summary window, but the summary is on the clipboard. Details: ${log}" >&2
    exit 1
}
