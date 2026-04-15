# GIT PUSH REMINDER HOOK (PowerShell)
# Runs before every Bash tool call on Windows. When a `git push` is detected,
# prints a non-blocking reminder to review changes before they go out.
# Never blocks — just informs.

$inputJson = $input -join ""
$command = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $command = [string]$data.command
} catch {
    $command = ""
}

# Only act on git push commands
if ($command -notmatch '\bgit\s+push\b') {
    exit 0
}

Write-Error "[team-plugin] Git push detected — quick checklist before it goes out:"
Write-Error "  • git diff origin/HEAD   — review what you're pushing"
Write-Error "  • git log --oneline -5   — confirm commit history looks right"
Write-Error "  • CI passing?            — check your pipeline before pushing"

exit 0
