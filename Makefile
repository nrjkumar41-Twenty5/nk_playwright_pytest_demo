# =============================================================================
# nk_playwright_pytest_demo — Record & Play
# Run `make help` for the full list.
# =============================================================================
.DEFAULT_GOAL := help
SHELL := /bin/bash

PYTHON  := ./.venv/bin/python
PYTEST  := $(PYTHON) -m pytest
BROWSER ?= chromium
NAME    ?=
URL     ?=
BRANCH  ?=
MSG     ?=

.PHONY: help setup install browsers record-ipe record-url \
        play play-all play-headless \
        branch save submit \
        clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# --- Setup -------------------------------------------------------------------

setup: ## Full first-time setup (venv + deps + chromium)
	./scripts/setup.sh

install: ## Install/refresh Python dependencies only
	$(PYTHON) -m pip install -r requirements.txt

browsers: ## Install all three Playwright browser engines
	$(PYTHON) -m playwright install chromium firefox webkit

# --- Record & replay ---------------------------------------------------------

record-ipe: ## Record against Twenty5 IPE app (NAME=my_test)
	@test -n "$(NAME)" || { echo "Usage: make record-ipe NAME=my_test"; exit 1; }
	$(PYTHON) scripts/record_test.py $(NAME) --url https://twenty5ipe-ai-mfg.cfapps.us20.hana.ondemand.com

record-url: ## Record against any URL (NAME=my_test URL=https://...)
	@test -n "$(NAME)" || { echo "Usage: make record-url NAME=my_test URL=https://..."; exit 1; }
	@test -n "$(URL)"  || { echo "Usage: make record-url NAME=my_test URL=https://..."; exit 1; }
	$(PYTHON) scripts/record_test.py $(NAME) --url $(URL)

play: ## Replay a recorded test with visible browser (NAME=my_test)
	@test -n "$(NAME)" || { echo "Usage: make play NAME=my_test"; exit 1; }
	$(PYTEST) tests/recorded/test_$(NAME).py --headed --browser=$(BROWSER)

play-all: ## Replay all recorded tests with visible browser
	$(PYTEST) tests/recorded --headed --browser=$(BROWSER)

play-headless: ## Replay all recorded tests headless (CI-friendly)
	$(PYTEST) tests/recorded --browser=$(BROWSER)

# --- Git workflow (branch → record → save → submit PR) -----------------------

branch: ## Create your branch (BRANCH=your-name/feature-name)
	@test -n "$(BRANCH)" || { echo "Usage: make branch BRANCH=neeraj/create-estimate"; exit 1; }
	git checkout -b record/$(BRANCH)
	@echo ""
	@echo "  You are now on branch: record/$(BRANCH)"
	@echo "  Next: make record-ipe NAME=my_test"
	@echo ""

save: ## Save your recorded tests (MSG="what you recorded")
	@test -n "$(MSG)" || { echo 'Usage: make save MSG="recorded the create estimate flow"'; exit 1; }
	@CURRENT=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT" = "master" ]; then \
		echo "  ERROR: You are on master. Create a branch first:"; \
		echo "         make branch BRANCH=your-name/feature-name"; \
		exit 1; \
	fi
	git add tests/recorded/
	git commit -m "$(MSG)"
	@echo ""
	@echo "  Saved. Next: make submit"
	@echo ""

submit: ## Push your branch and create a pull request
	@CURRENT=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT" = "master" ]; then \
		echo "  ERROR: You are on master. Create a branch first:"; \
		echo "         make branch BRANCH=your-name/feature-name"; \
		exit 1; \
	fi; \
	git push -u origin HEAD; \
	echo ""; \
	if command -v gh >/dev/null 2>&1; then \
		TITLE=$$(echo "$$CURRENT" | sed 's|record/||; s|/| — |; s|-| |g'); \
		gh pr create --base master \
			--title "Recorded test: $$TITLE" \
			--body "Automated test recorded with Playwright codegen."; \
	else \
		echo "  Now open the link above in your browser to create the Pull Request."; \
		echo "  (Install GitHub CLI for one-command PRs: brew install gh && gh auth login)"; \
	fi

# --- Cleanup -----------------------------------------------------------------

clean: ## Remove caches and test artifacts
	rm -rf .pytest_cache test-results
	find . -type d -name __pycache__ -not -path "./.venv/*" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean."
