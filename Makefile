FORMULAS = stng cleave scan filefacts
TAP = atomdrift-project/tap
TAP_DIR = $(shell brew --repository $(TAP) 2>/dev/null)

.PHONY: test style audit upgrade reinstall verify

# Run all checks
test: style audit

# Fix style issues
style:
	brew style --fix $(TAP)

# Audit the tap
audit:
	brew audit --except=installed,token_conflicts --tap=$(TAP)

# Upgrade a formula to a new version
# Usage: make upgrade FORMULA=stng VERSION=v1.0.1
upgrade:
ifndef FORMULA
	$(error FORMULA is required. Usage: make upgrade FORMULA=stng VERSION=v1.0.1)
endif
ifndef VERSION
	$(error VERSION is required. Usage: make upgrade FORMULA=stng VERSION=v1.0.1)
endif
	@echo "Upgrading $(FORMULA) to $(VERSION)..."
	@COMMIT=$$(git ls-remote https://github.com/atomdrift-project/$(FORMULA).git "$(VERSION)^{}" 2>/dev/null | head -1 | cut -f1); \
	if [ -z "$$COMMIT" ]; then \
		echo "Trying lightweight tag..."; \
		COMMIT=$$(git ls-remote --refs https://github.com/atomdrift-project/$(FORMULA).git $(VERSION) | head -1 | cut -f1); \
	fi; \
	if [ -z "$$COMMIT" ]; then \
		echo "Error: Could not find tag $(VERSION) for $(FORMULA)"; \
		exit 1; \
	fi; \
	echo "Tag $(VERSION) -> commit $$COMMIT"; \
	sed -i '' -E "s/tag:[ ]*\"[^\"]*\"/tag:      \"$(VERSION)\"/" Formula/$(FORMULA).rb; \
	sed -i '' -E "s/revision:[ ]*\"[a-f0-9]+\"/revision: \"$$COMMIT\"/" Formula/$(FORMULA).rb
	@echo "Done. Run 'make test' to verify."

# Reinstall a formula from the local tap
# Usage: make reinstall FORMULA=stng
reinstall:
ifndef FORMULA
	$(error FORMULA is required. Usage: make reinstall FORMULA=stng)
endif
	@echo "Copying $(FORMULA) to tap..."
	@if [ -z "$(TAP_DIR)" ]; then echo "Tap not found. Run: brew tap $(TAP)"; exit 1; fi
	@cp Formula/$(FORMULA).rb "$(TAP_DIR)/Formula/"
	@echo "Reinstalling..."
	brew reinstall $(TAP)/$(FORMULA)

# Full verification: lint, install, test, uninstall for all formulas
verify:
	@echo "=== Syncing tap ==="
	@if [ -z "$(TAP_DIR)" ]; then \
		echo "Tap not found. Run: brew tap $(TAP)"; \
		exit 1; \
	fi
	@cp Formula/*.rb "$(TAP_DIR)/Formula/"
	@echo ""
	@echo "=== Linting ==="
	brew style $(TAP)
	brew audit --except=installed,token_conflicts --tap=$(TAP)
	@echo ""
	@set -e; for f in $(FORMULAS); do \
		echo "=== Installing $$f ==="; \
		brew install --build-from-source $(TAP)/$$f; \
		echo ""; \
		echo "=== Testing $$f ==="; \
		brew test $(TAP)/$$f; \
		echo ""; \
	done
	@echo "=== Uninstalling ==="
	@for f in $(FORMULAS); do \
		brew uninstall $(TAP)/$$f 2>/dev/null || true; \
	done
	@echo ""
	@echo "All formulas verified successfully."
