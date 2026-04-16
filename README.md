# team-plugin

A team plugin for **VS Code GitHub Copilot** and **Claude Code CLI**. Install it to get hooks that run automatically, agents, skills, and your team's conventions baked into every session.

---

## 1. VS Code GitHub Copilot

### Requirements

- VS Code 1.99 or later
- GitHub Copilot + GitHub Copilot Chat extensions installed and signed in
- Use **Agent mode** in Copilot Chat (the mode selector in the chat input bar — select "Agent" not "Ask" or "Edit")

Hooks, skills, and agents only run in Agent mode. Basic chat and inline suggestions do not execute plugin hooks.

### Install

1. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`)
2. Run **Chat: Install Plugin From Source**
3. Enter your team's plugin URL:
   ```
   https://github.com/your-org/team-plugin
   ```
4. VS Code clones and activates the plugin — no restart needed

To verify installation: open Copilot Chat in Agent mode and run a git commit — the `pre-commit-quality` hook will fire automatically.

### What you get

**Hooks** (run automatically in the background):

| Hook | What it does |
|------|-------------|
| `pre-tool-use-bash` | Blocks dangerous shell commands (rm -rf /, force push, DROP TABLE) |
| `pre-commit-quality` | Blocks git commits with console.log/debugger or bad commit message format |
| `git-push-reminder` | Prints a review checklist before every git push |
| `doc-file-warning` | Warns when writing ad-hoc files like NOTES.md outside structured dirs |
| `strategic-compact` | Suggests /compact at 50-edit milestones to keep context fresh |
| `prettier-format` | Auto-formats files after every write (if Prettier is installed) |
| `quality-gate` | Syntax/lint check after every file edit |
| `pr-logger` | Logs PR URL and review command after gh pr create |
| `pre-compact` | Logs a timestamp before context compaction |
| `session-start` | Prints your team's banner at session start |
| `Stop` | Prompt-based quality gate before the agent stops |

**Agents** (invoke on demand in chat):

| Agent | What it does |
|-------|-------------|
| `code-reviewer` | Reviews completed implementation steps against plan and coding standards |

**Skills** (invoke via slash command in chat):

| Skill | What it does |
|-------|-------------|
| `skill-creator` | Creates and optimizes new skills with eval-driven iteration |

### Setup after install

1. **Fill in `CLAUDE.md`** — replace the `TODO` sections with your team name, doc links, and coding conventions. This file is shown at session start.
2. **Customize hooks** (optional) — edit scripts in `hooks/scripts/`:
   - `pre-tool-use-bash` — add or remove dangerous command patterns
   - `post-tool-use-write` — uncomment the auto-format example for your stack
3. **Add copilot instructions** — copy `.github/copilot-instructions.md` into your project repo for team context in inline suggestions (see section 3 below).

### Windows requirements

Hooks require one of:
- **Git for Windows** (recommended) — includes bash. Download: https://git-scm.com
- **PowerShell 7+** — `winget install Microsoft.PowerShell`

If neither is found, hooks exit with a clear error. Skills and agents work without bash or PowerShell.

---

## 2. Claude Code CLI

### Install

```bash
/plugin install https://github.com/your-org/team-plugin
```

Everything works the same as VS Code — same hooks, same agents, same skills.

### Setup after install

1. Update `.claude-plugin/plugin.json` — replace `Your Team Name` and `your-org/team-plugin`.
2. Fill in `CLAUDE.md` — same team details.
3. Customize hooks in `hooks/scripts/` as needed.
4. Add internal MCP in `.mcp.json` when ready (see `CLAUDE.md` for format).

---

## 3. VS Code Inline Suggestions (without Agent mode)

Copilot inline suggestions and basic chat do not run plugin hooks. To give Copilot your team's conventions in those contexts, copy the instructions file into your project repo:

```bash
# From your project repo root
cp /path/to/team-plugin/.github/copilot-instructions.md .github/copilot-instructions.md
```

Then fill in the `TODO` sections and commit. GitHub Copilot picks it up automatically with no settings change.

This gives inline suggestions and chat context about your branch naming, commit format, PR policy, and key links — but does not run hooks.

---

## Hooks Reference

All hooks run through the cross-platform `run-hook.cmd` wrapper (bash on Mac/Linux, Git Bash or PowerShell 7+ on Windows). Each hook has an extensionless bash script and a `.ps1` PowerShell equivalent in `hooks/scripts/`.

### Hook Overview

| Script | Event | Matcher | Blocking? | Purpose |
|--------|-------|---------|-----------|---------|
| `session-start` | SessionStart | — | No | Prints team banner |
| `pre-tool-use-bash` | PreToolUse | Bash | Yes | Blocks dangerous shell commands |
| `pre-commit-quality` | PreToolUse | Bash | Yes | Quality checks before git commit |
| `git-push-reminder` | PreToolUse | Bash | No | Reminds to review before push |
| `doc-file-warning` | PreToolUse | Write | No | Warns about ad-hoc doc files |
| `strategic-compact` | PreToolUse | Edit\|Write | No | Suggests /compact at thresholds |
| `post-tool-use-write` | PostToolUse | Write | No | Placeholder for auto-format |
| `prettier-format` | PostToolUse | Write | No | Auto-formats files via Prettier |
| `quality-gate` | PostToolUse | Edit\|Write | No | Syntax/lint check after edits |
| `pr-logger` | PostToolUse | Bash | No | Logs PR URL after gh pr create |
| `pre-compact` | PreCompact | — | No | Logs compaction timestamp |
| `Stop` | Stop | — | No | Prompt-based quality gate |

### Hook Details

#### `pre-commit-quality`
Intercepts `git commit` commands and checks:
- Staged `.js/.jsx/.ts/.tsx` files for `console.log`, `console.debug`, or `debugger` statements
- Commit message format against [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): description`

