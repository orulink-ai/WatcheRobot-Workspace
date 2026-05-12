[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot

$repos = @(
    [pscustomobject]@{ Name = "workspace"; Path = $workspaceRoot },
    [pscustomobject]@{ Name = "esp32"; Path = Join-Path $workspaceRoot "WatcheRobot_esp32" },
    [pscustomobject]@{ Name = "stm32"; Path = Join-Path $workspaceRoot "WatcheRobot_stm32" }
)

function Invoke-GitText {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C $RepoPath @Arguments 2>$null
        if ($LASTEXITCODE -ne 0) {
            return ""
        }
        return ($output -join [Environment]::NewLine).Trim()
    }
    finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
}

foreach ($repo in $repos) {
    Write-Host ""
    Write-Host "== $($repo.Name): $($repo.Path) =="

    if (-not (Test-Path (Join-Path $repo.Path ".git"))) {
        Write-Host "not a git repo"
        continue
    }

    $branch = Invoke-GitText -RepoPath $repo.Path -Arguments @("branch", "--show-current")
    $head = Invoke-GitText -RepoPath $repo.Path -Arguments @("rev-parse", "--short", "HEAD")
    if (-not $branch) { $branch = "(detached or unborn)" }
    if (-not $head) { $head = "(no commits yet)" }
    Write-Host "branch : $branch"
    Write-Host "head   : $head"

    $status = & git -C $repo.Path status --short
    if ($status) {
        $status | ForEach-Object { Write-Host $_ }
    }
    else {
        Write-Host "clean"
    }
}
