[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PytestArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$serverRoot = Join-Path $workspaceRoot "WatcheRobot_server"

if (-not (Test-Path $serverRoot)) {
    throw "Server repository not found: $serverRoot"
}

if (-not $PytestArgs -or $PytestArgs.Count -eq 0) {
    $PytestArgs = @("tests", "-q")
}

Push-Location $serverRoot
$exitCode = 0
try {
    & python -m pytest @PytestArgs
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

exit $exitCode
