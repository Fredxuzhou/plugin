# Team AI Plugin — Design Spec

**Date:** 2026-04-14  
**Status:** Approved  

---

## Overview

A self-contained Claude Code + GitHub Copilot CLI plugin hosted on GitHub. Teammates install it via a single GitHub URL. It provides a curated set of official skills and agents (copied in for self-containment), a scaffolded hook suite for team customization, and a team context file. It also serves as a forkable starter template for further customization.

---

## Goals

1. **Productivity kit** — bundles the best official skills/agents so teammates get a working setup in one install
2. **Team onboarding** — loads shared conventions and context via `CLAUDE.md` and a SessionStart hook
3. **Curated starter** — well-structured, documented, ready to fork and extend with company-specific content (e.g. internal MCP)

---

## Non-Goals (v1)

- No MCP servers (placeholder left for future internal MCP)
- No custom skills beyond what is copied from official sources
- No CI/CD or automated testing of plugin content

---

## Repository Structure

```
team-plugin/
├── .claude-plugin/
│   └── plugin.json                   # Plugin manifest
├── skills/
│   └── skill-creator/
│       └── SKILL.md                  # Copied from skill-creator@claude-plugins-official
├── agents/
│   └── code-reviewer.md              # Copied from superpowers code-reviewer agent
├── hooks/
│   └── hooks.json                    # 4 hook types as example scaffolds
├── .mcp.json                         # Placeholder for internal MCP
├── CLAUDE.md                         # Team context template
└── README.md                         # Install instructions + component overview
```

---

## Components

### Plugin Manifest (`.claude-plugin/plugin.json`)

```json
{
  "name": "team-plugin",
  "version": "0.1.0",
  "description": "Team AI plugin — skills, agents, hooks, and context for Claude Code and GitHub Copilot CLI",
  "author": {
    "name": "Your Team Name",
    "url": "https://github.com/your-org/team-plugin"
  },
  "repository": "https://github.com/your-org/team-plugin",
  "license": "MIT",
  "keywords": ["team", "productivity", "skills", "workflow"]
}
```

---

### Skills (`skills/skill-creator/SKILL.md`)

Copied verbatim from `skill-creator@claude-plugins-official` at the time of initial release. Enables teammates to create new skills, improve existing ones, and run evals — directly from within agent sessions.

**Provenance header** (top of file):
```
# SOURCE: copied from skill-creator@claude-plugins-official
# To update: replace this file with the latest version from the official plugin
```

---

### Agents (`agents/code-reviewer.md`)

Copied verbatim from the `code-reviewer` agent in `superpowers@claude-plugins-official` (v5.0.7). Triggered after major implementation steps to review completed work against the original plan and coding standards.

**Provenance header** (top of file):
```
# SOURCE: copied from superpowers@claude-plugins-official v5.0.7
# To update: replace this file with the latest version from the official plugin
```

---

### Hooks (`hooks/hooks.json`)

All four hook types included as documented scaffolds. Each hook has inline comments explaining what to replace and how.

| Hook | Event | Example behavior | Type |
|------|-------|-----------------|------|
| Session context loader | `SessionStart` | Prints team welcome, points agent to `CLAUDE.md` | command |
| Dangerous command guard | `PreToolUse` (Bash) | Warns on `rm -rf`, `git push --force` | command |
| Post-write placeholder | `PostToolUse` (Write) | Example slot for auto-format / lint trigger | command |
| Completion quality gate | `Stop` | Prompt-based: "Did you verify your changes?" | prompt |

All hook commands reference `${CLAUDE_PLUGIN_ROOT}` for portability.

---

### MCP Placeholder (`.mcp.json`)

Empty object with a comment block explaining the format and where to drop internal MCP server config.

```json
{}
```

Comment block documents:
- Expected format for stdio and HTTP MCP servers
- How to reference `${CLAUDE_PLUGIN_ROOT}` in server paths
- Where to find the team's internal MCP config

---

### Team Context (`CLAUDE.md`)

A template with labeled `# TODO` sections that teams fill in once after forking:

- Team name and primary repo links
- Internal documentation URLs
- Coding conventions and branch naming rules
- Note about where the internal MCP will be wired up

---

### README (`README.md`)

Covers:
- One-line install for Claude Code and GitHub Copilot CLI
- What's included (table of skills / agents / hooks)
- How to customize hooks
- How to add the internal MCP later
- How to update official content (provenance instructions)

---

## Installation

**Claude Code:**
```bash
/plugin install https://github.com/your-org/team-plugin
```

**GitHub Copilot CLI:**
```bash
copilot plugin marketplace add https://github.com/your-org/team-plugin
copilot plugin install team-plugin@your-org
```

---

## Provenance & Maintenance

Copied official content (`skill-creator` skill, `code-reviewer` agent) carries a `# SOURCE:` header comment identifying the upstream plugin and version. When Anthropic releases updates, teammates replace the file contents and update the source comment. No automated sync — intentionally manual to keep the repo stable.

---

## Future Extensions (out of scope for v1)

- Internal MCP server configuration (drop into `.mcp.json`)
- Company-specific custom skills
- PreToolUse hooks enforcing team-specific policies
- Automated upstream sync script
