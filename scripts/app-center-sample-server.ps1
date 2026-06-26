param(
    [int]$Port = 8767,

    [switch]$SkipValidate,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sampleDir = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3\app_center_sample"
$appsJson = Join-Path $sampleDir "apps.json"

if (-not (Test-Path -LiteralPath $appsJson)) {
    throw "App.Center sample apps.json not found: $appsJson"
}

if (-not $SkipValidate) {
    $validator = Join-Path $PSScriptRoot "validate-app-center-catalog.ps1"
    if (-not (Test-Path -LiteralPath $validator)) {
        throw "App.Center catalog validator not found: $validator"
    }

    Write-Host "Validating App.Center sample catalog..." -ForegroundColor Cyan
    & powershell -NoProfile -ExecutionPolicy Bypass -File $validator -CatalogDir $sampleDir
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    Write-Host ""
}

$python = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if ($null -eq $python) {
    throw "Python was not found in PATH. Install Python or add it to PATH before starting the sample server."
}

$addresses = @(Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Select-Object -ExpandProperty IPAddress -Unique)

$lanAddresses = @($addresses | Where-Object {
        $_ -like "10.*" -or
        $_ -like "192.168.*" -or
        $_ -match "^172\.(1[6-9]|2[0-9]|3[0-1])\."
    })
$otherAddresses = @($addresses | Where-Object { $lanAddresses -notcontains $_ })

Write-Host ""
Write-Host "App.Center sample catalog server" -ForegroundColor Cyan
Write-Host "Directory: $sampleDir"
Write-Host "Port     : $Port"
Write-Host ""
Write-Host "Set CONFIG_APP_CENTER_REMOTE_LIST_URL to one of these LAN URLs:" -ForegroundColor Yellow

foreach ($address in $lanAddresses) {
    Write-Host "  http://${address}:$Port/apps.json"
}
if (-not $lanAddresses) {
    Write-Host "  http://<computer-lan-ip>:$Port/apps.json"
}

if ($otherAddresses) {
    Write-Host ""
    Write-Host "Other IPv4 addresses, usually VPN/virtual adapters:" -ForegroundColor DarkYellow
    foreach ($address in $otherAddresses) {
        Write-Host "  http://${address}:$Port/apps.json"
    }
}

Write-Host ""
Write-Host "Press Ctrl+C to stop the server."
Write-Host ""

if ($DryRun) {
    Write-Host "DryRun: server not started." -ForegroundColor Yellow
    exit 0
}

Push-Location $sampleDir
try {
    $serverScript = @"
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

class AppCenterSampleHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Accept")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", $Port), AppCenterSampleHandler)
    server.serve_forever()
"@
    $serverScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) "watcher-appcenter-sample-server-$Port.py"
    Set-Content -LiteralPath $serverScriptPath -Value $serverScript -Encoding UTF8
    try {
        & $python.Source $serverScriptPath
    } finally {
        Remove-Item -LiteralPath $serverScriptPath -Force -ErrorAction SilentlyContinue
    }
} finally {
    Pop-Location
}
