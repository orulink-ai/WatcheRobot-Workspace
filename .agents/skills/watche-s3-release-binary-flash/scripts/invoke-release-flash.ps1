[CmdletBinding()]
param(
    [string]$Port,

    [string]$Zip,

    [string]$RepoRoot,

    [switch]$Monitor,

    [int]$MonitorSeconds = 15,

    [int]$Baud = 460800,

    [int]$MonitorBaud = 115200,

    [switch]$InstallDeps,

    [switch]$ListReleases,

    [switch]$ListPorts,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize-PortName {
    param([string]$Value)

    if (-not $Value) {
        return $null
    }

    $trimmed = $Value.Trim()
    if ($trimmed -match '^\d+$') {
        return "COM$trimmed"
    }
    if ($trimmed -match '^COM\d+$') {
        return $trimmed.ToUpperInvariant()
    }
    return $trimmed
}

function Test-RepoRoot {
    param([string]$Path)

    if (-not $Path) {
        return $false
    }

    return (Test-Path (Join-Path $Path "tools\flash-release.cmd")) -and
        (Test-Path (Join-Path $Path "firmware\s3\release"))
}

function Find-RepoRoot {
    param([string]$RequestedRoot)

    if ($RequestedRoot) {
        $resolved = (Resolve-Path $RequestedRoot).Path
        if (Test-RepoRoot -Path $resolved) {
            return $resolved
        }
        throw "Not a WatcheRobot-Firmware repo root: $resolved"
    }

    try {
        $gitRoot = (& git rev-parse --show-toplevel 2>$null).Trim()
        if ($gitRoot -and (Test-RepoRoot -Path $gitRoot)) {
            return $gitRoot
        }
    }
    catch {
    }

    $current = (Get-Location).Path
    while ($current) {
        if (Test-RepoRoot -Path $current) {
            return $current
        }

        $parent = Split-Path -Parent $current
        if (-not $parent -or $parent -eq $current) {
            break
        }
        $current = $parent
    }

    throw "Unable to locate WatcheRobot-Firmware repo root. Pass -RepoRoot explicitly."
}

function Resolve-ZipPath {
    param(
        [string]$Repo,
        [string]$ZipValue
    )

    if (-not $ZipValue) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($ZipValue)) {
        return [System.IO.Path]::GetFullPath($ZipValue)
    }

    $version = $ZipValue.Trim()
    if ($version -match '^[vV]?\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?$') {
        $versionCandidates = New-Object System.Collections.Generic.List[string]
        if ($version -match '^[vV]') {
            $versionCandidates.Add($version)
            if ($version[0] -eq 'V') {
                $versionCandidates.Add(("v" + $version.Substring(1)))
            } else {
                $versionCandidates.Add(("V" + $version.Substring(1)))
            }
        } else {
            $versionCandidates.Add("v$version")
            $versionCandidates.Add("V$version")
        }

        foreach ($candidateVersion in ($versionCandidates | Select-Object -Unique)) {
            $candidatePath = Join-Path $Repo "firmware\s3\release\$candidateVersion\WatcheRobot-S3-$candidateVersion-esp32s3.zip"
            if (Test-Path $candidatePath) {
                return $candidatePath
            }
        }

        $fallbackVersion = $versionCandidates[0]
        return Join-Path $Repo "firmware\s3\release\$fallbackVersion\WatcheRobot-S3-$fallbackVersion-esp32s3.zip"
    }

    return [System.IO.Path]::GetFullPath((Join-Path $Repo $ZipValue))
}

$resolvedRepo = Find-RepoRoot -RequestedRoot $RepoRoot
$resolvedPort = Normalize-PortName -Value $Port
$resolvedZip = Resolve-ZipPath -Repo $resolvedRepo -ZipValue $Zip

$command = New-Object System.Collections.Generic.List[string]

if ($InstallDeps) {
    $requirements = Join-Path $resolvedRepo "tools\win_flasher\requirements.txt"
    $installCommand = @("python", "-m", "pip", "install", "-r", $requirements)
    Write-Host "Repo    : $resolvedRepo"
    Write-Host "Install : $($installCommand -join ' ')"
    if (-not $DryRun) {
        Push-Location $resolvedRepo
        try {
            $installer = $installCommand[0]
            $installerArgs = $installCommand[1..($installCommand.Count - 1)]
            & $installer @installerArgs
            if ($LASTEXITCODE -ne 0) {
                exit $LASTEXITCODE
            }
        }
        finally {
            Pop-Location
        }
    }
}

if ($ListReleases) {
    $command.Add("python")
    $command.Add("-m")
    $command.Add("tools.win_flasher")
    $command.Add("list-releases")
} elseif ($ListPorts) {
    $command.Add("python")
    $command.Add("-m")
    $command.Add("tools.win_flasher")
    $command.Add("list-ports")
} else {
    $command.Add((Join-Path $resolvedRepo "tools\flash-release.cmd"))
    $command.Add("flash")

    if ($resolvedZip) {
        if (-not (Test-Path $resolvedZip)) {
            throw "Release ZIP not found: $resolvedZip"
        }
        $command.Add("--zip")
        $command.Add($resolvedZip)
    }

    if ($resolvedPort) {
        $command.Add("--port")
        $command.Add($resolvedPort)
    }

    $command.Add("--baud")
    $command.Add([string]$Baud)

    if ($Monitor) {
        $command.Add("--monitor")
        $command.Add("--monitor-seconds")
        $command.Add([string]$MonitorSeconds)
        $command.Add("--monitor-baud")
        $command.Add([string]$MonitorBaud)
    }
}

Write-Host "Repo    : $resolvedRepo"
if ($resolvedPort) {
    Write-Host "Port    : $resolvedPort"
}
if ($resolvedZip) {
    Write-Host "ZIP     : $resolvedZip"
} elseif (-not $ListReleases -and -not $ListPorts) {
    Write-Host "ZIP     : latest scanned release"
}
Write-Host "Command : $($command -join ' ')"

if ($DryRun) {
    exit 0
}

Push-Location $resolvedRepo
try {
    $executable = $command[0]
    $arguments = if ($command.Count -gt 1) { $command[1..($command.Count - 1)] } else { @() }
    & $executable @arguments
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
