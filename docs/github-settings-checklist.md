# GitHub Settings Checklist

This file lists administrator actions. It does not claim the settings are already enabled.

## Discussions

- [ ] Decide whether GitHub Discussions is the official community entrance.
- [ ] Enable Discussions on the root public repository if chosen.
- [ ] Add categories: Announcements, Q&A, Ideas, Showcase, Development.

Read-only check:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1
```

If the anonymous GitHub API is rate-limited, set `GH_TOKEN` or `GITHUB_TOKEN`.

## Branch Protection

Recommended for the public default branch:

- [ ] Require pull request before merge.
- [ ] Require at least one review.
- [ ] Require status checks once CI exists.
- [ ] Block force pushes.
- [ ] Restrict who can push directly.

## Labels

- [ ] Create labels from `docs/github-labels.md`.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-community-assets.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\sync-github-labels.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\sync-github-labels.ps1
```

## Good First Issues

- [ ] Review `.github/good-first-issues/`.
- [ ] Create the first 3-5 beginner issues after labels exist.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-templates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\create-good-first-issues.ps1
```

## Security

- [ ] Enable private vulnerability reporting if available.
- [ ] Configure security contact or advisory process.
- [ ] Add required CI secrets only through GitHub Secrets.

## Releases

- [ ] Confirm whether release assets are hosted in source repositories or a dedicated release repository.
- [ ] Ensure checksums accompany public binaries.
- [ ] Fill and validate a release manifest.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-release-manifest.ps1 -AllowPlaceholders
```
