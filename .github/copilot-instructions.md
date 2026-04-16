<!-- TEMPLATE: from team-plugin — https://github.com/your-org/team-plugin -->
<!-- Copy this file to .github/copilot-instructions.md in your project repo, then fill in each TODO section -->
<!-- GitHub Copilot in VS Code picks this file up automatically — no extension settings needed -->

# Team Copilot Instructions

This file gives GitHub Copilot (VS Code, JetBrains, and other IDEs) persistent context about your team's conventions, standards, and resources. It is read automatically on every chat message and inline suggestion.

> **Note:** Hooks, agents, and skills run in **VS Code Copilot Agent mode** after the plugin is installed (Command Palette → Chat: Install Plugin From Source). In Ask/Edit mode and inline suggestions, only the conventions in this file are available.

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
- [Add more conventions here — e.g. preferred libraries, patterns to avoid, testing requirements]

## Key Links
<!-- TODO: Replace with real URLs -->
- CI/CD dashboard: [URL]
- On-call runbook: [URL]
- Architecture docs: [URL]

## Internal MCP
<!-- TODO: Update when your internal MCP is configured -->
The team uses an internal MCP server configured in `.mcp.json` (Claude Code CLI only).

## Installed Components
| Component | Type | Available in |
|-----------|------|-------------|
| `skill-creator` | Skill | VS Code Agent mode + Claude Code CLI |
| `code-reviewer` | Agent | VS Code Agent mode + Claude Code CLI |
| `session-start` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `pre-tool-use-bash` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `pre-commit-quality` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `git-push-reminder` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `doc-file-warning` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `strategic-compact` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `post-tool-use-write` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `prettier-format` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `quality-gate` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `pr-logger` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `pre-compact` hook | Hook | VS Code Agent mode + Claude Code CLI |
| `Stop` hook | Hook | VS Code Agent mode + Claude Code CLI |
