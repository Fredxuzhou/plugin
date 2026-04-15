# PRETTIER FORMAT HOOK (PowerShell)
# Runs after every Write tool call on Windows. If Prettier is installed
# in the project or globally, auto-formats the written file in place.
# Silently skips if Prettier is not available.
#
# Supported extensions: js jsx ts tsx css scss html json md yaml yml

$inputJson = $input -join ""
$filePath = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $filePath = [string]$data.tool_input.file_path
} catch {
    $filePath = ""
}

if ([string]::IsNullOrEmpty($filePath) -or -not (Test-Path $filePath)) {
    exit 0
}

$ext = [System.IO.Path]::GetExtension($filePath).TrimStart('.').ToLower()
$supported = @('js', 'jsx', 'ts', 'tsx', 'css', 'scss', 'html', 'json', 'md', 'yaml', 'yml')
if ($ext -notin $supported) {
    exit 0
}

# Try local prettier first, then global
$localPrettier = "node_modules\.bin\prettier.cmd"
if (Test-Path $localPrettier) {
    & $localPrettier --write $filePath 2>$null
} else {
    $prettierCmd = Get-Command prettier -ErrorAction SilentlyContinue
    if ($prettierCmd) {
        & prettier --write $filePath 2>$null
    }
}

exit 0
