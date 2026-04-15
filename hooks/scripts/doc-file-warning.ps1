# DOC FILE WARNING HOOK (PowerShell)
# Runs before every Write tool call on Windows. Warns when Claude is about to
# create an ad-hoc documentation file (NOTES.md, TODO.txt, SCRATCH.md, etc.)
# outside of structured directories.
# Never blocks — only warns via stderr.
#
# TODO: Add more patterns to $adHocNames or paths to $allowedDirs as needed.

$inputJson = $input -join ""
$filePath = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $filePath = [string]$data.tool_input.file_path
} catch {
    $filePath = ""
}

if ([string]::IsNullOrEmpty($filePath)) {
    exit 0
}

$baseName = [System.IO.Path]::GetFileName($filePath).ToLower()

$adHocPattern = '^(notes|todo|todos|scratch|temp|draft|wip|untitled|misc)\.(md|txt)$'
if ($baseName -notmatch $adHocPattern) {
    exit 0
}

$allowedDirs = @("docs/", ".claude/", ".github/", "commands/", "skills/", "memory/", "templates/")
foreach ($dir in $allowedDirs) {
    if ($filePath -like "*$dir*") {
        exit 0
    }
}

Write-Error "[team-plugin] Warning: '$filePath' looks like an ad-hoc doc file."
Write-Error "  Consider using docs/, .claude/, or another structured directory instead."
Write-Error "  Writing anyway — remove this hook to silence."

exit 0
