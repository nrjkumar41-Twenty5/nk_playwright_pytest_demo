#!/usr/bin/env bash
# =============================================================================
# One-time setup: virtualenv, Python dependencies, Playwright browsers.
# =============================================================================
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

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
