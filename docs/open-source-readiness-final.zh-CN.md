# WatcheRobot 开源准备度中文摘要

本文件是 [Open Source Readiness Final](open-source-readiness-final.md) 的中文执行摘要，供中文维护者、Codex 主 agent 和子 agent 快速接手。英文文件仍是逐项证据源；如果两者不一致，以英文文件和当前仓库证据为准。

## 当前结论

| 项目 | 当前状态 |
| --- | --- |
| 自评分 | 99/100，本地可由 Codex 完成的开源准备项已基本闭环 |
| 产品名 | 新增公开文档统一使用 `WatcheRobot` |
| README | 已有英文 README 和中文 README |
| 文档入口 | 已有英文 `docs/README.md` 和中文 `docs/README.zh-CN.md` |
| 示例 | BLE、动作、表情、AI reminder、creator template 已有最小示例；本地 dry-run 通过 |
| 治理 | 贡献指南、行为准则、安全说明、Issue/PR 模板、labels 配置和 good first issue 草案已准备 |
| 证据脚本 | readiness、evidence collector、release manifest、release manifest regression tests、GitHub template tests、GitHub community asset tests、owner decision record tests、owner decision quality fixture tests、owner decision brief tests、uncertainty governance contract tests、launch evidence template tests、launch evidence coverage tests、launch evidence request pack tests、launch evidence owner request tests、GitHub web snapshot contract tests、open-source CI workflow tests、Markdown link audit、Markdown link audit tests、Evidence collector coverage tests、product name policy tests、readiness score contract tests、self-reflection log tests、launch gate closeout plan tests、plan docx contract tests、DOCX render prerequisite audit/tests、goal completion audit tests、public README contract tests、docs index contract tests、developer onboarding contract tests、workspace submodule contract tests、open-source runbook tests、WOS coverage tests、WOS evidence trace tests、delivery plan structure contract tests、sub-agent work order tests、example dry-run、launch gate regression tests、placeholder audit、text quality audit、publication hygiene audit、publication hygiene regression tests、launch gate audit、GitHub audit 脚本已准备；当前本地证据收集 Passed 42、Failed 0、Unavailable 7 |
| 占位符控制 | 已有 `docs/placeholder-register.md` 和 `scripts/audit-open-source-placeholders.ps1`，未登记占位会导致 readiness 失败 |
| Owner 决策控制 | 已有 `scripts/test-owner-decision-record.ps1` 和 `scripts/test-owner-decision-quality-fixtures.ps1`，会验证 OQ-001~OQ-009 在 open questions 和 owner decision record 中一致，launch gate audit 也会阻止缺失、重复或额外 OQ ID；Open / Closed 状态必须自洽，并阻止无效日期、未来日期、泛泛 owner approval、`command output was reviewed` 或不可追踪的弱证据关闭决策 |
| Uncertainty governance 控制 | 已有 `scripts/test-uncertainty-governance-contract.ps1`，会验证不确定事项必须询问用户、走 owner 决策或保留 TODO/TBD/PLACEHOLDER，防止被写成未验证的公开承诺 |
| Launch evidence 模板控制 | 已有 `scripts/test-launch-evidence-templates.ps1`，会验证外部证据模板字段完整、license/community/demo/GitHub admin/clean-machine/hardware smoke/App Gradle 模板保留字段级证据要求、日期规则存在且保持 Draft，不会误标为 Passed |
| Launch evidence coverage 控制 | 已有 `scripts/test-launch-evidence-coverage.ps1`，会验证 9 个 launch gate 都保留 evidence 文件、模板、launch gates、closeout plan、request pack、final report 和 handoff 引用 |
| GitHub 网页快照控制 | 已有 `scripts/test-github-web-snapshot-contract.ps1`，会验证 GitHub 网页 fallback evidence 有模板、当前快照，并且不会被当成 GitHub admin gate 通过证据；当前快照记录远端公开页仍未显示 Discussions、顶层 `.github`、releases 或新 README |
| CI workflow 控制 | 已有 `scripts/test-open-source-ci-workflow.ps1`，会验证 GitHub Actions readiness workflow 保留 PR/push 触发、recursive submodules、Python、pwsh 和 `-SkipGradle` readiness 命令 |
| Markdown link audit 控制 | 已有 `scripts/audit-markdown-links.ps1` 和 `scripts/test-markdown-link-audit.ps1`，会验证 README、docs、examples 和 `.github` 的本地链接与 heading anchor |
| Evidence collector coverage 控制 | 已有 `scripts/test-evidence-collector-coverage.ps1`，会验证 readiness 检查不会从 `scripts/collect-open-source-evidence.ps1` 和最终报告中漂移 |
| Product name policy 控制 | 已有 `docs/product-name-policy.md` 和 `scripts/test-product-name-policy.ps1`，会验证公开名称使用 `WatcheRobot`，技术历史名只保留在允许例外中 |
| Readiness score contract 控制 | 已有 `scripts/test-readiness-score-contract.ps1`，会验证 launch gates 未全过时最终报告和交接文档不能声称 100/100 |
| Self-reflection log 控制 | 已有 `docs/self-reflection-log.md` 和 `scripts/test-self-reflection-log.ps1`，会验证每轮自评分有命令证据，且 launch gates 未全过时不能声称 100/100 |
| Launch gate closeout 控制 | 已有 `docs/launch-gate-closeout-plan.md` 和 `scripts/test-launch-gate-closeout-plan.ps1`，会验证 9 个 launch gate 都有 owner、证据目标、关闭动作和通过信号 |
| Launch evidence request pack 控制 | 已有 `docs/launch-evidence-request-pack.md` 和 `scripts/test-launch-evidence-request-pack.ps1`，会验证 owner/admin/QA 请求包覆盖 9 个 launch gate 和 OQ-001~OQ-009，且不会被误当作通过证据 |
| Launch evidence owner request 控制 | 已有 `docs/launch-evidence-owner-requests.md` 和 `scripts/test-launch-evidence-owner-requests.ps1`，会验证 9 个 launch gate 的 copy-ready 请求草稿、目标 evidence 文件、回复字段、final license 的 SPDX / LICENSE path / scope 证据、community URL / access / fallback 证据、demo media / rights / caption 证据、release owner 的 final manifest 字段级请求、GitHub admin 的远端 workflow / required checks 证据请求、App Gradle 的 `java -version` / `JAVA_HOME` / Android SDK / command exit code / log path / signing-secret exclusion / OQ-009 字段级请求，以及 clean-machine / hardware smoke 的字段级证据请求 |
| Plan docx 控制 | 已重新从 `docs/open-source-delivery-plan.md` 生成根目录 Word 参考计划，并加入 `scripts/test-plan-docx-contract.ps1`、`scripts/audit-docx-render-prerequisites.ps1` 和 `scripts/test-docx-render-prerequisites-audit.ps1`，防止目标中的 `.docx` 与当前执行计划、publication hygiene / root docx staging 规则脱节；当前沙箱中 DOCX 渲染前置条件审计显示 Python `TemporaryDirectory` 嵌套写入、`soffice`、`pdftoppm` 和替代 Word/PDF 渲染通道不可用，因此 Word 视觉渲染 QA 仍明确未证明，DOCX render fallback 已记录在 `docs/self-reflection-log.md` |
| Goal completion audit 控制 | 已有 `docs/goal-completion-audit.md` 和 `scripts/test-goal-completion-audit.ps1`，会验证当前目标逐条映射到证据，并在 launch gates 未全过、或 Word 视觉 QA 不可用但 DOCX render prerequisites 未纳入判断时，阻止把目标标记为 complete；同时要求 completion audit 保留 owner decisions、final license、community entrance、approved demo asset、GitHub admin state、release manifest、App Gradle、clean-machine validation、hardware smoke validation 的字段级证据清单、Strict Final Review Command Set、防止 stale screenshots / stale logs / stale owner replies 被直接当作完成证明的 Evidence Freshness Rule，以及处理 derived summaries、source-of-truth conflict 和 launch evidence files override final reports 的 Authoritative Evidence Hierarchy |
| 公开 README 契约控制 | 已有 `scripts/test-public-readme-contract.ps1`，会验证英文和中文 README 保留产品定位、Demo 占位、资源入口、社区治理入口和贡献边界 |
| 文档索引契约控制 | 已有 `scripts/test-docs-index-contract.ps1`，会验证英文和中文 docs index 保留关键文档、脚本闸门和子仓库 README 入口 |
| 开发者上手契约控制 | 已有 `scripts/test-developer-onboarding-contract.ps1`，会验证 Quick Start、工具链矩阵和 examples README 保留 clone、submodule、启动、工具链和 smoke-test 路径 |
| Workspace submodule 控制 | 已有 `scripts/test-workspace-submodule-contract.ps1`，会验证 `.gitmodules`、root gitlink、README 仓库表和 Quick Start 子仓路径一致 |
| Runbook 控制 | 已有 `scripts/test-open-source-runbooks.ps1`，会验证发布、public-launch validation 和交接 runbook 保留安全 staging、阅读顺序、work orders、最小验证命令，以及 clean-machine / GitHub admin / hardware smoke 的字段级证据要求 |
| Publication hygiene 控制 | 已有 `scripts/audit-publication-hygiene.ps1`、`scripts/test-publication-hygiene.ps1` 和本地 `.gitignore` 规则，会验证本地导出、output 目录、临时 pull worktree、子仓路径、无关根级 `.docx` 和 helper 文件不会被误 staged |
| WOS 覆盖控制 | 已有 `scripts/test-wos-coverage.ps1`，会验证执行计划、英文最终报告、中文最终摘要都覆盖且仅覆盖 WOS-01~WOS-45 |
| WOS evidence trace 控制 | 已有 `scripts/test-wos-evidence-trace.ps1`，会验证英文和中文最终报告里每个 WOS 行都有状态、可追踪 evidence、剩余阻塞或无阻塞说明，防止只保留编号但丢失证据 |
| Delivery plan structure 控制 | 已有 `scripts/test-delivery-plan-structure-contract.ps1`，会验证执行计划保留 Check 点、Target Table、Todo List、子 agent 策略、TDD 和自评分规则 |
| Owner decision brief 控制 | 已有 `docs/owner-decision-brief.md` 和 `scripts/test-owner-decision-brief.ps1`，会验证 9 个 owner 问题都映射到阻塞 gate、证据类型和批准后需更新的文件 |
| 子 agent 交接 | 已有 `docs/sub-agent-handoff.md`，包含阅读顺序、work orders、停止条件、外部证据和最小 continuation 命令 |
| 子 agent work order 包 | 已有 `docs/sub-agent-work-orders/README.md` 和 WO-01~WO-07，可直接分发给子 agent 执行；`scripts/test-sub-agent-work-orders.ps1` 会验证每个任务包保留输入、允许动作、禁止事项、验证命令、升级条件、交付物、自评分说明，以及 GitHub admin / hardware smoke / final launch review 的字段级 evidence checklist 和 WO-07 Strict Final Review Command Set |
| Launch gates | 已有 `docs/open-source-launch-gates.md`、`docs/launch-evidence/README.md`、evidence templates、App Gradle blocker evidence、release artifact blocker evidence、`scripts/audit-open-source-launch-gates.ps1` 和 `scripts/test-open-source-launch-gates.ps1`；当前 gate audit 为 Passed 0、Unavailable 9、Failed 0；正式 evidence 文件必须包含 `Status: Passed`、完整 owner/date/environment/evidence/result/follow-up 字段、有效且非未来的 `YYYY-MM-DD` 日期、具体可追踪来源标记，且全文不能包含 TODO/TBD/PLACEHOLDER/REPLACE_ME/UNKNOWN pending token 才会通过；`command output was reviewed` 这类泛泛说明不能关闭 gate，除非同时给出具体命令、URL、路径、checksum、issue/PR 编号、artifact URL、transcript/recording 路径或 commit hash；README、License、owner decision、release manifest 或远端 GitHub 状态变化只是必要输入，不能在缺少匹配 evidence 文件时关闭 gate，回归测试会防止假通过 |
| 不能臆造的事项 | License、社区入口、Demo 素材、维护者、硬件开放范围、GitHub admin 设置、硬件 smoke test |

