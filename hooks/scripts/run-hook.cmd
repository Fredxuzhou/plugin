: << 'CMDBLOCK'
@echo off
REM Cross-platform polyglot wrapper for hook scripts.
REM On Windows: tries Git Bash first, then pwsh (PowerShell 7+), errors if neither found.
REM On Unix: the shell treats the batch block as a no-op and runs the bash section.
REM
REM Hook scripts use extensionless filenames so Claude Code's Windows auto-detection
REM (which prepends "bash" to any command containing .sh) doesn't interfere.
REM
REM Usage: run-hook.cmd <script-name> [args...]

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"
set "SCRIPT_NAME=%~1"
shift

REM Try Git for Windows bash in standard locations
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%SCRIPT_NAME%" %1 %2 %3 %4 %5 %6 %7 %8
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%SCRIPT_NAME%" %1 %2 %3 %4 %5 %6 %7 %8
    exit /b %ERRORLEVEL%
)

REM Try bash on PATH (MSYS2, Cygwin, WSL-exposed bash)
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%SCRIPT_NAME%" %1 %2 %3 %4 %5 %6 %7 %8
    exit /b %ERRORLEVEL%
)

REM Try PowerShell 7+ with .ps1 equivalent
where pwsh >nul 2>nul
if %ERRORLEVEL% equ 0 (
    pwsh -NoProfile -File "%HOOK_DIR%%SCRIPT_NAME%.ps1" %1 %2 %3 %4 %5 %6 %7 %8
    exit /b %ERRORLEVEL%
)

REM Neither bash nor pwsh found — exit with clear error
echo team-plugin: no bash or pwsh found. Install Git for Windows (https://git-scm.com) or PowerShell 7+ (winget install Microsoft.PowerShell) >&2
exit /b 1
CMDBLOCK

# Unix: run the named extensionless script directly via bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
[ -z "$1" ] && { echo "run-hook.cmd: missing script name" >&2; exit 1; }
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
