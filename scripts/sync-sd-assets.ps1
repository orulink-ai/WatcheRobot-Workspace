[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$TargetRoot,

    [string]$SourceDir,

    [switch]$Check,

    [switch]$Generate,

    [switch]$NoClean,

    [switch]$Force,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Format-Bytes {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) {
        return "{0:N2} GB" -f ($Bytes / 1GB)
    }
    if ($Bytes -ge 1MB) {
        return "{0:N2} MB" -f ($Bytes / 1MB)
    }
    if ($Bytes -ge 1KB) {
        return "{0:N2} KB" -f ($Bytes / 1KB)
    }
    return "$Bytes B"
}

function Resolve-ExistingDirectory {
    param(
        [string]$PathValue,
        [string]$BasePath,
        [string]$Label
    )

    if (-not $PathValue) {
        return $null
    }

    $candidate = $PathValue
    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $candidate = Join-Path $BasePath $candidate
    }

    if (-not (Test-Path -LiteralPath $candidate -PathType Container)) {
        throw "$Label directory does not exist: $candidate"
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Get-GeneratedAnimSource {
    param(
        [string]$FirmwareRoot,
        [string]$ExplicitSourceDir
    )

    $resolvedSource = Resolve-ExistingDirectory -PathValue $ExplicitSourceDir -BasePath $FirmwareRoot -Label "Source"
    if ($resolvedSource) {
        return $resolvedSource
    }

    $releaseRoot = Join-Path $FirmwareRoot "release"
    if (-not (Test-Path -LiteralPath $releaseRoot -PathType Container)) {
        throw "Release directory not found: $releaseRoot"
    }

    $candidates = Get-ChildItem -Path $releaseRoot -Directory -ErrorAction Stop |
        ForEach-Object {
            $animDir = Join-Path $_.FullName "sdcard\anim"
            if (Test-Path -LiteralPath $animDir -PathType Container) {
                Get-Item -LiteralPath $animDir
            }
        } |
        Sort-Object LastWriteTime, FullName -Descending

    $selected = $candidates | Select-Object -First 1
    if (-not $selected) {
        throw "No generated SD-card anim assets found under: $releaseRoot"
    }

    return $selected.FullName
}

function Get-RemovableDrives {
    Get-CimInstance Win32_LogicalDisk |
        Where-Object { $_.DriveType -eq 2 -and $_.FileSystem -and $_.Size -gt 0 } |
        Sort-Object DeviceID
}

function Resolve-TargetRoot {
    param([string]$RequestedTargetRoot)

    if ($RequestedTargetRoot) {
        if ($RequestedTargetRoot -match '^[A-Za-z]:$') {
            $RequestedTargetRoot = "$RequestedTargetRoot\"
        }
        $full = [System.IO.Path]::GetFullPath($RequestedTargetRoot)
        if (-not (Test-Path -LiteralPath $full -PathType Container)) {
            throw "Target root does not exist: $full"
        }
        return (Resolve-Path -LiteralPath $full).Path
    }

    $drives = @(Get-RemovableDrives)
    if ($drives.Count -eq 0) {
        throw "No mounted removable SD-card drive was detected. Pass a target root, for example: yarn sd F:\"
    }
    if ($drives.Count -gt 1) {
        $summary = ($drives | ForEach-Object { "$($_.DeviceID)\ ($($_.FileSystem), $(Format-Bytes -Bytes ([long]$_.Size)))" }) -join ", "
        throw "Multiple removable drives detected: $summary. Pass the target root explicitly, for example: yarn sd F:\"
    }

    return "$($drives[0].DeviceID)\"
}

function Assert-SafeTarget {
    param(
        [string]$ResolvedTargetRoot,
        [switch]$AllowFixedDrive
    )

    $root = [System.IO.Path]::GetPathRoot($ResolvedTargetRoot)
    if (-not $root) {
        throw "Unable to determine target drive root: $ResolvedTargetRoot"
    }

    $driveId = $root.TrimEnd("\")
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$driveId'" -ErrorAction SilentlyContinue
    if (-not $disk) {
        throw "Unable to inspect target drive: $driveId"
    }

    if ($disk.DriveType -ne 2 -and -not $AllowFixedDrive) {
        throw "Refusing to sync to non-removable drive $driveId. Use -Force only when this is intentional."
    }

    return $disk
}

function Get-TreeFileSummary {
    param([string]$Root)

    $files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction Stop)
    $bytes = 0L
    foreach ($file in $files) {
        $bytes += [long]$file.Length
    }

    [PSCustomObject]@{
        Files = $files.Count
        Bytes = $bytes
    }
}

$workspaceRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$firmwareRoot = Join-Path $workspaceRoot "WatcheRobot_esp32\firmware\s3"
$syncScript = Join-Path $firmwareRoot "tools\sync_anim_sdcard.py"
$generateScript = Join-Path $firmwareRoot "tools\generate_anim_assets.py"

if (-not (Test-Path -LiteralPath $syncScript -PathType Leaf)) {
    throw "SD-card sync script not found: $syncScript"
}
if (-not (Test-Path -LiteralPath $generateScript -PathType Leaf)) {
    throw "Animation generator script not found: $generateScript"
}

if ($Generate) {
    Write-Host "Generating SD-card animation assets..."
    & python $generateScript
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

$resolvedSourceDir = Get-GeneratedAnimSource -FirmwareRoot $firmwareRoot -ExplicitSourceDir $SourceDir
$resolvedTargetRoot = Resolve-TargetRoot -RequestedTargetRoot $TargetRoot
$targetDisk = Assert-SafeTarget -ResolvedTargetRoot $resolvedTargetRoot -AllowFixedDrive:$Force
$targetAnimDir = Join-Path $resolvedTargetRoot "anim"
$sourceSummary = Get-TreeFileSummary -Root $resolvedSourceDir

Write-Host "Source  : $resolvedSourceDir"
Write-Host "Target  : $resolvedTargetRoot"
Write-Host "Anim dir: $targetAnimDir"
Write-Host "Files   : $($sourceSummary.Files)"
Write-Host "Size    : $(Format-Bytes $sourceSummary.Bytes)"
Write-Host "Free    : $(Format-Bytes ([long]$targetDisk.FreeSpace))"
Write-Host "Mode    : $(if ($Check) { 'check' } else { 'sync' })"

if ([long]$targetDisk.FreeSpace -lt [long]$sourceSummary.Bytes -and -not (Test-Path -LiteralPath $targetAnimDir -PathType Container)) {
    throw "Target drive does not have enough free space for the source assets."
}

if ($Check) {
    if (Test-Path -LiteralPath $targetAnimDir -PathType Container) {
        $targetSummary = Get-TreeFileSummary -Root $targetAnimDir
        Write-Host "Existing target anim files: $($targetSummary.Files), $(Format-Bytes $targetSummary.Bytes)"
    } else {
        Write-Host "Existing target anim files: none"
    }
    Write-Host "Check passed. No files were changed."
    exit 0
}

$syncArgs = @(
    $syncScript,
    "--source-dir",
    $resolvedSourceDir,
    "--target-root",
    $resolvedTargetRoot
)

if ($NoClean) {
    $syncArgs += "--no-clean"
}
if ($ExtraArgs) {
    $syncArgs += $ExtraArgs
}

& python @syncArgs
exit $LASTEXITCODE
