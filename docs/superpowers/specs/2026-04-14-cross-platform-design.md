# Cross-Platform Support — Design Spec

**Date:** 2026-04-14  
**Status:** Approved  

---

## Overview

Extend the team-plugin to work on Windows, Mac, and Linux across all supported AI tools: Claude Code CLI, GitHub Copilot CLI, VS Code Copilot, JetBrains Copilot, and any IDE Copilot. The main work is fixing hook scripts (currently bash-only) to run on Windows, and adding a `.github/copilot-instructions.md` template for IDE Copilot users.

---

## Platform Support Matrix

| Platform | Install method | Hook support |
|----------|---------------|--------------|
| Claude Code CLI (Mac/Linux) | `/plugin install <url>` | Full |
| Claude Code CLI (Windows) | `/plugin install <url>` | Full (requires Git Bash or PowerShell 7+) |
| GitHub Copilot CLI | `copilot plugin marketplace add` + `copilot plugin install` | Full |
| VS Code Copilot | Copy `.github/copilot-instructions.md` to repo | Instructions only |
| JetBrains Copilot | Copy `.github/copilot-instructions.md` to repo | Instructions only |
| Any IDE Copilot | Copy `.github/copilot-instructions.md` to repo | Instructions only |

---

## Approach: Polyglot Wrapper + Dual Scripts

Adopted from the superpowers plugin (proven pattern). A single `run-hook.cmd` file acts as both a Windows batch script and a Unix shell script simultaneously. Hook scripts are extensionless bash files with matching `.ps1` PowerShell equivalents. `hooks.json` calls `run-hook.cmd <script-name>` — the wrapper handles platform dispatch.

---

## Changes

### 1. `hooks/scripts/run-hook.cmd` (new)

Polyglot wrapper script (valid Windows batch AND Unix bash):

**Windows execution path (batch):**
1. Try `C:\Program Files\Git\bin\bash.exe` (Git for Windows standard location)
2. Try `C:\Program Files (x86)\Git\bin\bash.exe` (32-bit Git for Windows)
3. Try `bash` on PATH (MSYS2, Cygwin, WSL-exposed bash)
4. Try `pwsh` on PATH (PowerShell 7+ cross-platform — runs `.ps1` equivalent)
5. If none found: exit with error message `"team-plugin: no bash or pwsh found. Install Git for Windows or PowerShell 7+."`

**Unix execution path (bash):**  
Directly exec the named extensionless script via bash.

### 2. Hook script renames (bash, extensionless)

| Old name | New name |
|----------|----------|
| `hooks/scripts/session-start.sh` | `hooks/scripts/session-start` |
| `hooks/scripts/pre-tool-use-bash.sh` | `hooks/scripts/pre-tool-use-bash` |
| `hooks/scripts/post-tool-use-write.sh` | `hooks/scripts/post-tool-use-write` |

Content unchanged. Extensionless naming avoids Claude Code's Windows auto-detection behavior (which prepends `bash` to any command containing `.sh`, interfering with the polyglot wrapper).

### 3. PowerShell equivalents (new)

Three new `.ps1` scripts that mirror their bash counterparts exactly:

**`hooks/scripts/session-start.ps1`**  
Uses `Write-Host` to print the same team banner. Same `# TODO:` comment.

**`hooks/scripts/pre-tool-use-bash.ps1`**  
Reads JSON from stdin (`$input -join ""`), parses with `ConvertFrom-Json`, checks `command` field against the same `$dangerousPatterns` array, outputs `{"decision":"block","reason":"..."}` or exits 0. Same `# TODO:` comment.

**`hooks/scripts/post-tool-use-write.ps1`**  
All logic commented out. Three same examples (format Python with black, format JS/TS with prettier, run ESLint). Same `# TODO:` comment. Exits 0.

### 4. `hooks/hooks.json` — command strings updated

All three command-type hooks change from `bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<name>.sh"` to `"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd" <name>`:

```json
"command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd\" session-start"
"command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd\" pre-tool-use-bash"
"command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/run-hook.cmd\" post-tool-use-write"
```

The `Stop` hook (prompt-type) is unchanged — no script involved.

### 5. `.github/copilot-instructions.md` (new)

Template file for IDE Copilot users. Teams copy this into their own repos. Content:

- Header explaining it's a template from team-plugin (with repo URL placeholder)
- Same sections as `CLAUDE.md`: Team, Coding Conventions, Key Links, Internal MCP, Installed Components
- Same `<!-- TODO: -->` comment convention
- Note: hooks and agents are not available in IDE Copilot — conventions and context only

### 6. `README.md` — additions

Three new sections added after the existing content:

- **Platform Support** table (the matrix above)
- **Windows Requirements** — Git for Windows (preferred, includes bash) or PowerShell 7+ (`winget install Microsoft.PowerShell`)
- **IDE Copilot Setup** — how to copy and fill in `.github/copilot-instructions.md`

---

## Non-Goals

- No WSL-specific configuration (WSL users get the Linux path automatically)
- No Cursor, Gemini CLI, or OpenCode support (out of scope for this iteration)
- No automated sync of `.github/copilot-instructions.md` with `CLAUDE.md`

---

## File Map

| File | Action |
|------|--------|
| `hooks/scripts/run-hook.cmd` | Create |
| `hooks/scripts/session-start` | Rename from `session-start.sh` |
| `hooks/scripts/pre-tool-use-bash` | Rename from `pre-tool-use-bash.sh` |
| `hooks/scripts/post-tool-use-write` | Rename from `post-tool-use-write.sh` |
| `hooks/scripts/session-start.ps1` | Create |
| `hooks/scripts/pre-tool-use-bash.ps1` | Create |
| `hooks/scripts/post-tool-use-write.ps1` | Create |
| `hooks/hooks.json` | Modify (3 command strings) |
| `.github/copilot-instructions.md` | Create |
| `README.md` | Modify (3 new sections) |
