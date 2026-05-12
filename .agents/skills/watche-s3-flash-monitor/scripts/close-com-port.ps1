[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Port,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize-PortName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PortName
    )

    if ($PortName -match '^COM\d+$') {
        return $PortName.ToUpperInvariant()
    }

    return $PortName
}

function Get-HandleExecutablePath {
    $candidates = @()

    try {
        $command = Get-Command handle.exe -ErrorAction SilentlyContinue
        if ($command) {
            $candidates += $command.Source
        }
    }
    catch {
    }

    $candidates += @(
        "C:\SysinternalsSuite\handle.exe",
        "C:\Tools\Sysinternals\handle.exe",
        "C:\Program Files\Sysinternals\handle.exe",
        "C:\Program Files (x86)\Sysinternals\handle.exe"
    )

    foreach ($candidate in $candidates | Select-Object -Unique) {
        if ($candidate -and (Test-Path $candidate)) {
            return $candidate
        }
    }

    return $null
}

function Get-PortOwnersViaHandle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PortName
    )

    $handleExe = Get-HandleExecutablePath
    if (-not $handleExe) {
        return @()
    }

    $owners = New-Object System.Collections.Generic.List[object]
    $queries = @($PortName, "\\.\$PortName")

    foreach ($query in $queries | Select-Object -Unique) {
        $output = & $handleExe -a -nobanner $query 2>$null
        foreach ($line in $output) {
            if ($line -match '^(?<name>\S+)\s+pid:\s+(?<pid>\d+)\s+') {
                $owners.Add([pscustomobject]@{
                    Id      = [int]$Matches.pid
                    Name    = $Matches.name
                    Reason  = "handle.exe"
                    Command = ""
                })
            }
        }
    }

    return $owners |
        Sort-Object Id -Unique
}

function Get-PortOwnersViaProcessScan {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PortName,

        [System.Collections.Generic.HashSet[int]]$ExcludedIds
    )

    $windowTitles = @{}
    Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.MainWindowTitle) {
            $windowTitles[$_.Id] = $_.MainWindowTitle
        }
    }

    $namePattern = 'python|pwsh|powershell|cmd|openocd|putty|tterm|securecrt|arduino|coolterm|mobaxterm|code'
    $hintPattern = 'idf\.py|idf_monitor|esp_idf_monitor|esptool|monitor|miniterm|serial'
    $portPattern = [regex]::Escape($PortName)

    $matches = foreach ($process in Get-CimInstance Win32_Process) {
        $processId = [int]$process.ProcessId
        if ($ExcludedIds -and $ExcludedIds.Contains($processId)) {
            continue
        }

        $commandLine = [string]$process.CommandLine
        $windowTitle = ""
        if ($windowTitles.ContainsKey($processId)) {
            $windowTitle = [string]$windowTitles[$processId]
        }

        $commandMatchesPort = $commandLine -and $commandLine -match $portPattern
        $windowMatchesPort = $windowTitle -and $windowTitle -match $portPattern
        $looksLikeSerialTool = $process.Name -match $namePattern -and $commandLine -and $commandLine -match $hintPattern

        if ($commandMatchesPort -or $windowMatchesPort -or ($looksLikeSerialTool -and $commandMatchesPort)) {
            [pscustomobject]@{
                Id      = $processId
                Name    = [string]$process.Name
                Reason  = if ($commandMatchesPort) { "command-line" } elseif ($windowMatchesPort) { "window-title" } else { "serial-tool" }
                Command = $commandLine
            }
        }
    }

    return $matches |
        Sort-Object Id -Unique
}

function Test-PortAvailability {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PortName
    )

    $serialPort = [System.IO.Ports.SerialPort]::new($PortName, 115200)
    try {
        $serialPort.Open()
        return [pscustomobject]@{
            IsAvailable = $true
            Error       = ""
        }
    }
    catch {
        return [pscustomobject]@{
            IsAvailable = $false
            Error       = $_.Exception.Message
        }
    }
    finally {
        if ($serialPort.IsOpen) {
            $serialPort.Close()
        }
        $serialPort.Dispose()
    }
}

function Get-ExcludedProcessIds {
    $excluded = [System.Collections.Generic.HashSet[int]]::new()
    $currentId = $PID

    while ($currentId -gt 0 -and -not $excluded.Contains($currentId)) {
        $null = $excluded.Add($currentId)
        $process = Get-CimInstance Win32_Process -Filter "ProcessId = $currentId" -ErrorAction SilentlyContinue
        if (-not $process) {
            break
        }

        $parentId = [int]$process.ParentProcessId
        if ($parentId -le 0) {
            break
        }

        $currentId = $parentId
    }

    return $excluded
}

$resolvedPort = Normalize-PortName -PortName $Port
$excludedIds = Get-ExcludedProcessIds
$owners = @()
$owners += Get-PortOwnersViaHandle -PortName $resolvedPort
$owners += Get-PortOwnersViaProcessScan -PortName $resolvedPort -ExcludedIds $excludedIds
$owners = @(
    $owners |
        Where-Object { -not $excludedIds.Contains([int]$_.Id) } |
        Sort-Object Id -Unique
)

if (-not $owners -or $owners.Count -eq 0) {
    Write-Host "No matching process found for $resolvedPort."
} else {
    Write-Host "Found $($owners.Count) process(es) using or targeting ${resolvedPort}:"
    $owners | Format-Table Id, Name, Reason -AutoSize

    foreach ($owner in $owners) {
        if ($DryRun) {
            Write-Host "Dry run: would stop PID $($owner.Id) ($($owner.Name))"
            continue
        }

        try {
            Stop-Process -Id $owner.Id -Force -ErrorAction Stop
            Write-Host "Stopped PID $($owner.Id) ($($owner.Name))"
        }
        catch {
            Write-Warning "Failed to stop PID $($owner.Id) ($($owner.Name)): $($_.Exception.Message)"
        }
    }
}

if ($DryRun) {
    exit 0
}

Start-Sleep -Milliseconds 700
$portStatus = Test-PortAvailability -PortName $resolvedPort
if (-not $portStatus.IsAvailable) {
    throw "Port $resolvedPort is still busy or unavailable after cleanup: $($portStatus.Error)"
}

Write-Host "Port $resolvedPort is available."
