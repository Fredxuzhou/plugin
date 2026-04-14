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