Blocks the commit and lists all issues if checks fail. Customize patterns in the script.

**Dependencies:** `git`, `python3`

#### `git-push-reminder`
Detects `git push` commands and prints a non-blocking checklist to stderr reminding you to review `git diff origin/HEAD` and confirm CI status before the push proceeds.

**Dependencies:** none

#### `doc-file-warning`
Warns when the agent writes a file matching ad-hoc patterns (`NOTES.md`, `TODO.txt`, `SCRATCH.md`, `TEMP.md`, etc.) outside of structured directories (`docs/`, `.claude/`, `.github/`, `skills/`, `memory/`). Never blocks.

**Dependencies:** `python3`

#### `strategic-compact`
Tracks edit/write operations per session (keyed by parent process ID). At the configured threshold (default: 50, override with `COMPACT_THRESHOLD` env var) and every 25 calls after, suggests running `/compact` to keep context fresh.

**Dependencies:** none

#### `quality-gate`
After each file edit or write, runs a lightweight check using available tooling:
- **JS/TS** → ESLint (if installed)
- **Python** → `python3 -m py_compile` (syntax check)
- **Go** → `gofmt -l` (format check)
- **JSON** → `python3 -m json.tool` (syntax check)

Never blocks. Prints warnings to stderr.

**Dependencies:** `python3`; optional: `eslint`, `gofmt`

#### `prettier-format`
After each Write, auto-formats the file in place using Prettier if available. Tries `node_modules/.bin/prettier` first, then the global `prettier`. Silently skips if Prettier is not installed. Supports: `js jsx ts tsx css scss html json md yaml yml`.

**Dependencies:** optional: `prettier`

#### `pr-logger`
After each Bash tool call, checks if the command was `gh pr create`. If so, extracts the PR URL from the output and prints the URL and a ready-to-use `gh pr review` command to stderr.

**Dependencies:** `gh` (GitHub CLI), `python3`

#### `pre-compact`
Runs before the agent compacts the conversation context. Appends a timestamped line to `~/.claude/compaction-log.txt` so you can track compaction frequency.

**Dependencies:** none

---

## Updating Official Content

Both `skills/skill-creator/SKILL.md` and `agents/code-reviewer.md` carry a `<!-- SOURCE: -->` header comment. To update them to a newer upstream version:

1. Find the latest files at the URL in the SOURCE comment
2. Replace the file contents (keep the provenance header lines at the top)
3. Commit with `chore: update <component> from upstream`

---

## Platform Support

| Platform | Install | Hooks | Agents | Skills |
|----------|---------|-------|--------|--------|
| VS Code Copilot (Agent mode) | Command Palette → Chat: Install Plugin From Source | ✅ | ✅ | ✅ |
| Claude Code CLI — Mac/Linux | `/plugin install <url>` | ✅ | ✅ | ✅ |
| Claude Code CLI — Windows | `/plugin install <url>` (needs Git Bash or pwsh) | ✅ | ✅ | ✅ |
| VS Code Copilot (Ask/Edit mode) | Copy `.github/copilot-instructions.md` | ❌ | ❌ | ❌ |

---

## License

MIT
