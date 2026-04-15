<!-- TEMPLATE: from team-plugin — https://github.com/your-org/team-plugin -->
<!-- Copy this file to .github/copilot-instructions.md in your project repo, then fill in each TODO section -->
<!-- GitHub Copilot in VS Code picks this file up automatically — no extension settings needed -->

# Team Copilot Instructions

This file gives GitHub Copilot (VS Code, JetBrains, and other IDEs) persistent context about your team's conventions, standards, and resources. It is read automatically on every chat message and inline suggestion.

> **Note:** Hooks, the `code-reviewer` agent, and the `skill-creator` skill require Claude Code CLI and are not available in IDE Copilot. This file provides team context and coding conventions only.

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
| `skill-creator` | Skill | Claude Code CLI only |
| `code-reviewer` | Agent | Claude Code CLI only |
| `session-start` hook | Hook | Claude Code CLI only |
| `pre-tool-use-bash` hook | Hook | Claude Code CLI only |
| `pre-commit-quality` hook | Hook | Claude Code CLI only |
| `git-push-reminder` hook | Hook | Claude Code CLI only |
| `doc-file-warning` hook | Hook | Claude Code CLI only |
| `strategic-compact` hook | Hook | Claude Code CLI only |
| `post-tool-use-write` hook | Hook | Claude Code CLI only |
| `prettier-format` hook | Hook | Claude Code CLI only |
| `quality-gate` hook | Hook | Claude Code CLI only |
| `pr-logger` hook | Hook | Claude Code CLI only |
| `pre-compact` hook | Hook | Claude Code CLI only |
| `Stop` hook | Hook | Claude Code CLI only |
