#!/usr/bin/env bash
# =============================================================================
# One-time setup: virtualenv, Python dependencies, Playwright browsers.
# =============================================================================
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# ---------------------------------------------------------------------------
# Detect OS
# ---------------------------------------------------------------------------
IS_WINDOWS=false
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=true ;;
esac

# ---------------------------------------------------------------------------
# Prerequisite checks — tell the user exactly what's missing and how to fix it
# ---------------------------------------------------------------------------
MISSING=()

if [[ "$IS_WINDOWS" == "false" ]]; then
  # macOS / Linux checks
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if ! xcode-select -p &>/dev/null; then
      MISSING+=("  Xcode Command Line Tools  →  xcode-select --install")
    fi
    if ! command -v brew &>/dev/null; then
      MISSING+=("  Homebrew                   →  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
    fi
  fi

  if ! command -v python3 &>/dev/null; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      MISSING+=("  Python 3                   →  brew install python@3.12")
    else
      MISSING+=("  Python 3                   →  sudo apt install python3 (or your package manager)")
    fi
  fi
else
  # Windows (Git Bash) checks
  if ! command -v python &>/dev/null && ! command -v python3 &>/dev/null; then
    MISSING+=("  Python 3                   →  Run windows-setup.bat or install from python.org")
  fi
fi

if ! command -v git &>/dev/null; then
  MISSING+=("  Git                        →  installed with Xcode Command Line Tools (Mac) or git-scm.com (Windows)")
fi

if ! command -v gh &>/dev/null; then
  if [[ "$IS_WINDOWS" == "true" ]]; then
    MISSING+=("  GitHub CLI (gh)            →  choco install gh  then  gh auth login")
  else
    MISSING+=("  GitHub CLI (gh)            →  brew install gh  then  gh auth login")
  fi
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

# ---------------------------------------------------------------------------
# Detect Python binary name (python3 on Mac/Linux, python on Windows)
# ---------------------------------------------------------------------------
if [[ "$IS_WINDOWS" == "true" ]]; then
  PYTHON_BIN="${PYTHON_BIN:-python}"
else
  PYTHON_BIN="${PYTHON_BIN:-python3}"
fi

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

# ---------------------------------------------------------------------------
# Venv Python path differs by OS
# ---------------------------------------------------------------------------
if [[ "$IS_WINDOWS" == "true" ]]; then
  VENV_PYTHON="./.venv/Scripts/python.exe"
else
  VENV_PYTHON="./.venv/bin/python"
fi

echo "==> Installing Python dependencies"
"$VENV_PYTHON" -m pip install --upgrade pip --quiet
"$VENV_PYTHON" -m pip install -r requirements.txt

echo "==> Installing Playwright Chromium browser"
"$VENV_PYTHON" -m playwright install chromium

mkdir -p tests/recorded

cat <<'EOF'

Setup complete. You're ready to record and play tests:

    make record-ipe NAME=my_first_test   # record on IPE
    make play NAME=my_first_test         # replay it

EOF
