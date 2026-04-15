# PRE-COMPACT HOOK (PowerShell)
# Runs before Claude Code compacts the conversation context on Windows.
# Appends a timestamped entry to ~/.claude/compaction-log.txt so you
# can track when and how often compaction occurs.
# Never blocks compaction — always exits 0.

$logFile = Join-Path $HOME ".claude\compaction-log.txt"
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Ensure log directory exists
$logDir = Split-Path $logFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

Add-Content -Path $logFile -Value "[$timestamp] Context compaction triggered" -ErrorAction SilentlyContinue

exit 0
