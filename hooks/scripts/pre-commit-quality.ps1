# PRE-COMMIT QUALITY CHECK HOOK (PowerShell)
# Runs before every Bash tool call on Windows. Intercepts `git commit` commands.
# Checks staged JS/TS files for console.log/debugger and validates commit message format.
# Blocks the commit if critical issues are found.
#
# TODO: Extend $dangerousPatterns or add more checks for your stack.

$inputJson = $input -join ""
$command = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $command = [string]$data.tool_input.command
} catch {
    $command = ""
}

# Only act on git commit commands
if ($command -notmatch '\bgit\s+commit\b') {
    exit 0
}

$issues = @()

# --- Check staged JS/TS files for debug statements ---
try {
    $staged = git diff --cached --name-only 2>$null
    foreach ($file in $staged) {
        if ($file -match '\.(js|jsx|ts|tsx)$') {
            $content = git show ":$file" 2>$null
            if ($content -match 'console\.(log|debug|warn|error)\s*\(|debugger\s*;') {
                $issues += "  - ${file}: contains console.log/debugger statement"
            }
        }
    }
} catch {}

# --- Check commit message against Conventional Commits ---
# Try -m flag first, then -F/--file flag
$msg = $null
if ($command -match '-m\s+[''"](.+?)[''"]') {
    $msg = $Matches[1]
} elseif ($command -match '(?:-F|--file)[=\s]+[''"]?([^\s''"]+)') {
    $msgFile = $Matches[1]
    if (Test-Path $msgFile) {
        $msg = (Get-Content $msgFile -TotalCount 1 -ErrorAction SilentlyContinue)
    }
}

if ($msg) {
    if ($msg -notmatch '^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,72}$') {
        $issues += "  - Commit message does not follow Conventional Commits format"
        $issues += "    Expected: type(scope): description (max 72 chars)"
        $issues += "    Got: $msg"
    }
}

if ($issues.Count -gt 0) {
    $reason = "Pre-commit quality check failed:`n" + ($issues -join "`n")
    [PSCustomObject]@{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress
    exit 0
}

exit 0
