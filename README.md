# Record & Play — Playwright Test Recorder

Record browser tests by pointing and clicking, then replay them reliably.

## Quick start

```bash
make setup                              # one-time install
make record-ipe NAME=create_estimate    # record on the IPE app
make play NAME=create_estimate          # replay it
```

## Prerequisites (new Mac)

1. Install Xcode CLI tools: `xcode-select --install`
2. Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Install Python: `brew install python@3.12`
4. Clone this repo and run `make setup`

## Commands

| Command | What it does |
|---------|-------------|
| `make setup` | Install Python venv, dependencies, and Chromium |
| `make record-ipe NAME=xxx` | Record a test against the IPE app |
| `make record-url NAME=xxx URL=...` | Record against any website |
| `make play NAME=xxx` | Replay one test with a visible browser |
| `make play-all` | Replay all recorded tests |
| `make play-headless` | Replay without opening a browser (CI) |
| `make clean` | Remove caches |
