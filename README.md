# Record & Play — Playwright Test Recorder

Record browser tests by pointing and clicking, then replay them reliably.

## Quick start

```bash
make setup                              # one-time install
make branch BRANCH=neeraj/create-estimate  # create your branch
make record-ipe NAME=create_estimate    # record on the IPE app
make play NAME=create_estimate          # replay it to verify
make save MSG="recorded create estimate flow"  # commit it
make submit                             # push and open a pull request
```

## Prerequisites (new Mac)

1. Install Xcode CLI tools: `xcode-select --install`
2. Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
3. Install Python: `brew install python@3.12`
4. Install GitHub CLI: `brew install gh` then `gh auth login`
5. Clone this repo and run `make setup`

## The workflow: branch → record → play → save → submit

Every recorded test goes on its own branch, then gets merged via a pull request.

### Branch naming

```
record/<your-first-name>/<short-description>
```

Examples: `record/neeraj/create-estimate`, `record/priya/search-projects`, `record/amit/edit-wbs-line`

### Step by step

| Step | Command | What it does |
|------|---------|-------------|
| 1 | `make branch BRANCH=neeraj/create-estimate` | Create and switch to your branch |
| 2 | `make record-ipe NAME=create_estimate` | Open the IPE app recorder |
| 3 | `make play NAME=create_estimate` | Replay to confirm it works |
| 4 | `make save MSG="recorded create estimate flow"` | Commit the test file |
| 5 | `make submit` | Push branch and open a pull request |

### PR naming

Pull requests are auto-titled: **"Recorded test: neeraj — create estimate"** (derived from your branch name). No manual title needed.

## All commands

| Command | What it does |
|---------|-------------|
| **Setup** | |
| `make setup` | Install Python venv, dependencies, and Chromium |
| **Record & replay** | |
| `make record-ipe NAME=xxx` | Record a test against the IPE app |
| `make record-url NAME=xxx URL=...` | Record against any website |
| `make play NAME=xxx` | Replay one test with a visible browser |
| `make play-all` | Replay all recorded tests |
| `make play-headless` | Replay without opening a browser (CI) |
| **Git workflow** | |
| `make branch BRANCH=name/feature` | Create your branch |
| `make save MSG="..."` | Commit your recorded tests |
| `make submit` | Push and create a pull request |
| **Cleanup** | |
| `make clean` | Remove caches |
