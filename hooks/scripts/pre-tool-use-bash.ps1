# PRE TOOL USE HOOK — Bash tool guard (PowerShell)
# Reads the tool input JSON from stdin.
# Output {"decision":"block","reason":"..."} to prevent the command.
# Exit 0 to allow it.
#
# TODO: Customize $dangerousPatterns for your team's safety requirements.

$inputJson = $input -join ""
$command = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $command = $data.command
} catch {
    $command = ""
}

$dangerousPatterns = @(
    "rm -rf /",
    "git push --force",
    "git push -f",
    "DROP TABLE",
    "drop table"
)

foreach ($pattern in $dangerousPatterns) {
    if ($command -like "*$pattern*") {
        Write-Output "{`"decision`":`"block`",`"reason`":`"Potentially destructive command detected: $pattern. Please confirm this is intentional.`"}"
        exit 0
    }
}

exit 0
