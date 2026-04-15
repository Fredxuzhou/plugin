# team-plugin

A team context and quality-guard plugin for **VS Code GitHub Copilot** and **Claude Code CLI**. Copy one file to give Copilot your team's conventions; install the full plugin to get hooks, agents, and skills in Claude Code.

---

## 1. VS Code GitHub Copilot Setup

### What this gives you

VS Code GitHub Copilot reads `.github/copilot-instructions.md` from your repository and uses it as persistent context in every chat and inline suggestion. This plugin ships a ready-to-use template that you copy into your project repo once — no extension to install, no API keys, no build step.

With a filled-in file Copilot will:
- Follow your branch naming and commit message conventions automatically
- Reference your team's doc links when answering architecture questions
- Respect your PR policy and code review standards in suggestions
- Know about the agents and skills available to your team

### Step 1 — Copy the template

```bash
# From your project repo root
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/your-org/team-plugin/main/.github/copilot-instructions.md
```

Or copy the file manually from `.github/copilot-instructions.md` in this repo.

### Step 2 — Fill in your team details

Open `.github/copilot-instructions.md` and replace every `TODO` section:

```markdown
## Team
- **Team name:** Payments Platform
- **Primary repo:** https://github.com/acme/payments-api
- **Internal docs:** https://notion.so/acme/payments

## Coding Conventions
- Branch naming: `feature/<JIRA-123>-description`
- Commit format: Conventional Commits (feat:, fix:, chore:, docs:, etc.)
- PR policy: 2 reviews required; no direct pushes to main
- Use Zod for all runtime validation
- All API responses must be typed with shared DTOs in packages/types

## Key Links
- CI/CD dashboard: https://buildkite.com/acme/payments
- On-call runbook: https://notion.so/acme/payments/runbook
- Architecture docs: https://notion.so/acme/payments/arch
```

### Step 3 — Commit and push

```bash
git add .github/copilot-instructions.md
git commit -m "chore: add team Copilot instructions"
git push
```

GitHub Copilot in VS Code picks up the file automatically — no settings change needed.

### Step 4 — Verify it's working

Open GitHub Copilot Chat in VS Code (`Ctrl+Shift+I` / `Cmd+Shift+I`) and ask:

> "What's our branch naming convention?"

Copilot should answer using your team's conventions from the file.

### What Copilot Instructions can and cannot do

| Capability | Supported |
|------------|-----------|
| Team conventions in every suggestion | Yes |
| Coding standards and patterns | Yes |
| Links to internal docs | Yes |
| Custom hooks / automated guards | No — Claude Code CLI only |
| Code review agent | No — Claude Code CLI only |
| Skill creator | No — Claude Code CLI only |

> Hooks, agents, and skills require Claude Code CLI (see section 2 below). The instructions file provides context only.

### Keeping it up to date

The template in this repo is the canonical version. When your team standards change:
1. Edit `.github/copilot-instructions.md` in your project repo
2. Commit — Copilot picks up changes on the next VS Code reload

To pull in upstream improvements to the template itself, compare against the latest version in this repo and merge any structural improvements.

---

## 2. Claude Code CLI Setup

### Install

```bash
/plugin install https://github.com/your-org/team-plugin
```

This installs all hooks, agents, and skills into your Claude Code configuration.

### What you get

On top of everything in the Copilot instructions, Claude Code gets:

- **13 hooks** that run automatically — quality guards, format checks, safety blocks, and session tooling
- **`code-reviewer` agent** — reviews completed implementation steps
- **`skill-creator` skill** — creates and improves agent skills with eval-driven optimization

### Setup after install

1. **Update `.claude-plugin/plugin.json`** — replace `Your Team Name` and `your-org/team-plugin` with your actual team and repo details.
2. **Fill in `CLAUDE.md`** — same team details as the Copilot instructions; this file is loaded at session start by the `session-start` hook.
3. **Customize hooks** (optional) — edit `hooks/scripts/` to match your team's policies:
   - `session-start` / `session-start.ps1` — update the banner text
   - `pre-tool-use-bash` / `pre-tool-use-bash.ps1` — add or remove dangerous command patterns
   - `post-tool-use-write` / `post-tool-use-write.ps1` — uncomment the auto-format example for your stack
4. **Add internal MCP** (when ready) — drop your server config into `.mcp.json`. See `CLAUDE.md` for the format.

### Windows requirements

Hooks require one of:
- **Git for Windows** (recommended) — includes bash. Download: https://git-scm.com
- **PowerShell 7+** — `winget install Microsoft.PowerShell`

If neither is found, hooks exit with a clear error message. Skills and agents work without bash or PowerShell.

---

## What's Included

| Component | Type | Available in |
|-----------|------|-------------|
| `.github/copilot-instructions.md` | Context template | VS Code Copilot + Claude Code |
| `CLAUDE.md` | Context template | Claude Code |
| `skill-creator` | Skill | Claude Code |
| `code-reviewer` | Agent | Claude Code |
| `session-start` hook | Hook | Claude Code |
| `pre-tool-use-bash` hook | Hook | Claude Code |
| `pre-commit-quality` hook | Hook | Claude Code |
| `git-push-reminder` hook | Hook | Claude Code |
| `doc-file-warning` hook | Hook | Claude Code |
| `strategic-compact` hook | Hook | Claude Code |
| `post-tool-use-write` hook | Hook | Claude Code |
| `prettier-format` hook | Hook | Claude Code |
| `quality-gate` hook | Hook | Claude Code |
| `pr-logger` hook | Hook | Claude Code |
| `pre-compact` hook | Hook | Claude Code |
| `Stop` hook | Hook | Claude Code |

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

## Updating Official Content

Both `skills/skill-creator/SKILL.md` and `agents/code-reviewer.md` carry a `<!-- SOURCE: -->` header comment. To update them to a newer upstream version:

1. Find the latest files at the URL in the SOURCE comment
2. Replace the file contents (keep the provenance header lines at the top)
3. Commit with `chore: update <component> from upstream`

---

## Platform Support

| Platform | Setup | What you get |
|----------|-------|-------------|
| VS Code GitHub Copilot | Copy `.github/copilot-instructions.md` to your repo | Team conventions in every suggestion |
| JetBrains GitHub Copilot | Copy `.github/copilot-instructions.md` to your repo | Team conventions in every suggestion |
| Claude Code — Mac/Linux | `/plugin install https://github.com/your-org/team-plugin` | Full (hooks, agents, skills) |
| Claude Code — Windows | `/plugin install https://github.com/your-org/team-plugin` | Full (requires Git Bash or PowerShell 7+) |

---

## License

MIT
