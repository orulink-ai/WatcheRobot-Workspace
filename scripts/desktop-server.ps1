[CmdletBinding()]
param(
    [int]$ReadyTimeoutSec = 30,
    [switch]$KeepServerRunning,
    [switch]$SkipDesktop
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$serverRoot = Join-Path $workspaceRoot "WatcheRobot_server"
$desktopRoot = Join-Path $workspaceRoot "WatcheRobot_client\Watcher Desktop App"

if (-not (Test-Path $serverRoot)) {
    throw "Server repository not found: $serverRoot"
}
if (-not (Test-Path $desktopRoot)) {
    throw "Desktop repository not found: $desktopRoot"
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

function Test-WatcherServerReady {
    try {
        $response = Invoke-WebRequest -Uri "http://127.0.0.1:8766/api/admin/health" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
            return $true
        }
    }
    catch {
    }

    return Test-TcpPort -Port 8765
}

function Wait-WatcherServerReady {
    param(
        [Parameter(Mandatory = $true)][System.Diagnostics.Process]$Process,
        [Parameter(Mandatory = $true)][int]$TimeoutSec,
        [Parameter(Mandatory = $true)][string]$StdoutLog,
        [Parameter(Mandatory = $true)][string]$StderrLog
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        if (Test-WatcherServerReady) {
            return
        }

        if ($Process.HasExited) {
            $stdoutTail = if (Test-Path $StdoutLog) { (Get-Content -LiteralPath $StdoutLog -Tail 40) -join [Environment]::NewLine } else { "" }
            $stderrTail = if (Test-Path $StderrLog) { (Get-Content -LiteralPath $StderrLog -Tail 40) -join [Environment]::NewLine } else { "" }
            throw "watcher-server exited before becoming ready. stdout=$StdoutLog stderr=$StderrLog`n$stdoutTail`n$stderrTail"
        }

        Start-Sleep -Milliseconds 500
    }

    throw "watcher-server did not become ready within ${TimeoutSec}s. stdout=$StdoutLog stderr=$StderrLog"
}

function Get-WatcherDesktopProcessIds {
    $desktopExeRoot = Join-Path $desktopRoot "src-tauri\target"
    $ids = @()

    foreach ($process in @(Get-Process -Name "watcher-desktop" -ErrorAction SilentlyContinue)) {
        try {
            if ($process.Path -and $process.Path.StartsWith($desktopExeRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $ids += [int]$process.Id
            }
        }
        catch {
        }
    }

    return @($ids | Sort-Object -Unique)
}

function Wait-ForWatcherDesktopExit {
    param([int[]]$InitialProcessIds)

    $initialLookup = @{}
    foreach ($id in $InitialProcessIds) {
        $initialLookup[[int]$id] = $true
    }

    $currentIds = @(
        Get-WatcherDesktopProcessIds |
            Where-Object { -not $initialLookup.ContainsKey([int]$_) }
    )
    if ($currentIds.Count -eq 0) {
        return
    }

    Write-Host "Watcher Desktop is running. Keeping watcher-server alive until the desktop window exits..."
    while ($true) {
        $currentIds = @(
            Get-WatcherDesktopProcessIds |
                Where-Object { -not $initialLookup.ContainsKey([int]$_) }
        )
        if ($currentIds.Count -eq 0) {
            return
        }

        Start-Sleep -Seconds 1
    }
}

$startedServer = $null
$exitCode = 0

try {
    if (Test-WatcherServerReady) {
        Write-Host "watcher-server is already running on 127.0.0.1:8765/8766."
    }
    else {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $stdoutLog = Join-Path $env:TEMP "watcher-server-desktop-$timestamp.out.log"
        $stderrLog = Join-Path $env:TEMP "watcher-server-desktop-$timestamp.err.log"
        $python = (Get-Command "python" -ErrorAction Stop).Source

        Write-Host "Starting watcher-server..."
        $startedServer = Start-Process -FilePath $python `
            -ArgumentList @("main.py") `
            -WorkingDirectory $serverRoot `
            -WindowStyle Hidden `
            -PassThru `
            -RedirectStandardOutput $stdoutLog `
            -RedirectStandardError $stderrLog

        Wait-WatcherServerReady -Process $startedServer -TimeoutSec $ReadyTimeoutSec -StdoutLog $stdoutLog -StderrLog $stderrLog
        Write-Host "watcher-server is ready. pid=$($startedServer.Id)"
        Write-Host "server logs: $stdoutLog"
    }

    if ($SkipDesktop) {
        exit 0
    }

    Write-Host "Starting Watcher Desktop..."
    $desktopProcessIdsBefore = @(Get-WatcherDesktopProcessIds)
    & npm --prefix $desktopRoot run dev
    $exitCode = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    Wait-ForWatcherDesktopExit -InitialProcessIds $desktopProcessIdsBefore
}
finally {
    if ($startedServer -and -not $KeepServerRunning) {
        try {
            if (-not $startedServer.HasExited) {
                Write-Host "Stopping watcher-server started by this command..."
                Stop-Process -Id $startedServer.Id -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
        }
    }
}

exit $exitCode
