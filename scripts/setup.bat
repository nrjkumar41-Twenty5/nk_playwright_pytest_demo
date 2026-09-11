@echo off
REM =============================================================================
REM  One-time setup (Windows): virtualenv, Python dependencies, Playwright.
REM  Called by: make setup
REM =============================================================================
setlocal EnableDelayedExpansion

set "PROJECT_ROOT=%~dp0.."

REM --- Prerequisite checks ---------------------------------------------------
set "FAIL=0"

where python >nul 2>&1
if %errorlevel% neq 0 (
    echo   Python not found. Run windows-setup.bat first, or install Python from python.org
    set "FAIL=1"
)

where git >nul 2>&1
if %errorlevel% neq 0 (
    echo   Git not found. Run windows-setup.bat first, or install Git from git-scm.com
    set "FAIL=1"
)

where gh >nul 2>&1
if %errorlevel% neq 0 (
    echo   WARNING: GitHub CLI (gh) not found. You won't be able to use "make submit".
    echo            Install it:  choco install gh   then   gh auth login
)

if "!FAIL!"=="1" (
    echo.
    echo   Fix the above issues and run "make setup" again.
    exit /b 1
)

REM --- Python version check --------------------------------------------------
python -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>&1
if %errorlevel% neq 0 (
    echo   Python 3.10 or newer is required. Please upgrade.
    exit /b 1
)

for /f "tokens=*" %%v in ('python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"') do set "PYVER=%%v"
echo ==^> Using Python %PYVER%

REM --- Create virtualenv if missing ------------------------------------------
if not exist "%PROJECT_ROOT%\.venv" (
    echo ==^> Creating virtualenv at .venv
    python -m venv "%PROJECT_ROOT%\.venv"
)

REM --- Install dependencies --------------------------------------------------
echo ==^> Installing Python dependencies
"%PROJECT_ROOT%\.venv\Scripts\python.exe" -m pip install --upgrade pip --quiet
"%PROJECT_ROOT%\.venv\Scripts\python.exe" -m pip install -r "%PROJECT_ROOT%\requirements.txt"

REM --- Install Playwright browser --------------------------------------------
echo ==^> Installing Playwright Chromium browser
"%PROJECT_ROOT%\.venv\Scripts\python.exe" -m playwright install chromium

REM --- Ensure tests/recorded/ exists -----------------------------------------
if not exist "%PROJECT_ROOT%\tests\recorded" mkdir "%PROJECT_ROOT%\tests\recorded"

echo.
echo   Setup complete. You're ready to record and play tests:
echo.
echo       make record-ipe NAME=my_first_test   # record on IPE
echo       make play NAME=my_first_test         # replay it
echo.
