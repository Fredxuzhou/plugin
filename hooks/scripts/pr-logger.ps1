# PR LOGGER HOOK (PowerShell)
# Runs after every Bash tool call on Windows. Detects when a `gh pr create`
# command was run and prints the PR URL + a ready-to-use review command.
# Never blocks — informational only.

$inputJson = $input -join ""
$command = ""
$toolResponse = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $command = [string]$data.tool_input.command
    $toolResponse = $data.tool_response | ConvertTo-Json -Depth 5
} catch {
    exit 0
}

# Only act on gh pr create commands
if ($command -notmatch '\bgh\s+pr\s+create\b') {
    exit 0
}

# Extract PR URL from tool response
$urlMatch = [regex]::Match($toolResponse, 'https://github\.com/([^/\s"]+/[^/\s"]+)/pull/(\d+)')
if ($urlMatch.Success) {
    $url = $urlMatch.Value
    $repo = $urlMatch.Groups[1].Value
    $prNum = $urlMatch.Groups[2].Value
    Write-Error "[team-plugin] PR created: $url"
    Write-Error "  To review: gh pr review $prNum --repo $repo"
}

exit 0
