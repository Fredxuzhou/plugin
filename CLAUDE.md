# Team Context

This file is loaded by the SessionStart hook and gives Claude Code context about your team's conventions and resources. Replace every `TODO` section before sharing with teammates.

> **VS Code Copilot users:** install the plugin via Command Palette → **Chat: Install Plugin From Source** to get hooks, agents, and skills in Agent mode. Copy `.github/copilot-instructions.md` to your project repo for conventions in Copilot Chat (Ask/Edit mode). Note: custom instructions apply to chat only, not inline completions.

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
The internal MCP server will be configured in `.mcp.json` when available.
Format for a stdio server:
```json
{
  "server-name": {
    "command": "/path/to/server",
    "args": ["--flag"],
    "env": { "API_KEY": "${API_KEY}" }
  }
}
```

## Installed Components
| Component | Type | Purpose |
|-----------|------|---------|
| `skill-creator` | Skill | Create and improve agent skills |
| `code-reviewer` | Agent | Review completed implementation steps |
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
