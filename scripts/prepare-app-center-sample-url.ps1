param(
    [int]$Port = 8767,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$validator = Join-Path $PSScriptRoot "validate-app-center-catalog.ps1"
$setUrlScript = Join-Path $PSScriptRoot "set-app-center-url.ps1"

if (-not (Test-Path -LiteralPath $validator)) {
    throw "App.Center catalog validator not found: $validator"
}
if (-not (Test-Path -LiteralPath $setUrlScript)) {
    throw "App.Center URL setter not found: $setUrlScript"
}

Write-Host "Validating App.Center sample catalog..." -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $validator
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$lanAddress = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown" -and
        (
            $_.IPAddress -like "10.*" -or
            $_.IPAddress -like "192.168.*" -or
            $_.IPAddress -match "^172\.(1[6-9]|2[0-9]|3[0-1])\."
        )
    } |
    Select-Object -ExpandProperty IPAddress -First 1

if (-not $lanAddress) {
    throw "No private LAN IPv4 address found. Run yarn appcenter:sample:dryrun and choose the reachable device LAN IP manually."
}

$url = "http://${lanAddress}:$Port/apps.json"

Write-Host ""
Write-Host "Selected App.Center sample URL:" -ForegroundColor Yellow
Write-Host "  $url"
Write-Host ""

$argsList = @($url)
if ($DryRun) {
    $argsList += "-DryRun"
}

& powershell -NoProfile -ExecutionPolicy Bypass -File $setUrlScript @argsList
exit $LASTEXITCODE

