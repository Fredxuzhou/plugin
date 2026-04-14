#!/bin/bash
# SESSION START HOOK
# Runs at the beginning of each Claude Code session.
# Customize this script to load team context, print reminders, etc.
#
# TODO: Replace the banner text below with your team's content.

cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Team Plugin loaded
 • Team conventions → see CLAUDE.md
 • Code review      → superpowers:code-reviewer agent
 • Skill creator    → skill-creator skill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
