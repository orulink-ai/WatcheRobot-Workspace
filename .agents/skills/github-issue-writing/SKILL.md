---
name: github-issue-writing
description: Use when creating or editing GitHub issues with gh, especially when the issue body contains Chinese or mixed Markdown/code content. Ensures correct repository selection, UTF-8 body handling, and post-create verification.
---

# GitHub Issue Writing

## When To Use

Use this skill whenever the user asks to create, update, or repair a GitHub issue in this workspace.

This is mandatory when the issue body contains Chinese text, degree symbols, circuit diagrams, Markdown tables, or code blocks.

## Core Rules

- Use `gh` for all GitHub operations.
- Run GitHub commands from the target subrepo, not the workspace meta repo.
- Confirm the target repo with `git remote -v` before creating the issue.
- Do not pipe Chinese Markdown directly into `gh issue create --body-file -` from PowerShell. It can corrupt text into `?`.
- Write the issue body to a temporary UTF-8 no-BOM Markdown file, then pass it with `--body-file <path>`.
- After creating or editing the issue, verify the remote body with `gh issue view <number> --json body,url`.

## Workflow

1. Identify the target repository:

```powershell
git remote -v
gh auth status
```

2. Draft the issue body as Markdown. Include:

- Background and scope
- Current evidence or logs
- Hardware/software assumptions
- Proposed fix or design
- Validation criteria

3. Write the body to a UTF-8 no-BOM temp file:

```powershell
$path = Join-Path $env:TEMP 'issue-body.md'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($path, $body, $utf8NoBom)
```

4. Create the issue:

```powershell
gh issue create --repo OWNER/REPO --title "标题" --body-file $path
```

5. If repairing an existing issue:

```powershell
gh issue edit ISSUE_NUMBER --repo OWNER/REPO --body-file $path
```

6. Verify the remote issue body:

```powershell
gh issue view ISSUE_NUMBER --repo OWNER/REPO --json title,body,url
```

If the body contains `?` where Chinese text should be, rewrite from the UTF-8 no-BOM file and verify again before reporting completion.

## Delivery

Return the issue URL and briefly state that the body was verified after creation or edit.
