#!/bin/bash
# POST TOOL USE HOOK — Write tool
# Runs after every Write tool call.
# Receives JSON with tool_name, tool_input, tool_response via stdin.
#
# TODO: Uncomment one of the examples below to enable auto-formatting.

# INPUT=$(cat)
# FILE_PATH=$(echo "$INPUT" | python3 -c "
# import sys, json
# try:
#     data = json.load(sys.stdin)
#     print(data.get('tool_input', {}).get('file_path', ''))
# except Exception:
#     print('')
# " 2>/dev/null)

# --- Example 1: Auto-format Python files ---
# if echo "$FILE_PATH" | grep -q '\.py$'; then
#   black "$FILE_PATH" 2>/dev/null || true
# fi

# --- Example 2: Auto-format JS/TS files ---
# if echo "$FILE_PATH" | grep -qE '\.(js|ts|jsx|tsx)$'; then
#   npx prettier --write "$FILE_PATH" 2>/dev/null || true
# fi

# --- Example 3: Run ESLint after write ---
# if echo "$FILE_PATH" | grep -qE '\.(js|ts)$'; then
#   npx eslint --fix "$FILE_PATH" 2>/dev/null || true
# fi

exit 0
