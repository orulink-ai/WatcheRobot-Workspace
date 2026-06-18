param(
    [int]$Port = 8767
)

$ErrorActionPreference = "Stop"

$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$sampleDir = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3\app_center_sample"
$validator = Join-Path $PSScriptRoot "validate-app-center-catalog.ps1"

if (-not (Test-Path -LiteralPath $sampleDir)) {
    throw "App.Center sample directory not found: $sampleDir"
}
if (-not (Test-Path -LiteralPath $validator)) {
    throw "App.Center catalog validator not found: $validator"
}

Write-Host "Validating App.Center sample catalog..." -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $validator -CatalogDir $sampleDir
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$python = Get-Command python -ErrorAction SilentlyContinue
if ($null -eq $python) {
    $python = Get-Command py -ErrorAction SilentlyContinue
}
if ($null -eq $python) {
    throw "Python was not found in PATH. Install Python or add it to PATH before running the smoke test."
}

$stdoutLogPath = Join-Path ([System.IO.Path]::GetTempPath()) "watcher-appcenter-http-$Port.out.log"
$stderrLogPath = Join-Path ([System.IO.Path]::GetTempPath()) "watcher-appcenter-http-$Port.err.log"
$process = $null

function Convert-WebContentToText {
    param([object]$Content)

    if ($Content -is [byte[]]) {
        return [System.Text.Encoding]::UTF8.GetString($Content)
    }
    return [string]$Content
}

try {
    Write-Host ""
    Write-Host "Starting temporary App.Center sample server on 127.0.0.1:$Port..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $python.Source `
        -ArgumentList @("-m", "http.server", "$Port", "--bind", "127.0.0.1") `
        -WorkingDirectory $sampleDir `
        -RedirectStandardOutput $stdoutLogPath `
        -RedirectStandardError $stderrLogPath `
        -WindowStyle Hidden `
        -PassThru

    Start-Sleep -Milliseconds 900
    if ($process.HasExited) {
        $stdoutLog = if (Test-Path -LiteralPath $stdoutLogPath) { Get-Content -LiteralPath $stdoutLogPath -Raw } else { "" }
        $stderrLog = if (Test-Path -LiteralPath $stderrLogPath) { Get-Content -LiteralPath $stderrLogPath -Raw } else { "" }
        $log = "STDOUT:`n$stdoutLog`nSTDERR:`n$stderrLog"
        throw "Temporary sample server exited early. Log:`n$log"
    }

    $appsUrl = "http://127.0.0.1:$Port/apps.json"
    $pkgUrl = "http://127.0.0.1:$Port/espnow_remote.pkg"

    Write-Host "Fetching $appsUrl"
    $apps = Invoke-WebRequest -Uri $appsUrl -UseBasicParsing -TimeoutSec 5
    if ($apps.StatusCode -ne 200) {
        throw "apps.json returned HTTP $($apps.StatusCode)"
    }
    $appsJson = Convert-WebContentToText $apps.Content | ConvertFrom-Json
    if ($null -eq $appsJson) {
        throw "apps.json did not parse as JSON."
    }

    Write-Host "Fetching $pkgUrl"
    $pkg = Invoke-WebRequest -Uri $pkgUrl -UseBasicParsing -TimeoutSec 5
    if ($pkg.StatusCode -ne 200) {
        throw "espnow_remote.pkg returned HTTP $($pkg.StatusCode)"
    }
    $pkgJson = Convert-WebContentToText $pkg.Content | ConvertFrom-Json
    if ($null -eq $pkgJson -or $null -eq $pkgJson.PSObject.Properties["name"] -or
        [string]::IsNullOrWhiteSpace([string]$pkgJson.PSObject.Properties["name"].Value)) {
        throw "espnow_remote.pkg did not parse as a valid app-pack manifest."
    }

    Write-Host ""
    Write-Host "App.Center sample HTTP smoke test passed." -ForegroundColor Green
} finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}
