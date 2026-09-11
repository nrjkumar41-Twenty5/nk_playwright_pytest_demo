@echo off
REM =============================================================================
REM  nk_playwright_pytest_demo — Windows One-Click Setup
REM
REM  Double-click this file (or run from cmd/PowerShell).
REM  It installs all prerequisites so you can use:
REM      make setup / make record-ipe / make play / make save / make submit
REM
REM  WHAT IT INSTALLS (only if missing):
REM    1. Chocolatey   — Windows package manager (like Homebrew for Mac)
REM    2. Python 3.12  — required by Playwright
REM    3. Git          — version control
REM    4. Make         — the build tool that runs our commands
REM    5. GitHub CLI   — for creating pull requests from the terminal
REM
REM  REQUIRES: Administrator privileges (right-click → Run as administrator
REM            if double-click fails).
REM =============================================================================

setlocal EnableDelayedExpansion

echo.
echo  ============================================================
echo   nk_playwright_pytest_demo — Windows Setup
echo  ============================================================
echo.

REM --- Check for admin privileges -------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   This script needs Administrator privileges to install software.
    echo.
    echo   Right-click windows-setup.bat and choose "Run as administrator"
    echo.
    pause
    exit /b 1
)

REM --- Step 1: Install Chocolatey if missing --------------------------------
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo  [1/5] Installing Chocolatey...
    @powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Set-ExecutionPolicy Bypass -Scope Process -Force; ^
         [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; ^
         iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if !errorlevel! neq 0 (
        echo   ERROR: Chocolatey installation failed.
        pause
        exit /b 1
    )
    REM Refresh PATH so choco is available immediately
    call refreshenv >nul 2>&1
    set "PATH=%ALLUSERSPROFILE%\chocolatey\bin;%PATH%"
    echo  [1/5] Chocolatey installed.
) else (
    echo  [1/5] Chocolatey already installed. Skipping.
)

REM --- Step 2: Install Python if missing ------------------------------------
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo  [2/5] Installing Python 3.12...
    choco install python312 -y --no-progress
    if !errorlevel! neq 0 (
        echo   ERROR: Python installation failed.
        pause
        exit /b 1
    )
    call refreshenv >nul 2>&1
    echo  [2/5] Python installed.
) else (
    echo  [2/5] Python already installed. Skipping.
)

REM Verify Python version is 3.10+
python -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>&1
if %errorlevel% neq 0 (
    echo   WARNING: Python 3.10+ is required. Your version is too old.
    echo   Run:  choco install python312 -y
    echo   Then re-run this script.
    pause
    exit /b 1
)

REM --- Step 3: Install Git if missing ---------------------------------------
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo  [3/5] Installing Git for Windows...
    choco install git -y --no-progress
    if !errorlevel! neq 0 (
        echo   ERROR: Git installation failed.
        pause
        exit /b 1
    )
    call refreshenv >nul 2>&1
    echo  [3/5] Git installed.
) else (
    echo  [3/5] Git already installed. Skipping.
)

REM --- Step 4: Install Make if missing --------------------------------------
where make >nul 2>&1
if %errorlevel% neq 0 (
    echo  [4/5] Installing Make...
    choco install make -y --no-progress
    if !errorlevel! neq 0 (
        echo   ERROR: Make installation failed.
        pause
        exit /b 1
    )
    call refreshenv >nul 2>&1
    echo  [4/5] Make installed.
) else (
    echo  [4/5] Make already installed. Skipping.
)

REM --- Step 5: Install GitHub CLI if missing --------------------------------
where gh >nul 2>&1
if %errorlevel% neq 0 (
    echo  [5/5] Installing GitHub CLI...
    choco install gh -y --no-progress
    if !errorlevel! neq 0 (
        echo   ERROR: GitHub CLI installation failed.
        pause
        exit /b 1
    )
    call refreshenv >nul 2>&1
    echo  [5/5] GitHub CLI installed.
) else (
    echo  [5/5] GitHub CLI already installed. Skipping.
)

REM --- Verification ---------------------------------------------------------
echo.
echo  ============================================================
echo   Verifying installations...
echo  ============================================================
echo.

set "ALL_OK=1"

where python >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('python --version 2^>^&1') do echo   OK  %%v
) else (
    echo   FAIL  Python not found
    set "ALL_OK=0"
)

where git >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('git --version 2^>^&1') do echo   OK  %%v
) else (
    echo   FAIL  Git not found
    set "ALL_OK=0"
)

where make >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('make --version 2^>^&1') do echo   OK  %%v
) else (
    echo   FAIL  Make not found
    set "ALL_OK=0"
)

where gh >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('gh --version 2^>^&1') do echo   OK  %%v
) else (
    echo   FAIL  GitHub CLI not found
    set "ALL_OK=0"
)

echo.

if "!ALL_OK!"=="0" (
    echo  ============================================================
    echo   Some tools failed to install. Close this window, reopen a
    echo   NEW terminal, and try again. If it still fails, install the
    echo   missing tool manually and re-run this script.
    echo  ============================================================
) else (
    echo  ============================================================
    echo   All prerequisites installed!
    echo.
    echo   IMPORTANT: Close this window and open a NEW terminal
    echo   (cmd, PowerShell, or Git Bash) so PATH updates take effect.
    echo.
    echo   Then navigate to this project folder and run:
    echo.
    echo       make setup
    echo.
    echo   After that you can record and play tests:
    echo.
    echo       make branch BRANCH=your-name/feature-name
    echo       make record-ipe NAME=my_test
    echo       make play NAME=my_test
    echo       make save MSG="recorded my test"
    echo       make submit
    echo  ============================================================
)

echo.
pause
