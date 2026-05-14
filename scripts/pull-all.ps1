[CmdletBinding()]
param(
    [switch]$FetchOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
. "$PSScriptRoot\workspace-repos.ps1"
$repos = Get-WatcheWorkspaceRepositories -WorkspaceRoot $workspaceRoot

foreach ($repo in $repos) {
    Write-Host ""
    Write-Host "== $($repo.Name) [$($repo.Kind)]: $($repo.Path) =="

    if (-not (Test-Path (Join-Path $repo.Path ".git"))) {
        Write-Host "not a git repo; skipped"
        continue
    }

    $remotes = & git -C $repo.Path remote
    if (-not $remotes) {
        Write-Host "no remote configured; skipped"
        continue
    }

    $dirty = & git -C $repo.Path status --porcelain
    if ($dirty -and -not $FetchOnly) {
        Write-Host "working tree is dirty; running fetch only"
        & git -C $repo.Path fetch --all --prune
        continue
    }

    if ($FetchOnly) {
        & git -C $repo.Path fetch --all --prune
    }
    else {
        & git -C $repo.Path pull --ff-only
    }
}
