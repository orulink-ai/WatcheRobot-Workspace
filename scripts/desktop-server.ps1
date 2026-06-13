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

function Add-PathIfMissing {
    param([Parameter(Mandatory=$true)][string]$PathToAdd)

    $pathSegments = $env:PATH -split ';'
    if ($pathSegments -notcontains $PathToAdd) {
        $env:PATH = "$PathToAdd;$env:PATH"
    }
}

function Ensure-Cargo {
    $cargoBin = Join-Path $env:USERPROFILE ".cargo\bin"
    if (Test-Path $cargoBin) {
        Add-PathIfMissing $cargoBin
    }

    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        throw "Cargo not found. Please install Rust (e.g. 'winget install Rustlang.Rustup') and reopen the terminal."
    }
}

function Ensure-VSLinker {
    if (Get-Command link.exe -ErrorAction SilentlyContinue) {
        return
    }

    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $installations = & $vswhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format json | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($installations) {
            $installPath = $installations[0].installationPath
            $toolchainRoot = Join-Path (Join-Path $installPath "VC\Tools\MSVC") "*"
            $latestToolchain = Get-ChildItem -Path $toolchainRoot -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
            if ($latestToolchain) {
                foreach ($arch in @("Hostx64\x64", "Hostx64\x86", "Hostx86\x64", "Hostx86\x86")) {
                    $candidate = Join-Path $latestToolchain.FullName ("bin\" + $arch + "\link.exe")
                    if (Test-Path $candidate) {
                        Add-PathIfMissing (Split-Path $candidate)
                        break
                    }
                }
            }
        }
    }

    if (-not (Get-Command link.exe -ErrorAction SilentlyContinue)) {
        throw "MSVC linker not found. Please install Visual Studio Build Tools with C++ build tools (MSVC)."
    }
}

Ensure-Cargo
Ensure-VSLinker

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

function Get-WatcherServerPython {
    $isWindows = $env:OS -eq "Windows_NT"
    $isMacOS = -not $isWindows -and $PSVersionTable.ContainsKey("Platform") -and $PSVersionTable.Platform -eq "Unix" -and (uname -s) -eq "Darwin"

    $platformResourceName = if ($isWindows) {
        "win32-x64"
    }
    elseif ($isMacOS) {
        "darwin-arm64"
    }
    else {
        "linux-x64"
    }

    $configuredVenv = [string]$env:WATCHER_SERVER_DEV_VENV
    $venvRoot = if ($configuredVenv.Trim()) {
        $configuredVenv.Trim()
    }
    else {
        Join-Path $serverRoot ".venv-dev-$platformResourceName"
    }
    $venvPython = if ($isWindows) {
        Join-Path $venvRoot "Scripts\python.exe"
    }
    else {
        Join-Path $venvRoot "bin/python"
    }

    if (Test-Path $venvPython) {
        return (Resolve-Path -LiteralPath $venvPython).Path
    }

    return (Get-Command "python" -ErrorAction Stop).Source
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
        $python = Get-WatcherServerPython

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
