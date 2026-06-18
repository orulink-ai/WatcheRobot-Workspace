$ErrorActionPreference = "Stop"

$validateScript = Join-Path $PSScriptRoot "validate-app-center-catalog.ps1"
$smokeScript = Join-Path $PSScriptRoot "test-app-center-sample-server.ps1"
$sampleScript = Join-Path $PSScriptRoot "app-center-sample-server.ps1"

foreach ($script in @($validateScript, $smokeScript, $sampleScript)) {
    if (-not (Test-Path -LiteralPath $script)) {
        throw "Required App.Center helper script not found: $script"
    }
}

Write-Host "== App.Center catalog validation ==" -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $validateScript
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "== App.Center local HTTP smoke test ==" -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $smokeScript
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "== App.Center sample URL dry run ==" -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $sampleScript -DryRun
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "App.Center local checks passed." -ForegroundColor Green

