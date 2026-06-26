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

function Get-JsonString {
    param(
        [object]$Object,
        [string[]]$Keys
    )

    foreach ($key in $Keys) {
        if ($null -ne $Object.PSObject.Properties[$key]) {
            $value = $Object.PSObject.Properties[$key].Value
            if ($value -is [string] -and -not [string]::IsNullOrWhiteSpace($value)) {
                return $value
            }
        }
    }
    return $null
}

try {
    Write-Host ""
    Write-Host "Starting temporary App.Center sample server on 127.0.0.1:$Port..." -ForegroundColor Cyan
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
    server = ThreadingHTTPServer(("127.0.0.1", $Port), AppCenterSampleHandler)
    server.serve_forever()
"@
    $serverScriptPath = Join-Path ([System.IO.Path]::GetTempPath()) "watcher-appcenter-smoke-server-$Port.py"
    Set-Content -LiteralPath $serverScriptPath -Value $serverScript -Encoding UTF8

    $process = Start-Process -FilePath $python.Source `
        -ArgumentList @($serverScriptPath) `
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

    Write-Host "Fetching $appsUrl"
    $apps = Invoke-WebRequest -Uri $appsUrl -UseBasicParsing -TimeoutSec 5
    if ($apps.StatusCode -ne 200) {
        throw "apps.json returned HTTP $($apps.StatusCode)"
    }
    if ($apps.Headers["Access-Control-Allow-Origin"] -ne "*") {
        throw "apps.json response is missing Access-Control-Allow-Origin: *"
    }
    $appsJson = Convert-WebContentToText $apps.Content | ConvertFrom-Json
    if ($null -eq $appsJson) {
        throw "apps.json did not parse as JSON."
    }
    $catalogApps = $null
    if ($appsJson -is [array]) {
        $catalogApps = $appsJson
    } elseif ($null -ne $appsJson.PSObject.Properties["apps"]) {
        $catalogApps = $appsJson.apps
    } elseif ($null -ne $appsJson.PSObject.Properties["data"]) {
        $catalogApps = $appsJson.data
    }
    if ($null -eq $catalogApps) {
        throw "apps.json must be an array or an object with apps/data array."
    }
    if ($catalogApps -isnot [array]) {
        $catalogApps = @($catalogApps)
    }
    if ($catalogApps.Count -eq 0) {
        throw "apps.json contains no apps."
    }

    foreach ($app in $catalogApps) {
        $name = Get-JsonString $app @("name", "appName", "title")
        $id = Get-JsonString $app @("id", "appId", "key")
        $packageUrl = Get-JsonString $app @("packageUrl", "downloadUrl", "appUrl", "url")
        if (-not $name) {
            throw "Catalog app is missing name/appName/title."
        }
        if (-not $packageUrl) {
            throw "Catalog app '$name' is missing packageUrl/downloadUrl/appUrl/url."
        }

        $pkgUrl = if ($packageUrl -match "^https?://") {
            $packageUrl
        } else {
            "http://127.0.0.1:$Port/$packageUrl"
        }

        Write-Host "Fetching $pkgUrl"
        $pkg = Invoke-WebRequest -Uri $pkgUrl -UseBasicParsing -TimeoutSec 5
        if ($pkg.StatusCode -ne 200) {
            throw "Package for '$name' returned HTTP $($pkg.StatusCode): $pkgUrl"
        }
        if ($pkg.Headers["Access-Control-Allow-Origin"] -ne "*") {
            throw "Package response is missing Access-Control-Allow-Origin: * for '$name': $pkgUrl"
        }
        $pkgJson = Convert-WebContentToText $pkg.Content | ConvertFrom-Json
        $pkgName = Get-JsonString $pkgJson @("name", "title", "appName")
        $pkgId = Get-JsonString $pkgJson @("id", "appId", "app_id")
        if (-not $pkgName) {
            throw "Package for '$name' did not parse as a valid app-pack manifest: $pkgUrl"
        }
        if ($id -and $pkgId -and $pkgId -ne $id) {
            throw "Package id '$pkgId' does not match catalog id '$id': $pkgUrl"
        }
    }

    Write-Host ""
    Write-Host "App.Center sample HTTP smoke test passed." -ForegroundColor Green
} finally {
    if ($null -ne $process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
    if ($serverScriptPath -and (Test-Path -LiteralPath $serverScriptPath)) {
        Remove-Item -LiteralPath $serverScriptPath -Force -ErrorAction SilentlyContinue
    }
}
