# =============================================================================
# nk_playwright_pytest_demo — Record & Play
# Run `make help` for the full list.
# Works on macOS, Linux, and Windows (Git Bash / choco install make).
# =============================================================================
.DEFAULT_GOAL := help

# --- Cross-platform detection ------------------------------------------------
ifeq ($(OS),Windows_NT)
    SHELL   := cmd.exe
    PYTHON  := .\.venv\Scripts\python.exe
    RMRF    := if exist "$(1)" rmdir /s /q "$(1)"
    FINDCMD := del /s /q
    PATHSEP := \\
    SETUP   := scripts\setup.bat
else
    SHELL   := /bin/bash
    PYTHON  := ./.venv/bin/python
    RMRF    = rm -rf $(1)
    PATHSEP := /
    SETUP   := ./scripts/setup.sh
endif

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
ifeq ($(OS),Windows_NT)
	@$(PYTHON) -c "import re,sys;[print(f'  {m[0]:<18} {m[1]}') for line in open('Makefile') if (m:=re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$',line))]" 2>nul || @echo Run: make setup / record-ipe / play / save / submit
else
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
endif

# --- Setup -------------------------------------------------------------------

setup: ## Full first-time setup (venv + deps + chromium)
	$(SETUP)

install: ## Install/refresh Python dependencies only
	$(PYTHON) -m pip install -r requirements.txt

browsers: ## Install all three Playwright browser engines
	$(PYTHON) -m playwright install chromium firefox webkit

# --- Record & replay ---------------------------------------------------------

record-ipe: ## Record against Twenty5 IPE app (NAME=my_test)
ifeq ($(OS),Windows_NT)
	@if "$(NAME)"=="" (echo Usage: make record-ipe NAME=my_test & exit /b 1)
else
	@test -n "$(NAME)" || { echo "Usage: make record-ipe NAME=my_test"; exit 1; }
endif
	$(PYTHON) scripts/record_test.py $(NAME) --url https://twenty5ipe-ai-mfg.cfapps.us20.hana.ondemand.com

record-url: ## Record against any URL (NAME=my_test URL=https://...)
ifeq ($(OS),Windows_NT)
	@if "$(NAME)"=="" (echo Usage: make record-url NAME=my_test URL=https://... & exit /b 1)
	@if "$(URL)"=="" (echo Usage: make record-url NAME=my_test URL=https://... & exit /b 1)
else
	@test -n "$(NAME)" || { echo "Usage: make record-url NAME=my_test URL=https://..."; exit 1; }
	@test -n "$(URL)"  || { echo "Usage: make record-url NAME=my_test URL=https://..."; exit 1; }
endif
	$(PYTHON) scripts/record_test.py $(NAME) --url $(URL)

play: ## Replay a recorded test with visible browser (NAME=my_test)
ifeq ($(OS),Windows_NT)
	@if "$(NAME)"=="" (echo Usage: make play NAME=my_test & exit /b 1)
else
	@test -n "$(NAME)" || { echo "Usage: make play NAME=my_test"; exit 1; }
endif
	$(PYTEST) tests/recorded/test_$(NAME).py --headed --browser=$(BROWSER)

play-all: ## Replay all recorded tests with visible browser
	$(PYTEST) tests/recorded --headed --browser=$(BROWSER)

play-headless: ## Replay all recorded tests headless (CI-friendly)
	$(PYTEST) tests/recorded --browser=$(BROWSER)

# --- Git workflow (branch → record → save → submit PR) -----------------------

branch: ## Create your branch (BRANCH=your-name/feature-name)
ifeq ($(OS),Windows_NT)
	@if "$(BRANCH)"=="" (echo Usage: make branch BRANCH=neeraj/create-estimate & exit /b 1)
	git checkout -b record/$(BRANCH)
	@echo.
	@echo   You are now on branch: record/$(BRANCH)
	@echo   Next: make record-ipe NAME=my_test
	@echo.
else
	@test -n "$(BRANCH)" || { echo "Usage: make branch BRANCH=neeraj/create-estimate"; exit 1; }
	git checkout -b record/$(BRANCH)
	@echo ""
	@echo "  You are now on branch: record/$(BRANCH)"
	@echo "  Next: make record-ipe NAME=my_test"
	@echo ""
endif

save: ## Save your recorded tests (MSG="what you recorded")
ifeq ($(OS),Windows_NT)
	@if "$(MSG)"=="" (echo Usage: make save MSG="recorded the create estimate flow" & exit /b 1)
	@for /f %%b in ('git rev-parse --abbrev-ref HEAD') do @if "%%b"=="master" (echo   ERROR: You are on master. Create a branch first: make branch BRANCH=your-name/feature-name & exit /b 1)
else
	@test -n "$(MSG)" || { echo 'Usage: make save MSG="recorded the create estimate flow"'; exit 1; }
	@CURRENT=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT" = "master" ]; then \
		echo "  ERROR: You are on master. Create a branch first:"; \
		echo "         make branch BRANCH=your-name/feature-name"; \
		exit 1; \
	fi
endif
	git add tests/recorded/
	git commit -m "$(MSG)"
	@echo.
	@echo   Saved. Next: make submit
	@echo.

submit: ## Push your branch and create a pull request
ifeq ($(OS),Windows_NT)
	@for /f %%b in ('git rev-parse --abbrev-ref HEAD') do @if "%%b"=="master" (echo   ERROR: You are on master. Create a branch first: make branch BRANCH=your-name/feature-name & exit /b 1)
	git push -u origin HEAD
	@where gh >nul 2>&1 && ( \
		$(PYTHON) -c "import subprocess; b=subprocess.check_output(['git','rev-parse','--abbrev-ref','HEAD']).decode().strip().replace('record/','').replace('/',' - ').replace('-',' '); subprocess.run(['gh','pr','create','--base','master','--title','Recorded test: '+b,'--body','Automated test recorded with Playwright codegen.'])" \
	) || ( \
		echo. & echo   Now open the link above in your browser to create the Pull Request. \
	)
else
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
endif

# --- Cleanup -----------------------------------------------------------------

clean: ## Remove caches and test artifacts
ifeq ($(OS),Windows_NT)
	@if exist .pytest_cache rmdir /s /q .pytest_cache
	@if exist test-results rmdir /s /q test-results
	@for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d" 2>nul
else
	rm -rf .pytest_cache test-results
	find . -type d -name __pycache__ -not -path "./.venv/*" -exec rm -rf {} + 2>/dev/null || true
endif
	@echo "Clean."
