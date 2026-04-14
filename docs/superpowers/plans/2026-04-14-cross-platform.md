# Cross-Platform Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the team-plugin's hooks work on Windows (Git Bash or PowerShell 7+) and Mac/Linux, and add IDE Copilot support via a `.github/copilot-instructions.md` template.

**Architecture:** Adopt the polyglot `run-hook.cmd` pattern (valid Windows batch + Unix bash simultaneously). Rename `.sh` hook scripts to extensionless bash files, add `.ps1` PowerShell equivalents, update `hooks.json` to call `run-hook.cmd <name>` instead of `bash "...*.sh"`. Add `.github/copilot-instructions.md` template and expand README with platform docs.

**Tech Stack:** Bash, PowerShell, Windows batch (cmd), JSON, Markdown

---

## File Map

| File | Action |
|------|--------|
| `hooks/scripts/run-hook.cmd` | Create — polyglot Windows/Unix dispatcher |
| `hooks/scripts/session-start` | Rename from `session-start.sh` (git mv) |
| `hooks/scripts/pre-tool-use-bash` | Rename from `pre-tool-use-bash.sh` (git mv) |
| `hooks/scripts/post-tool-use-write` | Rename from `post-tool-use-write.sh` (git mv) |
| `hooks/scripts/session-start.ps1` | Create — PowerShell equivalent |
| `hooks/scripts/pre-tool-use-bash.ps1` | Create — PowerShell equivalent |
| `hooks/scripts/post-tool-use-write.ps1` | Create — PowerShell equivalent |
| `hooks/hooks.json` | Modify — update 3 command strings |
| `.github/copilot-instructions.md` | Create — IDE Copilot template |
| `README.md` | Modify — add 3 new sections |

---

## Task 1: Create run-hook.cmd polyglot wrapper

**Files:**
- Create: `hooks/scripts/run-hook.cmd`

- [ ] **Step 1: Create run-hook.cmd**

Create `hooks/scripts/run-hook.cmd` with this exact content:

```
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
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
```

- [ ] **Step 2: Make run-hook.cmd executable**

```bash
chmod +x hooks/scripts/run-hook.cmd
```

- [ ] **Step 3: Verify Unix execution path works**

```bash
bash hooks/scripts/run-hook.cmd
```

Expected: `run-hook.cmd: missing script name` on stderr, exit code 1

- [ ] **Step 4: Commit**

```bash
git add hooks/scripts/run-hook.cmd
git commit -m "feat: add run-hook.cmd cross-platform polyglot wrapper"
```

---

## Task 2: Rename bash hook scripts to extensionless

**Files:**
- Rename: `hooks/scripts/session-start.sh` → `hooks/scripts/session-start`
- Rename: `hooks/scripts/pre-tool-use-bash.sh` → `hooks/scripts/pre-tool-use-bash`
- Rename: `hooks/scripts/post-tool-use-write.sh` → `hooks/scripts/post-tool-use-write`

- [ ] **Step 1: Rename all three scripts with git mv**

```bash
git mv hooks/scripts/session-start.sh hooks/scripts/session-start
git mv hooks/scripts/pre-tool-use-bash.sh hooks/scripts/pre-tool-use-bash
git mv hooks/scripts/post-tool-use-write.sh hooks/scripts/post-tool-use-write
```

- [ ] **Step 2: Verify files are renamed and executable**

```bash
ls -la hooks/scripts/
```

Expected: `session-start`, `pre-tool-use-bash`, `post-tool-use-write` listed (no `.sh`), all executable

- [ ] **Step 3: Verify session-start still runs via run-hook.cmd**

```bash
bash hooks/scripts/run-hook.cmd session-start
```

Expected: prints the team plugin banner

- [ ] **Step 4: Verify pre-tool-use-bash still blocks dangerous commands**

```bash
echo '{"command":"rm -rf /"}' | bash hooks/scripts/run-hook.cmd pre-tool-use-bash
```

Expected: `{"decision":"block","reason":"Potentially destructive command detected: rm -rf /...`

- [ ] **Step 5: Commit**

```bash
git add hooks/scripts/
git commit -m "refactor: rename hook scripts to extensionless for Windows compatibility"
```

---

## Task 3: Create PowerShell hook scripts

**Files:**
- Create: `hooks/scripts/session-start.ps1`
- Create: `hooks/scripts/pre-tool-use-bash.ps1`
- Create: `hooks/scripts/post-tool-use-write.ps1`

- [ ] **Step 1: Create session-start.ps1**

Create `hooks/scripts/session-start.ps1`:

```powershell
# SESSION START HOOK (PowerShell)
# Runs at the beginning of each Claude Code session on Windows without bash.
# Customize this script to load team context, print reminders, etc.
#
# TODO: Replace the banner text below with your team's content.

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host " Team Plugin loaded"
Write-Host " • Team conventions → see CLAUDE.md"
Write-Host " • Code review      → superpowers:code-reviewer agent"
Write-Host " • Skill creator    → skill-creator skill"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

- [ ] **Step 2: Create pre-tool-use-bash.ps1**

Create `hooks/scripts/pre-tool-use-bash.ps1`:

```powershell
# PRE TOOL USE HOOK — Bash tool guard (PowerShell)
# Reads the tool input JSON from stdin.
# Output {"decision":"block","reason":"..."} to prevent the command.
# Exit 0 to allow it.
#
# TODO: Customize $dangerousPatterns for your team's safety requirements.

