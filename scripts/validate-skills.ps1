[CmdletBinding()]
param(
    [string]$ValidatorPath = "$env:USERPROFILE\.codex\skills\.system\skill-creator\scripts\quick_validate.py"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$skillsRoot = Join-Path $workspaceRoot ".agents\skills"

if (-not (Test-Path $skillsRoot)) {
    throw "Skills directory not found: $skillsRoot"
}
if (-not (Test-Path $ValidatorPath)) {
    throw "Skill validator not found: $ValidatorPath"
}

$env:PYTHONUTF8 = "1"
$failed = $false

Get-ChildItem $skillsRoot -Directory | Sort-Object Name | ForEach-Object {
    Write-Host "== $($_.Name) =="
    & python $ValidatorPath $_.FullName
    if ($LASTEXITCODE -ne 0) {
        $failed = $true
    }
}

if ($failed) {
    exit 1
}

Write-Host "all skills valid"
