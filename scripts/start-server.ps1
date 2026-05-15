[CmdletBinding()]
param(
    [switch]$UseStartScript
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$serverRoot = Join-Path $workspaceRoot "WatcheRobot_server"

if (-not (Test-Path $serverRoot)) {
    throw "Server repository not found: $serverRoot"
}

Push-Location $serverRoot
$exitCode = 0
try {
    if ($UseStartScript) {
        & .\start.bat
    }
    else {
        & python main.py
    }
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

exit $exitCode