## 为什么不是 100/100

- License 仍需产品 / 法务 owner 确认。
- 官方社区入口仍需产品 / 社区 owner 确认。
- README 首屏 Demo 图、GIF 或视频仍需产品 / 设计 owner 批准。
- 硬件 smoke test 还没有真实设备证据；`docs/launch-evidence/hardware-smoke.md` 已记录为 Draft blocker evidence。
- GitHub Discussions、labels、branch protection、Issue/PR 模板远端效果需要仓库 admin 或 token 验证；`docs/launch-evidence/github-admin.md` 已记录为 Draft blocker evidence。
- 当前 shell 未安装 `gh`，也没有 `GH_TOKEN` / `GITHUB_TOKEN`。
- 当前 shell 未配置 Java，因此 App Android Gradle dry-run 未执行；`docs/launch-evidence/app-gradle.md` 已记录为 Draft blocker evidence，且正式通过前还必须补齐 `java -version`、`JAVA_HOME`、Android SDK path/version、`WatcheRobot_app/android` 下的确切 Gradle command、task / build variant、command exit code、output log path、可选 Metro / React Native command、signing-secret exclusion confirmation 和 OQ-009 legacy identifier decision。
- App 内部 `WatcherRobotAPP` 标识属于高风险 native target 重命名，已放入专项计划，不在本轮贸然修改。
- Launch gate audit 仍显示 9 个最终发布门槛 unavailable：owner 决策、最终 License、社区入口、Demo 素材、GitHub admin、release manifest、Java/App Gradle 证据、clean-machine 验证、硬件 smoke 验证。9 个 gate 现在都有明确 evidence route；未解决项仍保持 Draft 或 owner decision open，不能算通过。

