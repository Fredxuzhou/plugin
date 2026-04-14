#!/bin/bash
# PRE TOOL USE HOOK — Bash tool guard
# Reads the tool input JSON from stdin.
# Output {"decision":"block","reason":"..."} to prevent the command.
# Exit 0 (or output {"decision":"approve"}) to allow it.
#
# TODO: Customize DANGEROUS_PATTERNS for your team's safety requirements.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('command', ''))
except Exception:
    print('')
" 2>/dev/null)

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "drop table"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$pattern"; then
    printf '{"decision":"block","reason":"Potentially destructive command detected: %s. Please confirm this is intentional."}\n' "$pattern"
    exit 0
  fi
done

exit 0
