#!/usr/bin/env bash
# =============================================================================
# One-time setup: virtualenv, Python dependencies, Playwright browsers.
# =============================================================================
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ---------------------------------------------------------------------------
# Prerequisite checks — tell the user exactly what's missing and how to fix it
# ---------------------------------------------------------------------------
MISSING=()

if ! xcode-select -p &>/dev/null; then
  MISSING+=("  Xcode Command Line Tools  →  xcode-select --install")
fi

if ! command -v brew &>/dev/null; then
  MISSING+=("  Homebrew                   →  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
fi

if ! command -v python3 &>/dev/null; then
  MISSING+=("  Python 3                   →  brew install python@3.12")
fi

if ! command -v git &>/dev/null; then
  MISSING+=("  Git                        →  installed with Xcode Command Line Tools")
fi

if ! command -v gh &>/dev/null; then
  MISSING+=("  GitHub CLI (gh)            →  brew install gh  then  gh auth login")
fi

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo "  Some prerequisites are missing. Install them first:"
  echo ""
  for line in "${MISSING[@]}"; do
    echo "$line"
  done
  echo ""
  echo "  After installing, run 'make setup' again."
  echo ""
  exit 1
fi

PYTHON_BIN="${PYTHON_BIN:-python3}"
VERSION="$("$PYTHON_BIN" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
echo "==> Using $PYTHON_BIN (Python $VERSION)"
"$PYTHON_BIN" - <<'PY'
import sys
if sys.version_info < (3, 10):
    sys.exit("Python 3.10 or newer is required; found %s" % sys.version.split()[0])
PY

if [[ ! -d .venv ]]; then
  echo "==> Creating virtualenv at .venv"
  "$PYTHON_BIN" -m venv .venv
fi

echo "==> Installing Python dependencies"
./.venv/bin/python -m pip install --upgrade pip --quiet
./.venv/bin/python -m pip install -r requirements.txt

echo "==> Installing Playwright Chromium browser"
./.venv/bin/python -m playwright install chromium

mkdir -p tests/recorded

cat <<'EOF'

Setup complete. You're ready to record and play tests:

    make record-ipe NAME=my_first_test   # record on IPE
    make play NAME=my_first_test         # replay it

EOF