$inputJson = $input -join ""
$command = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $command = $data.command
} catch {
    $command = ""
}

$dangerousPatterns = @(
    "rm -rf /",
    "git push --force",
    "git push -f",
    "DROP TABLE",
    "drop table"
)

foreach ($pattern in $dangerousPatterns) {
    if ($command -like "*$pattern*") {
        Write-Output "{`"decision`":`"block`",`"reason`":`"Potentially destructive command detected: $pattern. Please confirm this is intentional.`"}"
        exit 0
    }
}

exit 0
```

- [ ] **Step 3: Create post-tool-use-write.ps1**

Create `hooks/scripts/post-tool-use-write.ps1`:

```powershell
# POST TOOL USE HOOK — Write tool (PowerShell)
# Runs after every Write tool call on Windows without bash.
# Receives JSON with tool_name, tool_input, tool_response via stdin.
#
# TODO: Uncomment one of the examples below to enable auto-formatting.

# $inputJson = $input -join ""
# $filePath = ""
# try {
#     $data = $inputJson | ConvertFrom-Json
#     $filePath = $data.tool_input.file_path
# } catch {
#     $filePath = ""
# }

# --- Example 1: Auto-format Python files ---
# if ($filePath -match '\.py$') {
#     & black $filePath 2>$null
# }

# --- Example 2: Auto-format JS/TS files ---
# if ($filePath -match '\.(js|ts|jsx|tsx)$') {
#     & npx prettier --write $filePath 2>$null
# }

# --- Example 3: Run ESLint after write ---
# if ($filePath -match '\.(js|ts)$') {
#     & npx eslint --fix $filePath 2>$null
# }

exit 0
```

- [ ] **Step 4: Verify all three files exist**

```bash
ls hooks/scripts/*.ps1
```

Expected: `session-start.ps1`, `pre-tool-use-bash.ps1`, `post-tool-use-write.ps1`

- [ ] **Step 5: Verify PowerShell syntax is valid (if pwsh available)**

```bash
if command -v pwsh &>/dev/null; then
  for f in hooks/scripts/*.ps1; do
    pwsh -NoProfile -Command "& { . '$f' }" 2>/dev/null && echo "OK: $f" || echo "SYNTAX ERROR: $f"
  done
else
  echo "pwsh not available — skipping syntax check"
fi
```

Expected: either `OK:` for all three, or `pwsh not available` message

- [ ] **Step 6: Commit**

```bash
git add hooks/scripts/session-start.ps1 hooks/scripts/pre-tool-use-bash.ps1 hooks/scripts/post-tool-use-write.ps1
git commit -m "feat: add PowerShell hook script equivalents for Windows"
```

---

## Task 4: Update hooks.json

**Files:**
- Modify: `hooks/hooks.json`

- [ ] **Step 1: Update hooks.json**

Replace the content of `hooks/hooks.json` with:

```json
{
  "description": "Team plugin hooks. Each section is a working example — customize or extend for your team.",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd\" session-start",
            "timeout": 10
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd\" pre-tool-use-bash",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd\" post-tool-use-write",
            "timeout": 30
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Before completing, reflect: have the changes been tested or verified? If there are untested or unverified changes, remind the user to check them before signing off. If everything looks confirmed, proceed normally.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -m json.tool hooks/hooks.json > /dev/null && echo "valid JSON"
```

Expected: `valid JSON`

- [ ] **Step 3: Verify all three command strings reference run-hook.cmd**

```bash
grep "run-hook.cmd" hooks/hooks.json
```

Expected: 3 lines, one for each of `session-start`, `pre-tool-use-bash`, `post-tool-use-write`

- [ ] **Step 4: Verify no .sh references remain**

```bash
grep "\.sh" hooks/hooks.json
```

Expected: no output (empty)

- [ ] **Step 5: Commit**

```bash
git add hooks/hooks.json
git commit -m "fix: update hooks.json to use run-hook.cmd for cross-platform compatibility"
```

---

## Task 5: Create .github/copilot-instructions.md

**Files:**
- Create: `.github/copilot-instructions.md`

- [ ] **Step 1: Create .github directory**

```bash
mkdir -p .github
```

- [ ] **Step 2: Create copilot-instructions.md**

Create `.github/copilot-instructions.md`:

```markdown
<!-- TEMPLATE: from team-plugin — https://github.com/your-org/team-plugin -->
<!-- Copy this file to .github/copilot-instructions.md in your project repo, then fill in each TODO section -->

# Team Copilot Instructions

This file gives GitHub Copilot (VS Code, JetBrains, and other IDEs) context about your team's conventions and resources.

> **Note:** Hooks and agents (code-reviewer, skill-creator) require Claude Code CLI or GitHub Copilot CLI. They are not available in IDE Copilot. This file provides conventions and context only.

## Team
<!-- TODO: Fill in your team details -->
- **Team name:** [Your Team Name]
- **Primary repo:** [https://github.com/your-org/your-repo]
- **Internal docs:** [https://your-internal-docs-url]

## Coding Conventions
<!-- TODO: Add your team's standards. Examples below — replace with your actual rules. -->
- Branch naming: `feature/<ticket>-description`, `fix/<ticket>-description`
- Commit format: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, etc.)
- PR policy: at least 1 review required before merge; no direct pushes to `main`
- [Add more conventions here]

## Key Links
<!-- TODO: Replace with real URLs -->
- CI/CD dashboard: [URL]
- On-call runbook: [URL]
- Architecture docs: [URL]

## Internal MCP
<!-- TODO: Update when your internal MCP is configured -->
The team uses an internal MCP server configured in `.mcp.json` (Claude Code CLI / Copilot CLI only).
```

- [ ] **Step 3: Verify file exists and has TODO sections**

```bash
grep -c "TODO" .github/copilot-instructions.md
```

Expected: `4`

- [ ] **Step 4: Commit**

```bash
git add .github/copilot-instructions.md
git commit -m "feat: add .github/copilot-instructions.md template for IDE Copilot support"
```

---

## Task 6: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read current README**

```bash
cat README.md
```

Note the current ending line so you know where to append.

- [ ] **Step 2: Append three new sections to README.md**

Append the following to the end of `README.md` (after the `## License` section):

```markdown

---

## Platform Support

| Platform | Install method | Hook support |
|----------|---------------|--------------|
| Claude Code CLI — Mac/Linux | `/plugin install https://github.com/your-org/team-plugin` | Full |
| Claude Code CLI — Windows | `/plugin install https://github.com/your-org/team-plugin` | Full (requires Git Bash or PowerShell 7+) |
| GitHub Copilot CLI | `copilot plugin marketplace add https://github.com/your-org/team-plugin` then `copilot plugin install team-plugin@your-org` | Full |
| VS Code Copilot | Copy `.github/copilot-instructions.md` to your repo | Conventions only |
| JetBrains Copilot | Copy `.github/copilot-instructions.md` to your repo | Conventions only |
| Any IDE Copilot | Copy `.github/copilot-instructions.md` to your repo | Conventions only |

## Windows Requirements

Hooks require one of:

- **Git for Windows** (recommended) — includes bash. Download: https://git-scm.com
- **PowerShell 7+** — cross-platform PowerShell. Install: `winget install Microsoft.PowerShell`

If neither is installed, hooks will exit with an error message pointing to this requirement. Skills and agents still work without bash or PowerShell.

## IDE Copilot Setup

VS Code, JetBrains, and other IDE Copilot integrations do not support plugin installation. To give IDE Copilot your team's context:

1. Copy `.github/copilot-instructions.md` from this repo into your project repo at the same path
2. Fill in the `TODO` sections (team name, doc links, conventions)
3. Commit — GitHub Copilot picks it up automatically

Note: Hooks, the `code-reviewer` agent, and the `skill-creator` skill are only available in Claude Code CLI and GitHub Copilot CLI, not in IDE Copilot.
```

- [ ] **Step 3: Verify all three sections were added**

```bash
grep -n "## Platform Support\|## Windows Requirements\|## IDE Copilot Setup" README.md
```

Expected: 3 lines with line numbers

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add platform support, Windows requirements, and IDE Copilot setup to README"
```

---

## Task 7: Final verification

- [ ] **Step 1: Verify file structure**

```bash
find hooks/ .github/ -not -path './.git/*' | sort
```

Expected output includes:
```
.github/copilot-instructions.md
hooks/hooks.json
hooks/scripts/post-tool-use-write
hooks/scripts/post-tool-use-write.ps1
hooks/scripts/pre-tool-use-bash
hooks/scripts/pre-tool-use-bash.ps1
hooks/scripts/run-hook.cmd
hooks/scripts/session-start
hooks/scripts/session-start.ps1
```

- [ ] **Step 2: Verify no .sh files remain**

```bash
find hooks/ -name "*.sh"
```

Expected: no output

- [ ] **Step 3: Verify hooks.json has no bash/\.sh references**

```bash
grep -E "bash |\.sh" hooks/hooks.json
```

Expected: no output

- [ ] **Step 4: Verify run-hook.cmd dispatches correctly on Unix**

```bash
bash hooks/scripts/run-hook.cmd session-start
```

Expected: prints team banner

```bash
echo '{"command":"git push --force origin main"}' | bash hooks/scripts/run-hook.cmd pre-tool-use-bash
```

Expected: `{"decision":"block","reason":"Potentially destructive command detected: git push --force...`

- [ ] **Step 5: Verify all JSON is valid**

```bash
python3 -m json.tool hooks/hooks.json > /dev/null && echo "hooks.json: OK"
```

Expected: `hooks.json: OK`

- [ ] **Step 6: Verify git log is clean**

```bash
git log --oneline
```

Expected: 6 new commits since `6f2baba` (cross-platform design spec), one per task
