# STRATEGIC COMPACT HOOK (PowerShell)
# Runs before every Edit and Write tool call on Windows. Tracks how many
# edits have happened this session and suggests /compact at checkpoints.
# Uses the parent process ID as a session identifier.
# Never blocks — only suggests via stderr.
#
# Configuration:
#   $env:COMPACT_THRESHOLD  — number of edits before first suggestion (default: 50)

$threshold = 50
if ($env:COMPACT_THRESHOLD) {
    $parsed = 0
    if ([int]::TryParse($env:COMPACT_THRESHOLD, [ref]$parsed)) {
        if ($parsed -ge 1 -and $parsed -le 10000) {
            $threshold = $parsed
        }
    }
}

# Session-scoped counter file (keyed to parent PID)
$ppid = (Get-Process -Id $PID).Parent.Id
$counterFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "claude-compact-$ppid")

$count = 0
if (Test-Path $counterFile) {
    $content = Get-Content $counterFile -ErrorAction SilentlyContinue
    [int]::TryParse($content, [ref]$count) | Out-Null
}
$count++
Set-Content -Path $counterFile -Value $count

if ($count -eq $threshold) {
    Write-Error "[team-plugin] $count edits this session — consider running /compact before continuing to a new phase."
} elseif ($count -gt $threshold) {
    $over = $count - $threshold
    if ($over % 25 -eq 0) {
        Write-Error "[team-plugin] $count edits this session — good checkpoint for /compact if context feels stale."
    }
}

exit 0
