EXT     := AISummarize.popclipext
DIST    := dist
PACKAGE := $(DIST)/AISummarize.popclipextz

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

.PHONY: package
package: check ## Build a distributable .popclipextz
	@mkdir -p $(DIST)
	@rm -f $(PACKAGE)
	@cd . && zip -r -q -X $(PACKAGE) $(EXT) -x '*.DS_Store'
	@echo "==> built $(PACKAGE)"

.PHONY: clean
clean: ## Remove build artifacts
	@rm -rf $(DIST) .tmp
	@echo "==> cleaned"
