# QUALITY GATE HOOK (PowerShell)
# Runs after every Edit and Write tool call on Windows. Performs a lightweight
# syntax/lint check on the modified file using whatever tooling is available.
# Never blocks — warns via stderr only.
#
# Supported checks (skipped silently if tool not installed):
#   JS/TS   → eslint (if available)
#   Python  → python3 syntax check
#   JSON    → ConvertFrom-Json validation

$inputJson = $input -join ""
$filePath = ""
try {
    $data = $inputJson | ConvertFrom-Json
    $filePath = [string]$data.tool_input.file_path
    if ([string]::IsNullOrEmpty($filePath)) {
        $filePath = [string]$data.file_path
    }
} catch {
    $filePath = ""
}

if ([string]::IsNullOrEmpty($filePath) -or -not (Test-Path $filePath)) {
    exit 0
}

$ext = [System.IO.Path]::GetExtension($filePath).TrimStart('.').ToLower()

switch ($ext) {
    { $_ -in @('js', 'jsx', 'ts', 'tsx') } {
        $eslint = Get-Command eslint -ErrorAction SilentlyContinue
        if ($eslint) {
            $result = & eslint --no-eslintrc --rule '{"no-undef":1}' $filePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "[team-plugin] quality-gate: eslint found issues in ${filePath}:"
                $result | Select-Object -First 20 | ForEach-Object { Write-Error $_ }
            }
        }
    }
    'py' {
        $py = Get-Command python3 -ErrorAction SilentlyContinue
        if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
        if ($py) {
            $result = & $py.Name -m py_compile $filePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "[team-plugin] quality-gate: Python syntax error in ${filePath}:"
                Write-Error $result
            }
        }
    }
    'json' {
        try {
            $content = Get-Content $filePath -Raw
            $content | ConvertFrom-Json | Out-Null
        } catch {
            Write-Error "[team-plugin] quality-gate: JSON syntax error in ${filePath}: $_"
        }
    }
}

exit 0
