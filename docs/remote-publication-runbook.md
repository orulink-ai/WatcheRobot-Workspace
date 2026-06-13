# Remote Publication Runbook

Use this runbook when turning the local open-source readiness work into remote GitHub evidence. Do not use broad `git add .` in this workspace because the root repo has submodules and may contain unrelated local changes.

## Current Remote Evidence

Latest local audit command:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
```

When the GitHub API is not rate-limited, `scripts/audit-github-readiness.ps1` can verify:

- Repository: `orulink-ai/WatcheRobot-Workspace`
- Default branch: `main`
- Public: yes
- Discussions: disabled
- Remote license: empty
- Expected labels: not fully present
- Root `.github` templates and readiness workflow: not pushed yet

## Publication Order

1. Root workspace docs/scripts/templates.
2. App subrepo naming and signing cleanup.
3. GitHub repository admin settings.
4. Release artifacts and hardware validation evidence.

## Root Workspace Commit

Review current status:

```powershell
git status --short
```

Stage only root-owned open-source readiness files:

```powershell
git add README.md README.zh-CN.md
git add .gitignore
git add CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md LICENSE-TBD.md SECURITY.md
git add .github
git add docs
git add examples
git add scripts/check-open-source-readiness.ps1
git add scripts/audit-github-readiness.ps1
git add scripts/audit-open-source-launch-gates.ps1
git add scripts/audit-open-source-placeholders.ps1
git add scripts/audit-open-source-text-quality.ps1
git add scripts/audit-publication-hygiene.ps1
git add scripts/collect-open-source-evidence.ps1
git add scripts/create-good-first-issues.ps1
git add scripts/sync-github-labels.ps1
git add scripts/audit-docx-render-prerequisites.ps1
git add scripts/test-delivery-plan-structure-contract.ps1
git add scripts/test-github-community-assets.ps1
git add scripts/test-github-templates.ps1
git add scripts/test-owner-decision-record.ps1
git add scripts/test-owner-decision-quality-fixtures.ps1
git add scripts/test-owner-decision-brief.ps1
git add scripts/test-launch-evidence-templates.ps1
git add scripts/test-uncertainty-governance-contract.ps1
git add scripts/test-open-source-ci-workflow.ps1
git add scripts/test-product-name-policy.ps1
git add scripts/test-readiness-score-contract.ps1
git add scripts/test-launch-gate-closeout-plan.ps1
git add scripts/test-launch-evidence-request-pack.ps1
git add scripts/test-plan-docx-contract.ps1
git add scripts/test-docx-render-prerequisites-audit.ps1
git add scripts/test-goal-completion-audit.ps1
git add scripts/test-public-readme-contract.ps1
git add scripts/test-docs-index-contract.ps1
git add scripts/test-developer-onboarding-contract.ps1
git add scripts/test-workspace-submodule-contract.ps1
git add scripts/test-github-web-snapshot-contract.ps1
git add scripts/test-open-source-runbooks.ps1
git add scripts/test-evidence-collector-coverage.ps1
git add scripts/test-wos-coverage.ps1
git add scripts/test-wos-evidence-trace.ps1
git add scripts/test-open-source-examples.ps1
git add scripts/test-open-source-launch-gates.ps1
git add scripts/test-publication-hygiene.ps1
git add scripts/test-release-manifest-validation.ps1
git add scripts/test-sub-agent-work-orders.ps1
git add scripts/validate-release-manifest.ps1
git add -- "*Codex*Sub-Agent*.docx"
```

The `docs` staging step must include `docs/README.zh-CN.md`, `docs/open-source-readiness-final.zh-CN.md`, `docs/open-source-launch-gates.md`, `docs/launch-evidence/README.md`, `docs/sub-agent-handoff.md`, and `docs/sub-agent-work-orders/README.md`. Only the root Word reference plan matching `*Codex*Sub-Agent*.docx` may be staged as a `.docx` file.

Do not stage these unless they are intentionally reviewed:

- `WatcheRobot_client`
- `WatcheRobot_esp32`
- `WatcheRobot_app`
- `scripts/desktop-server.ps1`
- untracked Feishu table export files
- unrelated local `.docx` files outside the root reference plan

Verify staged files:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-publication-hygiene.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-publication-hygiene.ps1
git diff --cached --stat
git diff --cached --check
```

Commit with a detailed Chinese message:

```powershell
git commit -m "docs: 完善 WatcheRobot 开源社区交付材料" -m "补充 README、治理文件、GitHub 模板、examples、readiness 检查、远端审计、发布 manifest、owner 决策记录和公开发布验收 runbook，支撑开源前的社区准备度验收。"
```

Push through a review branch:

```powershell
git switch -c codex/open-source-readiness
git push -u origin codex/open-source-readiness
```

## App Subrepo Commit

The App cleanup must be committed inside `WatcheRobot_app`, not in the root repository.

```powershell
git -C WatcheRobot_app status --short
git -C WatcheRobot_app diff --check
git -C WatcheRobot_app add README.md README_zh.md CONTRIBUTING.md app.json
git -C WatcheRobot_app add android/gradle.properties android/gradle.release.example.properties android/app/build.gradle android/app/src/main/res/values/strings.xml
git -C WatcheRobot_app add ios/WatcherRobotAPP/Info.plist
git -C WatcheRobot_app commit -m "chore: 统一 WatcheRobot App 公开命名并清理签名占位" -m "将公开展示名和文档统一为 WatcheRobot，移除 Android release signing 默认密码样式字段，新增本地签名配置示例，并保留内部 React Native / iOS target 命名到后续专项重命名任务。"
```

Push according to the App repository branch policy.

## After Push

Run remote audit again:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-github-readiness.ps1
```

Expected improvement after the root branch is merged:

- `.github/ISSUE_TEMPLATE` present
- `.github/PULL_REQUEST_TEMPLATE.md` present
- `.github/workflows/open-source-readiness.yml` present

Expected remaining admin actions:

- choose final License and replace `LICENSE-TBD.md`;
- sync labels with `scripts/sync-github-labels.ps1`;
- create good first issues with `scripts/create-good-first-issues.ps1`;
- enable Discussions or publish the final community entrance;
- enable branch protection;
- attach release artifacts and checksums.

## Completion Rule

Do not mark WOS-45 complete until:

- root readiness materials are merged to the public default branch;
- App cleanup is merged to the App repository;
- GitHub admin settings are verified remotely;
- owner decisions are filled in `docs/owner-decision-record.md`;
- hardware smoke tests and clean-machine validation have evidence.
