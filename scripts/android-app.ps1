[CmdletBinding()]
param(
    [string]$Device,
    [switch]$NoLaunch,
    [switch]$NoMetro
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$appRoot = Join-Path $workspaceRoot "WatcheRobot_app"
$androidRoot = Join-Path $appRoot "android"
$gradlew = Join-Path $androidRoot "gradlew.bat"
$packageName = "com.watcherrobotapp.debug"

if (-not (Test-Path $gradlew)) {
    throw "Android Gradle wrapper not found: $gradlew"
}

if (-not (Test-Path (Join-Path $appRoot "node_modules\.bin\react-native.cmd"))) {
    Write-Host "Dependencies missing; running yarn install in WatcheRobot_app..."
    & yarn --cwd $appRoot install
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function Test-TcpPort {
    param([Parameter(Mandatory = $true)][int]$Port)

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $async = $client.BeginConnect("127.0.0.1", $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(500)) {
            return $false
        }

        $client.EndConnect($async)
        return $true
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

function Wait-TcpPort {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter(Mandatory = $true)][int]$TimeoutSec,
        [string]$ProcessName,
        [System.Diagnostics.Process]$Process,
        [string]$StdoutLog,
        [string]$StderrLog
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if (Test-TcpPort -Port $Port) {
            return
        }

        if ($Process -and $Process.HasExited) {
            $stdoutTail = if ($StdoutLog -and (Test-Path $StdoutLog)) {
                (Get-Content -LiteralPath $StdoutLog -Tail 40) -join [Environment]::NewLine
            }
            else {
                ""
            }
            $stderrTail = if ($StderrLog -and (Test-Path $StderrLog)) {
                (Get-Content -LiteralPath $StderrLog -Tail 40) -join [Environment]::NewLine
            }
            else {
                ""
            }
            throw "$ProcessName exited before tcp:$Port became ready. stdout=$StdoutLog stderr=$StderrLog`n$stdoutTail`n$stderrTail"
        }

        Start-Sleep -Milliseconds 500
    }

    throw "Timed out waiting for $ProcessName on tcp:$Port after ${TimeoutSec}s."
}

function Start-MetroIfNeeded {
    if ($NoMetro) {
        Write-Host "Metro   : skipped"
        return
    }

    if (Test-TcpPort -Port 8081) {
        Write-Host "Metro   : already running on 127.0.0.1:8081"
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $stdoutLog = Join-Path $env:TEMP "watcher-app-metro-$timestamp.out.log"
    $stderrLog = Join-Path $env:TEMP "watcher-app-metro-$timestamp.err.log"
    $yarnCommand = Get-Command "yarn.cmd" -ErrorAction SilentlyContinue
    if (-not $yarnCommand) {
        $yarnCommand = Get-Command "yarn" -ErrorAction Stop
    }
    $yarn = $yarnCommand.Source

    Write-Host "Metro   : starting react-native start"
    $metro = Start-Process -FilePath $yarn `
        -ArgumentList @("--cwd", $appRoot, "start") `
        -WindowStyle Hidden `
        -PassThru `
        -RedirectStandardOutput $stdoutLog `
        -RedirectStandardError $stderrLog

    Wait-TcpPort -Port 8081 -TimeoutSec 45 -ProcessName "Metro" -Process $metro -StdoutLog $stdoutLog -StderrLog $stderrLog
    Write-Host "Metro   : ready on 127.0.0.1:8081 (pid=$($metro.Id))"
    Write-Host "MetroLog: $stdoutLog"
}

Start-MetroIfNeeded

if (-not $Device) {
    $devices = @(
        adb devices |
            Select-String "^\S+\s+device$" |
            ForEach-Object { ($_.Line -split "\s+")[0] }
    )

    if ($devices.Count -eq 0) {
        throw "No online Android device found. Connect a phone or start an emulator, then run yarn android again."
    }

    $Device = $devices[0]
    if ($devices.Count -gt 1) {
        Write-Host "Multiple Android devices online; using $Device. Pass -Device <serial> to override."
    }
}

Write-Host "Project : $appRoot"
Write-Host "Device  : $Device"
Write-Host "Install : gradlew app:installDebug"

Push-Location $androidRoot
try {
    & $gradlew "app:installDebug"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}

adb -s $Device reverse tcp:8081 tcp:8081 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warning "adb reverse tcp:8081 failed; the app may not reach Metro over USB."
}

if (-not $NoLaunch) {
    Write-Host "Launch  : $packageName"
    adb -s $Device shell monkey -p $packageName -c android.intent.category.LAUNCHER 1
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
