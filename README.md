# team-plugin

A self-contained Claude Code + GitHub Copilot CLI plugin for teams. Install via a single GitHub URL to get a curated set of official skills, a code review agent, four hook scaffolds, and a team context template.

## Install

**Claude Code:**
```bash
/plugin install https://github.com/your-org/team-plugin
```

**GitHub Copilot CLI:**
```bash
copilot plugin marketplace add https://github.com/your-org/team-plugin
copilot plugin install team-plugin@your-org
```

## What's Included

| Component | Type | Source |
|-----------|------|--------|
| `skill-creator` | Skill | Copied from `skill-creator@claude-plugins-official` |
| `code-reviewer` | Agent | Copied from `superpowers@claude-plugins-official` v5.0.7 |
| `session-start` hook | Hook | Prints team banner on session start |
| `pre-tool-use-bash` hook | Hook | Guards dangerous Bash commands |
| `pre-commit-quality` hook | Hook | Blocks commits with debug code or bad message format |
| `git-push-reminder` hook | Hook | Reminds to review before git push |
| `doc-file-warning` hook | Hook | Warns on ad-hoc doc files outside structured dirs |
| `strategic-compact` hook | Hook | Suggests /compact at edit count thresholds |
| `post-tool-use-write` hook | Hook | Placeholder for custom post-write actions |
| `prettier-format` hook | Hook | Auto-formats written files via Prettier (if installed) |
| `quality-gate` hook | Hook | Syntax/lint check after every file edit |
| `pr-logger` hook | Hook | Logs PR URL and review command after gh pr create |
| `pre-compact` hook | Hook | Logs timestamp before context compaction |
| `Stop` hook | Hook | Prompt-based quality gate before session end |

## Setup After Install

1. **Update `.claude-plugin/plugin.json`** — replace `Your Team Name` and `your-org/team-plugin` with your actual team and repo details.
2. **Fill in `CLAUDE.md`** — replace the `TODO` sections with your team name, doc links, and coding conventions.
3. **Customize hooks** (optional) — edit `hooks/scripts/` to match your team's policies:
   - `session-start` (bash) / `session-start.ps1` (PowerShell) — update the banner text
   - `pre-tool-use-bash` (bash) / `pre-tool-use-bash.ps1` (PowerShell) — add or remove dangerous patterns
   - `post-tool-use-write` (bash) / `post-tool-use-write.ps1` (PowerShell) — uncomment the auto-format example for your stack
4. **Add internal MCP** (when ready) — drop your server config into `.mcp.json`. See `CLAUDE.md` for the expected format.

## Updating Official Content

Both `skills/skill-creator/SKILL.md` and `agents/code-reviewer.md` carry a `<!-- SOURCE: -->` header comment. To update them to a newer upstream version:

1. Find the latest files at the URL in the SOURCE comment
2. Replace the file contents (keep the provenance header lines at the top)
3. Commit with `chore: update <component> from upstream`

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
Warns when Claude writes a file matching ad-hoc patterns (`NOTES.md`, `TODO.txt`, `SCRATCH.md`, `TEMP.md`, etc.) outside of structured directories (`docs/`, `.claude/`, `.github/`, `skills/`, `memory/`). Never blocks.

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
After each Write, auto-formats the file in place using Prettier if available. Tries the local `node_modules/.bin/prettier` first, then the global `prettier`. Silently skips if Prettier is not installed. Supports: `js jsx ts tsx css scss html json md yaml yml`.

**Dependencies:** optional: `prettier`

#### `pr-logger`
After each Bash tool call, checks if the command was `gh pr create`. If so, extracts the PR URL from the output and prints the URL and a ready-to-use `gh pr review` command to stderr.

**Dependencies:** `gh` (GitHub CLI), `python3`

#### `pre-compact`
Runs before Claude Code compacts the conversation context. Appends a timestamped line to `~/.claude/compaction-log.txt` so you can track compaction frequency.

**Dependencies:** none

---

## License

MIT

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
