EXT     := AISummarize.popclipext
DIST    := dist

# The scripts PopClip launches directly, as opposed to the sourced library and
# the Swift sources, which are compiled to a cache on first use.
ACTIONS := $(EXT)/summarize-claude.sh $(EXT)/summarize-openai.sh $(EXT)/summarize-grok.sh $(EXT)/summarize-apple.sh

# Version comes from the git tag (v1.2.3 -> 1.2.3). Untagged builds get the
# short commit sha so a local package is never mistaken for a release.
#
# Capture git's output before substituting the fallback. Piping into `|| echo dev`
# would never fire: the pipeline's status is sed's, and sed succeeds on empty
# input — yielding an empty version and a file named `AISummarize-.popclipextz`.
VERSION := $(shell v=$$(git describe --tags --always --dirty 2>/dev/null); echo "$${v:-dev}" | sed 's/^v//')
PACKAGE := $(DIST)/AISummarize-$(VERSION).popclipextz

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

.PHONY: check
check: ## Validate config, scripts, and permissions (runs in CI)
	@echo "==> Config.yaml parses as YAML"
	@ruby -ryaml -e 'd = YAML.load_file("$(EXT)/Config.yaml"); \
		abort "missing name"       unless d["name"]; \
		abort "missing identifier" unless d["identifier"]; \
		abort "missing actions"    unless d["actions"].is_a?(Array) && !d["actions"].empty?; \
		puts "    #{d["actions"].length} actions, #{d["options"].length} options"'
	@echo "==> shell scripts parse"
	@for f in $(EXT)/*.sh; do bash -n "$$f" || exit 1; done
	@echo "==> Swift sources parse"
	@for f in $(EXT)/*.swift; do swiftc -parse "$$f" >/dev/null || exit 1; done
	@echo "==> engines and viewer build for the declared minimum macOS"
	@# Users compile on their own Mac, so the promise in `macos version` holds
	@# only if nothing newer sneaks in. Apple Intelligence is macOS 26 by design
	@# and gated in its wrapper before it ever compiles.
	@floor="$$(ruby -ryaml -e 'puts YAML.load_file("$(EXT)/Config.yaml")["macos version"]')"; \
	for f in $(EXT)/claude-summarize.swift $(EXT)/responses-summarize.swift $(EXT)/summary-window.swift; do \
		swiftc -typecheck -target "$$(uname -m)-apple-macos$$floor" "$$f" 2>&1 | grep -m3 error: \
			&& echo "    FAIL: $$f needs a newer macOS than $$floor" && exit 1; \
	done; echo "    macOS $$floor"
	@echo "==> action scripts are executable with a shebang"
	@# PopClip runs a `shell script file` directly, so it needs both — the
	@# wrappers are the only files it launches. lib.sh is sourced, not run.
	@for f in $(ACTIONS); do \
		test -x "$$f" \
			|| (echo "    FAIL: $$f missing executable bit — run: chmod +x $$f" && exit 1); \
		head -1 "$$f" | grep -q '^#!' \
			|| (echo "    FAIL: $$f missing shebang line" && exit 1); \
	done
	@echo "==> shell-script actions come with a shellScriptRationale"
	@# The PopClip Directory rejects a shell-script extension without one outright.
	@ruby -ryaml -e 'd = YAML.load_file("$(EXT)/Config.yaml"); \
		exit unless d["actions"].any? { |a| a["shell script file"] || a["shellScriptFile"] }; \
		r = d["shellScriptRationale"].to_s.strip; \
		abort "    FAIL: shell-script actions need a top-level shellScriptRationale (20+ characters)" if r.length < 20; \
		puts "    #{r.length} characters"'
	@echo "==> license and third-party notices ship inside the package"
	@# Directory downloads drop README files, so notices must be files of their own.
	@for f in LICENSE THIRD_PARTY_NOTICES.txt; do \
		test -s "$(EXT)/$$f" || (echo "    FAIL: $(EXT)/$$f is missing" && exit 1); \
	done
	@cmp -s LICENSE $(EXT)/LICENSE || (echo "    FAIL: $(EXT)/LICENSE differs from the root LICENSE" && exit 1)
	@for f in $(EXT)/*.svg; do \
		grep -q "$$(basename $$f)" $(EXT)/THIRD_PARTY_NOTICES.txt \
			|| (echo "    FAIL: $$f is not listed in THIRD_PARTY_NOTICES.txt" && exit 1); \
	done
	@echo "==> every action script named in Config.yaml exists"
	@ruby -ryaml -e 'YAML.load_file("$(EXT)/Config.yaml")["actions"].each { |a| \
		f = a["shell script file"] or abort "action #{a["title"]} has no shell script file"; \
		abort "missing #{f}" unless File.exist?("$(EXT)/#{f}") }'
	@echo "==> every option-<id> requirement names a declared option"
	@# PopClip does not complain about an undeclared one; the action just never shows.
	@ruby -ryaml -e 'd = YAML.load_file("$(EXT)/Config.yaml"); \
		ids = d["options"].map { |o| o["identifier"] }; \
		d["actions"].each { |a| (a["requirements"] || []).each { |r| \
			id = r[/\Aoption-([^=]+)/, 1] or next; \
			abort "action #{a["title"]} requires undeclared option #{id}" unless ids.include?(id) } }'
	@echo "==> Config, wrappers, and engines agree (options, default models, prompt)"
	@ruby scripts/check-consistency.rb
	@echo "==> all checks passed"

.PHONY: check-full
check-full: check ## Also typecheck Swift and run a live on-device smoke test (macOS 26+)
	@echo "==> Swift typecheck (needs the macOS 26 SDK)"
	@for f in $(EXT)/*.swift; do swiftc -typecheck "$$f" || exit 1; done
	@echo "==> on-device summarization smoke test, into the clipboard"
	@POPCLIP_TEXT="PopClip is a macOS utility that shows a popup bar of actions whenever you select text. It is extensible through small packages that can run JavaScript, shell scripts, or AppleScript." \
		POPCLIP_OPTION_STYLE=tldr POPCLIP_OPTION_OUTPUT=copy \
		$(EXT)/summarize-apple.sh && pbpaste && echo "" && echo "==> smoke test passed"

.PHONY: prebuild
prebuild: ## Compile the Swift helpers into the cache now, instead of on first use
	@bash -c 'set -euo pipefail; EXT_DIR="$(EXT)"; . $(EXT)/lib.sh; \
		for f in $(EXT)/*.swift; do printf "    %s -> " "$$f"; build_cached "$$f"; echo; done'
	@echo "==> helpers built"

.PHONY: install
install: check ## Install the extension into PopClip
	@open -a PopClip $(EXT)
	@echo "==> handed to PopClip — confirm the install prompt"

.PHONY: version
version: ## Print the version this build would produce
	@echo $(VERSION)

.PHONY: package
package: check ## Build a versioned, distributable .popclipextz
	@mkdir -p $(DIST)
	@rm -f $(DIST)/*.popclipextz
	@zip -r -q -X $(PACKAGE) $(EXT) -x '*.DS_Store'
	@echo "==> built $(PACKAGE)"

.PHONY: release
release: ## Tag and push a release (make release V=0.2.0)
	@test -n "$(V)" || (echo "usage: make release V=0.2.0" && exit 1)
	@echo "$(V)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$$' \
		|| (echo "V must look like 1.2.3, got '$(V)'" && exit 1)
	@# --porcelain, not `git diff --quiet`: the latter ignores staged-only and
	@# untracked files, so a release could be tagged from a tree that differs
	@# from what was committed.
	@test -z "$$(git status --porcelain)" \
		|| (echo "working tree is dirty (staged, unstaged, or untracked) — commit first" && git status --short && exit 1)
	@! git rev-parse -q --verify "refs/tags/v$(V)" >/dev/null \
		|| (echo "tag v$(V) already exists" && exit 1)
	@grep -q "^## \[$(V)\]" CHANGELOG.md \
		|| (echo "CHANGELOG.md has no '## [$(V)]' section — add it first" && exit 1)
	@test "$$(ruby scripts/config-version.rb)" = "$(V)" \
		|| (echo "Config.yaml's version heading says $$(ruby scripts/config-version.rb), not $(V) — update it first" && exit 1)
	@git tag -a "v$(V)" -m "v$(V)"
	@git push origin "v$(V)"
	@echo "==> pushed tag v$(V); GitHub Actions will publish the release"

.PHONY: clean
clean: ## Remove build artifacts
	@rm -rf $(DIST) .tmp
	@echo "==> cleaned"
