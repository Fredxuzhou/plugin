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
| `SessionStart` hook | Hook | Example — prints team banner |
| `PreToolUse` hook | Hook | Example — guards dangerous Bash commands |
| `PostToolUse` hook | Hook | Example — placeholder for auto-format |
| `Stop` hook | Hook | Example — prompt-based quality gate |

## Setup After Install

1. **Update `.claude-plugin/plugin.json`** — replace `Your Team Name` and `your-org/team-plugin` with your actual team and repo details.
2. **Fill in `CLAUDE.md`** — replace the `TODO` sections with your team name, doc links, and coding conventions.
3. **Customize hooks** (optional) — edit `hooks/scripts/` to match your team's policies:
   - `session-start.sh` — update the banner text
   - `pre-tool-use-bash.sh` — add or remove dangerous patterns
   - `post-tool-use-write.sh` — uncomment the auto-format example for your stack
4. **Add internal MCP** (when ready) — drop your server config into `.mcp.json`. See `CLAUDE.md` for the expected format.

## Updating Official Content

Both `skills/skill-creator/SKILL.md` and `agents/code-reviewer.md` carry a `<!-- SOURCE: -->` header comment. To update them to a newer upstream version:

1. Find the latest files at the URL in the SOURCE comment
2. Replace the file contents (keep the provenance header lines at the top)
3. Commit with `chore: update <component> from upstream`

## License

MIT