## Launch evidence files

- `docs/launch-evidence/owner-decisions.md`
- `docs/launch-evidence/final-license.md`
- `docs/launch-evidence/community-entrance.md`
- `docs/launch-evidence/demo-asset.md`
- `docs/launch-evidence/github-admin.md`
- `docs/launch-evidence/release-artifacts.md`
- `docs/launch-evidence/app-gradle.md`
- `docs/launch-evidence/clean-machine.md`
- `docs/launch-evidence/hardware-smoke.md`

## 关键本地验证命令

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-open-source-readiness.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\collect-open-source-evidence.ps1 -SkipGradle
powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-record.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-quality-fixtures.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-uncertainty-governance-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-templates.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-github-web-snapshot-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-ci-workflow.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-evidence-collector-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-public-readme-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-docs-index-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-developer-onboarding-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-workspace-submodule-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-runbooks.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-coverage.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-wos-evidence-trace.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-delivery-plan-structure-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-owner-decision-brief.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-product-name-policy.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-readiness-score-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-self-reflection-log.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-gate-closeout-plan.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-request-pack.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-launch-evidence-owner-requests.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-plan-docx-contract.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-goal-completion-audit.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-release-manifest-validation.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-sub-agent-work-orders.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\audit-publication-hygiene.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-publication-hygiene.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-open-source-examples.ps1
git diff --check
git -C WatcheRobot_app diff --check
```

## WOS 中文状态表

| ID | 中文状态 | 当前证据 | 剩余阻塞 |
| --- | --- | --- | --- |
| WOS-01 | 部分通过 | 根 README、新增 docs、`docs/product-name-policy.md`、`scripts/test-product-name-policy.ps1`、App 公开展示名和 APK 输出名已统一为 `WatcheRobot` | App 内部 `WatcherRobotAPP` target 需专项重命名 |
| WOS-02 | 通过 | README 顶部已说明开源桌面具身智能机器人 | 无 |
| WOS-03 | 通过 | README 已说明项目对象和能力 | 无 |
| WOS-04 | 待素材批准 | README Demo 区、assets 规范、Demo 清单和 `docs/launch-evidence/demo-asset.md` 已准备 | 需要真实可公开产品图 / GIF / 视频；当前 Draft evidence 记录素材未确认 |
| WOS-05 | 部分通过 | README 和硬件结构图已聚合入口 | 硬件 / 结构件公开范围需 owner 确认 |
| WOS-06 | 通过 | README 子仓库关系、贡献边界和 `scripts/test-workspace-submodule-contract.ps1` | 无 |
| WOS-07 | 通过 | `docs/architecture.md` | 拓扑变化时需刷新 |
| WOS-08 | 待外部验证 | `docs/quick-start.md`、`docs/public-launch-validation.md`、`docs/launch-evidence/clean-machine.md`、`scripts/test-developer-onboarding-contract.ps1` 和 `scripts/test-workspace-submodule-contract.ps1` | 需要 clean-machine 验证；当前 Draft evidence 记录尚未做 fresh-machine run |
| WOS-09 | 通过 | `docs/toolchain-matrix.md` 和 developer onboarding contract tests | 子仓版本变化时维护 |
| WOS-10 | 部分通过 | App README、中文 README、签名配置示例、`docs/launch-evidence/app-gradle.md`、`docs/launch-evidence-owner-requests.md` 和 `scripts/test-launch-evidence-owner-requests.ps1` | Java 缺失，Gradle dry-run 未执行；正式 App 证据仍需 `java -version`、`JAVA_HOME`、Android SDK path/version、Gradle task / build variant、command exit code、output log path、signing-secret exclusion 和 OQ-009 legacy identifier decision |
| WOS-11 | 部分通过 | Quick Start 和桌面端 README 链接 | 桌面端首次启动 smoke test 未跑 |
| WOS-12 | 通过 | Quick Start、Server README / config | 无 |
| WOS-13 | 通过 | `docs/quick-start.md` 中的 ESP32 / STM32 文档入口和固件 README 链接 | 硬件烧录 smoke test 未跑 |
| WOS-14 | 通过 | `docs/provisioning.md` 和固件 BLE 协议入口 | 协议源文档需持续维护 |
| WOS-15 | 部分通过 | `docs/provisioning.md` | ready / failure recovery 需硬件验证 |
| WOS-16 | 待批准 | `docs/open-source-scope.md` 和 `docs/hardware-structure-map.md` | 硬件文件公开范围需 owner 确认 |
| WOS-17 | 待批准 | `docs/hardware-structure-map.md` 和 `docs/assets/README.md` | STL / STEP / CAD / URDF 公开状态 TBD |
| WOS-18 | 部分通过 | `docs/motion-guide.md` 和 `examples/send-motion-minimal/README.md` | 需要硬件动作 smoke test |
| WOS-19 | 部分通过 | `docs/expression-guide.md`、`examples/switch-expression-minimal/README.md`、`scripts/test-open-source-examples.ps1` | `evt.ai.status` BLE route 需固件 / 硬件验证 |
| WOS-20 | 通过 | `docs/ai-integration.md` | 默认 provider 公开推荐需发布前复核 |
| WOS-21 | 部分通过 | `examples/`、`scripts/test-open-source-examples.ps1` 和 `scripts/test-developer-onboarding-contract.ps1` | 硬件 / server runtime smoke test 未跑 |
| WOS-22 | 通过 | `docs/README.md`、`docs/README.zh-CN.md` 和 docs index contract tests | 无 |
| WOS-23 | 通过 | `scripts/check-open-source-readiness.ps1` 扫描到配置示例和 App signing 示例 | 字段说明需各子仓维护 |
| WOS-24 | 通过 | Android release signing 默认密码样式字段已移除；`scripts/check-open-source-readiness.ps1` 敏感扫描通过 | 每次 release 前继续扫描 |
| WOS-25 | 通过 | `.gitignore`、`scripts/audit-publication-hygiene.ps1` 和 `scripts/test-publication-hygiene.ps1` | 提交前复查 generated files |
| WOS-26 | 待决策 | `LICENSE-TBD.md`、license decision guide、`docs/launch-evidence/final-license.md`、`docs/launch-evidence-owner-requests.md` 和 uncertainty governance contract tests | 需产品 / 法务选择最终协议，并提供 SPDX license identifier、root `LICENSE` path、subrepo license impact、hardware / structure file license scope、third-party dependency compatibility 和 temporary license placeholder removal 证据 |
| WOS-27 | 通过 | `CONTRIBUTING.md` | 无 |
| WOS-28 | 通过 | `CODE_OF_CONDUCT.md` | 需确认最终举报联系渠道 |
| WOS-29 | 通过 | `SECURITY.md` | 需确认最终安全联系渠道 |
| WOS-30 | 本地通过，远端待推送 | Issue templates、GitHub template tests、`docs/launch-evidence/github-admin.md` 已准备 | 远端 GitHub 未合并 / 未验证 |
| WOS-31 | 本地通过，远端待推送 | PR template、GitHub template tests、`docs/launch-evidence/github-admin.md` 已准备 | 远端 GitHub 未合并 / 未验证 |
| WOS-32 | 待 admin 执行 | labels JSON、sync 脚本、GitHub community asset tests 和 `docs/launch-evidence/github-admin.md` | 远端 labels 需 token / admin |
| WOS-33 | 待 admin 执行 | good first issue 草案、dry-run 和 GitHub community asset tests | 需 GitHub CLI / token 创建 issue |
| WOS-34 | 待决策 | 社区启动计划、owner decision record、`docs/launch-evidence-owner-requests.md`、uncertainty governance contract tests、GitHub audit、`docs/launch-evidence/community-entrance.md` 和 `docs/launch-evidence/github-admin.md` | Discussions 当前未启用；官方入口仍需 official community URL、access status、moderation owner、response window、fallback contact、README community link 和 GitHub Discussions setting or equivalent route |
| WOS-35 | 通过 | `docs/release-policy.md` | 真实 cadence 需 maintainer 确认 |
| WOS-36 | 部分通过 | root `CHANGELOG.md` | 子仓 changelog / license 不完全 |
| WOS-37 | 部分通过 | readiness CI、`scripts/collect-open-source-evidence.ps1`、GitHub template tests、GitHub community asset tests、owner decision record tests、owner decision quality fixture tests、owner decision brief tests、uncertainty governance contract tests、launch evidence template tests、launch evidence coverage tests、launch evidence request pack tests、launch evidence owner request tests、GitHub web snapshot contract tests、open-source CI workflow tests、product name policy tests、readiness score contract tests、self-reflection log tests、launch gate closeout plan tests、plan docx contract tests、goal completion audit tests、public README contract tests、docs index contract tests、developer onboarding contract tests、workspace submodule contract tests、open-source runbook tests、WOS coverage tests、WOS evidence trace tests、delivery plan structure contract tests、sub-agent work order tests、publication hygiene regression tests、release manifest regression tests、placeholder audit、text quality audit、publication hygiene audit、launch gate audit、launch gate regression tests、owner decision blocker evidence、final license blocker evidence、community entrance blocker evidence、demo asset blocker evidence、App Gradle blocker evidence、release artifact blocker evidence、GitHub admin blocker evidence、clean-machine blocker evidence、hardware smoke blocker evidence、example dry-run | workflow 需推送并在远端可见；branch protection required checks 需 GitHub admin 证据确认；Gradle 未纳入本地验证；未解决 launch evidence 仍为 Draft |
| WOS-38 | 待 release owner | release policy、manifest 示例、release artifacts 模板、`docs/launch-evidence/release-artifacts.md`、launch evidence 请求包、release owner 请求稿、校验脚本和 release manifest regression tests；最终 manifest 校验命令使用 `-Manifest <final-manifest>`，且 `-Path` 兼容别名已有回归测试；final manifest 现在会拒绝任意字段里的 pending token、非 semantic version、未来 release date、非 http(s) release URL、重复 artifact name、不是 JSON boolean 的 artifact `required` 字段、不是 http(s) URL 或可追踪文件路径的 artifact `path_or_url` 值，要求 `version` 是 semantic version tag，`release_date` 是有效且非未来日期，`release_url` 是 http(s) URL，workspace/App/desktop/server/ESP32/STM32 component refs 必须是 commit hash 或 semantic version tag，并要求必需的 desktop installer、ESP32 firmware package、readiness / hardware smoke / clean-machine check 结果都为 `passed` | 真实下载链接/路径 / checksum、唯一 artifact name、JSON boolean artifact `required`、semantic release version、release date、release URL、六个组件 commit hash 或 semantic version tag、通过的 readiness / hardware smoke / clean-machine check 结果、必需 desktop/ESP32 产物和可选 STM32 产物决策需确认；当前 Draft evidence 记录 release metadata 与 artifact values 仍未收口 |
| WOS-39 | 核心入口通过 | 英文 / 中文 README，英文 / 中文 docs index，中文最终验收摘要 | 若公开要求全量双语，后续需继续翻译所有 topic docs |
| WOS-40 | 待批准 | assets README、Demo 清单、`docs/launch-evidence-owner-requests.md`、硬件结构图 | Logo / 产品 / Demo 素材需 approved media URL or repository path、asset type、public usage rights、source owner、README Demo section replacement、assets README placement/reference 和 caption approval |
| WOS-41 | 待决策 | `docs/maintainers.md`、`docs/owner-decision-record.md` 和 `scripts/test-uncertainty-governance-contract.ps1` | 维护者姓名和响应窗口未确认 |
| WOS-42 | 通过 | `docs/branch-policy.md` | branch protection 需 admin 验证 |
| WOS-43 | 待 admin 执行 | GitHub settings checklist、validation runbook、`docs/launch-evidence/github-admin.md`、`docs/launch-evidence-owner-requests.md`、`docs/launch-evidence/web-snapshots/latest-github-remote.md` 和 `docs/launch-evidence/web-snapshots/github-remote-2026-06-12.md` | branch protection 和 required checks 未启用或未确认；网页快照和 Draft admin evidence 不能关闭此 gate |
| WOS-44 | 占位通过 | `docs/showcase.md` 和 `docs/community-submissions.md` | 真实用户作品和授权 TBD |
| WOS-45 | 待外部最终验证 | README、docs、examples、治理、product name policy、launch gate closeout plan、launch evidence request pack、launch evidence owner requests、goal completion audit、Word reference plan、placeholder register、publication hygiene audit、publication hygiene regression tests、owner decision record tests、owner decision quality fixture tests、owner decision brief tests、uncertainty governance contract tests、launch evidence template tests、launch evidence request pack tests、launch evidence owner request tests、GitHub web snapshot contract tests、open-source CI workflow tests、product name policy tests、readiness score contract tests、launch gate closeout plan tests、plan docx contract tests、goal completion audit tests、public README contract tests、docs index contract tests、developer onboarding contract tests、workspace submodule contract tests、open-source runbook tests、WOS coverage tests、WOS evidence trace tests、delivery plan structure contract tests、sub-agent work order tests、Target Table、Todo List、`docs/sub-agent-work-orders/README.md`、`scripts/test-sub-agent-work-orders.ps1`、`scripts/test-wos-evidence-trace.ps1`、owner decision blocker evidence、final license blocker evidence、community entrance blocker evidence、demo asset blocker evidence、App Gradle blocker evidence、release artifact blocker evidence、GitHub admin blocker evidence、clean-machine blocker evidence、hardware smoke blocker evidence、owner decision quality fixtures、owner decision brief、脚本、launch gates、evidence templates、web snapshots、runbook、sub-agent handoff 已准备 | clean-machine 仍需 fresh clone、root commit、recursive submodule status、Quick Start、readiness 和 examples dry-run 证据；硬件 smoke 仍需 BLE/servo/expression/Wi-Fi/AI reminder 的安全实机日志；远端 merge、GitHub admin、Java/Android Gradle command exit code 与 log path、release artifact、owner 决策、最终 License、官方社区入口、Demo 素材仍需证据 |

## 下一步只应做什么

1. 用 [Remote Publication Runbook](remote-publication-runbook.md) 分别提交 root 和 App 子仓，不要 `git add .`。
2. 设置 `GH_TOKEN` / `GITHUB_TOKEN` 或安装并登录 `gh`，再同步 labels、创建 good first issues、验证 Discussions 和 branch protection。
3. 配置 Java / Android 工具链后运行 App Gradle 检查。
4. 用真实硬件跑 BLE ping、servo、expression、Wi-Fi provisioning 和 AI reminder smoke test。
5. 由 owner 填写 [Owner Decision Record](owner-decision-record.md)，再把 TODO / TBD 变成正式公开承诺。
