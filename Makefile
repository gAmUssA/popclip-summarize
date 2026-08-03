EXT     := AISummarize.popclipext
DIST    := dist

# Version comes from the git tag (v1.2.3 -> 1.2.3). Untagged builds get the
# short commit sha so a local package is never mistaken for a release.
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null | sed 's/^v//' || echo dev)
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
	@echo "==> claude.js is valid JavaScript"
	@mkdir -p .tmp && cp $(EXT)/claude.js .tmp/claude-check.mjs
	@node --check .tmp/claude-check.mjs && rm -rf .tmp
	@echo "==> apple-intelligence.swift parses"
	@swiftc -parse $(EXT)/apple-intelligence.swift
	@echo "==> apple-intelligence.swift is executable with a shebang"
	@test -x $(EXT)/apple-intelligence.swift \
		|| (echo "    FAIL: missing executable bit — run: chmod +x $(EXT)/apple-intelligence.swift" && exit 1)
	@head -1 $(EXT)/apple-intelligence.swift | grep -q '^#!' \
		|| (echo "    FAIL: missing shebang line" && exit 1)
	@echo "==> all checks passed"

.PHONY: check-full
check-full: check ## Also typecheck Swift and run a live on-device smoke test (macOS 26+)
	@echo "==> Swift typecheck (needs the macOS 26 SDK)"
	@swiftc -typecheck $(EXT)/apple-intelligence.swift
	@echo "==> on-device summarization smoke test"
	@POPCLIP_TEXT="PopClip is a macOS utility that shows a popup bar of actions whenever you select text. It is extensible through small packages that can run JavaScript, shell scripts, or AppleScript." \
		POPCLIP_OPTION_STYLE=tldr \
		$(EXT)/apple-intelligence.swift && echo "" && echo "==> smoke test passed"

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
	@git diff --quiet || (echo "working tree is dirty — commit first" && exit 1)
	@grep -q "^## \[$(V)\]" CHANGELOG.md \
		|| (echo "CHANGELOG.md has no '## [$(V)]' section — add it first" && exit 1)
	@git tag -a "v$(V)" -m "v$(V)"
	@git push origin "v$(V)"
	@echo "==> pushed tag v$(V); GitHub Actions will publish the release"

.PHONY: clean
clean: ## Remove build artifacts
	@rm -rf $(DIST) .tmp
	@echo "==> cleaned"
