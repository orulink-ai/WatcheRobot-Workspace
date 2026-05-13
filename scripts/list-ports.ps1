[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$python = Get-Command python -ErrorAction SilentlyContinue
if ($python) {
    & $python.Source -c "import serial.tools.list_ports; [print(f'{p.device}`t{p.description}`t{p.hwid}') for p in serial.tools.list_ports.comports()]"
    exit $LASTEXITCODE
}

[System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object { [int]($_ -replace '^COM', '') }
