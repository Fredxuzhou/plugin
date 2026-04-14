# POST TOOL USE HOOK — Write tool (PowerShell)
# Runs after every Write tool call on Windows without bash.
# Receives JSON with tool_name, tool_input, tool_response via stdin.
#
# TODO: Uncomment one of the examples below to enable auto-formatting.

# $inputJson = $input -join ""
# $filePath = ""
# try {
#     $data = $inputJson | ConvertFrom-Json
#     $filePath = $data.tool_input.file_path
# } catch {
#     $filePath = ""
# }

# --- Example 1: Auto-format Python files ---
# if ($filePath -match '\.py$') {
#     & black $filePath 2>$null
# }

# --- Example 2: Auto-format JS/TS files ---
# if ($filePath -match '\.(js|ts|jsx|tsx)$') {
#     & npx prettier --write $filePath 2>$null
# }

# --- Example 3: Run ESLint after write ---
# if ($filePath -match '\.(js|ts)$') {
#     & npx eslint --fix $filePath 2>$null
# }

exit 0
