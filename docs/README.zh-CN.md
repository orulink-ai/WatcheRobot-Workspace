# WatcheRobot 开发者文档

本目录是 WatcheRobot 开源准备工作的公开文档入口。中文文档的目标是让外部开发者、维护者、后续 Codex 和子 agent 能快速接手；未确认的信息必须保留为 TODO / TBD / PLACEHOLDER，不能写成已经完成的事实。

## 快速入口

| 需求 | 文档 |
| --- | --- |
| 最快启动 | [Quick Start](quick-start.md) |
| 架构和数据流 | [Architecture](architecture.md) |
| 工具链版本 | [Toolchain Matrix](toolchain-matrix.md) |
| 开源范围 | [Open Source Scope](open-source-scope.md) |
| 产品名规范 | [Product Name Policy](product-name-policy.md) |
| 硬件 / 结构件资源图 | [Hardware and Structure Map](hardware-structure-map.md) |
| License 决策指南 | [License Decision Guide](license-decision-guide.md) |
| Demo 素材审核清单 | [Demo Asset Checklist](demo-asset-checklist.md) |
| Roadmap | [Roadmap](roadmap.md) |
| Codex / 子 agent 执行计划 | [Open Source Delivery Plan](open-source-delivery-plan.md) |
| Word 参考计划 | 根目录中匹配 `*Codex*Sub-Agent*.docx` 的 `.docx` 文件 |
| Codex / 子 agent 交接文档 | [Sub-Agent Handoff](sub-agent-handoff.md) |
| Codex / 子 agent work order 包 | [Sub-Agent Work Orders](sub-agent-work-orders/README.md) |
| 准备度基线 | [Open Source Readiness Baseline](open-source-readiness-baseline.md) |
| 最终准备度报告 | [Open Source Readiness Final](open-source-readiness-final.md) |
| 最终准备度中文摘要 | [Open Source Readiness Final zh-CN](open-source-readiness-final.zh-CN.md) |
| 目标完成审计 | [Goal Completion Audit](goal-completion-audit.md) |
| 公开发布验收 runbook | [Public Launch Validation Runbook](public-launch-validation.md) |
| 远端发布 runbook | [Remote Publication Runbook](remote-publication-runbook.md) |
| Launch gates | [Open Source Launch Gates](open-source-launch-gates.md) |
| Launch gate 关闭计划 | [Launch Gate Closeout Plan](launch-gate-closeout-plan.md) |
| Launch evidence 请求包 | [Launch Evidence Request Pack](launch-evidence-request-pack.md) |
| Launch evidence 目录 | [Launch Evidence](launch-evidence/README.md) |
| 占位符登记表 | [Placeholder Register](placeholder-register.md) |
| Owner 决策交接简报 | [Owner Decision Brief](owner-decision-brief.md) |
| 证据收集脚本 | [`scripts/collect-open-source-evidence.ps1`](../scripts/collect-open-source-evidence.ps1) |
| GitHub 社区资产测试脚本 | [`scripts/test-github-community-assets.ps1`](../scripts/test-github-community-assets.ps1) |
| GitHub 模板测试脚本 | [`scripts/test-github-templates.ps1`](../scripts/test-github-templates.ps1) |
| 计划结构契约测试脚本 | [`scripts/test-delivery-plan-structure-contract.ps1`](../scripts/test-delivery-plan-structure-contract.ps1) |
| 子 agent work order 测试脚本 | [`scripts/test-sub-agent-work-orders.ps1`](../scripts/test-sub-agent-work-orders.ps1) |
| Owner 决策记录测试脚本 | [`scripts/test-owner-decision-record.ps1`](../scripts/test-owner-decision-record.ps1) |
| Owner 决策日期质量回归测试脚本 | [`scripts/test-owner-decision-quality-fixtures.ps1`](../scripts/test-owner-decision-quality-fixtures.ps1) |
| Owner 决策交接测试脚本 | [`scripts/test-owner-decision-brief.ps1`](../scripts/test-owner-decision-brief.ps1) |
| Launch evidence 模板测试脚本 | [`scripts/test-launch-evidence-templates.ps1`](../scripts/test-launch-evidence-templates.ps1) |
| 不确定性治理契约测试脚本 | [`scripts/test-uncertainty-governance-contract.ps1`](../scripts/test-uncertainty-governance-contract.ps1) |
| GitHub 网页快照契约测试脚本 | [`scripts/test-github-web-snapshot-contract.ps1`](../scripts/test-github-web-snapshot-contract.ps1) |
| 开源 CI workflow 测试脚本 | [`scripts/test-open-source-ci-workflow.ps1`](../scripts/test-open-source-ci-workflow.ps1) |
| Markdown link audit 脚本 | [`scripts/audit-markdown-links.ps1`](../scripts/audit-markdown-links.ps1) |
| Markdown link audit 测试脚本 | [`scripts/test-markdown-link-audit.ps1`](../scripts/test-markdown-link-audit.ps1) |
| Evidence collector coverage 测试脚本 | [`scripts/test-evidence-collector-coverage.ps1`](../scripts/test-evidence-collector-coverage.ps1) |
| 产品名规范测试脚本 | [`scripts/test-product-name-policy.ps1`](../scripts/test-product-name-policy.ps1) |
| 准备度自评分契约测试脚本 | [`scripts/test-readiness-score-contract.ps1`](../scripts/test-readiness-score-contract.ps1) |
| Launch gate 关闭计划测试脚本 | [`scripts/test-launch-gate-closeout-plan.ps1`](../scripts/test-launch-gate-closeout-plan.ps1) |
| Launch evidence 请求包测试脚本 | [`scripts/test-launch-evidence-request-pack.ps1`](../scripts/test-launch-evidence-request-pack.ps1) |
| Word 计划契约测试脚本 | [`scripts/test-plan-docx-contract.ps1`](../scripts/test-plan-docx-contract.ps1) |
| DOCX 渲染前置条件审计 | [`scripts/audit-docx-render-prerequisites.ps1`](../scripts/audit-docx-render-prerequisites.ps1) |
| DOCX 渲染前置条件审计测试 | [`scripts/test-docx-render-prerequisites-audit.ps1`](../scripts/test-docx-render-prerequisites-audit.ps1) |
| 目标完成审计测试脚本 | [`scripts/test-goal-completion-audit.ps1`](../scripts/test-goal-completion-audit.ps1) |
| 公开 README 契约测试脚本 | [`scripts/test-public-readme-contract.ps1`](../scripts/test-public-readme-contract.ps1) |
| 文档索引契约测试脚本 | [`scripts/test-docs-index-contract.ps1`](../scripts/test-docs-index-contract.ps1) |
| 开发者上手契约测试脚本 | [`scripts/test-developer-onboarding-contract.ps1`](../scripts/test-developer-onboarding-contract.ps1) |
| Workspace submodule 契约测试脚本 | [`scripts/test-workspace-submodule-contract.ps1`](../scripts/test-workspace-submodule-contract.ps1) |
| 开源 runbook 测试脚本 | [`scripts/test-open-source-runbooks.ps1`](../scripts/test-open-source-runbooks.ps1) |
| WOS 覆盖测试脚本 | [`scripts/test-wos-coverage.ps1`](../scripts/test-wos-coverage.ps1) |
| WOS evidence trace 测试脚本 | [`scripts/test-wos-evidence-trace.ps1`](../scripts/test-wos-evidence-trace.ps1) |
| Launch gate 审计脚本 | [`scripts/audit-open-source-launch-gates.ps1`](../scripts/audit-open-source-launch-gates.ps1) |
| Launch gate 回归测试脚本 | [`scripts/test-open-source-launch-gates.ps1`](../scripts/test-open-source-launch-gates.ps1) |
| 占位符审计脚本 | [`scripts/audit-open-source-placeholders.ps1`](../scripts/audit-open-source-placeholders.ps1) |
| 文本质量审计脚本 | [`scripts/audit-open-source-text-quality.ps1`](../scripts/audit-open-source-text-quality.ps1) |
| 发布卫生审计脚本 | [`scripts/audit-publication-hygiene.ps1`](../scripts/audit-publication-hygiene.ps1) |
| 发布卫生回归测试脚本 | [`scripts/test-publication-hygiene.ps1`](../scripts/test-publication-hygiene.ps1) |
| Release manifest 回归测试脚本 | [`scripts/test-release-manifest-validation.ps1`](../scripts/test-release-manifest-validation.ps1) |
| 示例 dry-run 脚本 | [`scripts/test-open-source-examples.ps1`](../scripts/test-open-source-examples.ps1) |
| 根中文 README | [README.zh-CN.md](../README.zh-CN.md) |

## 开发主题

| 主题 | 文档 |
| --- | --- |
| BLE / Wi-Fi 配网 | [Provisioning](provisioning.md) |
| 动作 | [Motion Guide](motion-guide.md) |
| 表情 | [Expression Guide](expression-guide.md) |
| AI 运行时 | [AI Integration](ai-integration.md) |
| 扩展边界 | [Extension Boundaries](extension-boundaries.md) |
| 资源包 | [Resource Pack Spec](resource-pack-spec.md) |
| 社区投稿 | [Community Submissions](community-submissions.md) |

## 社区和发布

| 主题 | 文档 |
| --- | --- |
| 维护者 | [Maintainers](maintainers.md) |
| 社区启动计划 | [Community Launch Plan](community-launch-plan.md) |
| 分支策略 | [Branch Policy](branch-policy.md) |
| 发布策略 | [Release Policy](release-policy.md) |
| Release manifest 示例 | [Release Manifest Example](release-manifest.example.json) |
| GitHub labels | [GitHub Labels](github-labels.md) |
| GitHub 设置清单 | [GitHub Settings Checklist](github-settings-checklist.md) |
| Good First Issue 草稿 | [Good First Issues](good-first-issues.md) |
| Showcase | [Showcase](showcase.md) |
| 未决问题 | [Open Questions](open-questions.md) |
| Owner 决策记录 | [Owner Decision Record](owner-decision-record.md) |
| Owner 决策交接简报 | [Owner Decision Brief](owner-decision-brief.md) |
| Launch evidence 请求包 | [Launch Evidence Request Pack](launch-evidence-request-pack.md) |
| 决策日志 | [Decision Log](decision-log.md) |
| App 内部重命名计划 | [App Internal Rename Plan](app-internal-rename-plan.md) |

## 子仓库文档

- App：`../WatcheRobot_app/README.md`
- 桌面端：`../WatcheRobot_client/README.md`
- Server：`../WatcheRobot_server/README.md`
- ESP32 固件：`../WatcheRobot_esp32/README.md`
- STM32 固件：`../WatcheRobot_stm32/README.md`
- SD 卡动画资源工作流：[sd-card-assets.md](sd-card-assets.md)

## 验收原则

- 不确定的 License、社区入口、Demo、维护者、硬件开放范围和 Roadmap 日期必须留在 [Open Questions](open-questions.md) 或 [Owner Decision Record](owner-decision-record.md)。
- 本地可验证项必须通过 `scripts/check-open-source-readiness.ps1`。
- 计划结构必须通过 `scripts/test-delivery-plan-structure-contract.ps1`，确保 Check 点、Target Table、Todo List、子 agent 策略、TDD 和自评分规则不丢失。
- 子 agent work order 包必须通过 `scripts/test-sub-agent-work-orders.ps1`，确保 WO-01~WO-07 保留输入、允许动作、禁止事项、验证命令、升级条件、交付物和自评分说明。
- Owner 决策记录必须通过 `scripts/test-owner-decision-record.ps1` 和 `scripts/test-owner-decision-quality-fixtures.ps1`，确保 OQ-001~OQ-009 完整、Open / Closed 状态自洽，且 Closed 日期为有效非未来日期。
- Owner 决策交接简报必须通过 `scripts/test-owner-decision-brief.ps1`，确保 9 个 owner 问题都映射到阻塞 gate、证据类型和批准后需更新的文件。
- Launch evidence 模板必须通过 `scripts/test-launch-evidence-templates.ps1`，确保模板字段完整且不会误标为 Passed。
- Launch evidence 请求包必须通过 `scripts/test-launch-evidence-request-pack.ps1`，确保所有 gate 和 OQ 都有可发给 owner/admin/QA 的证据请求字段，且不会被误当作通过证据。
- 不确定性治理必须通过 `scripts/test-uncertainty-governance-contract.ps1`，确保未确认事项继续走询问用户、owner 决策或 TODO/TBD/PLACEHOLDER。
- GitHub 远端网页快照只能作为 API / gh 不可用时的 fallback evidence，必须通过 `scripts/test-github-web-snapshot-contract.ps1`。
- GitHub Actions readiness workflow 必须通过 `scripts/test-open-source-ci-workflow.ps1`，确保 PR/push 触发、submodules、Python 和 readiness 命令没有被改坏。
- Markdown 本地链接和 heading anchor 必须通过 `scripts/audit-markdown-links.ps1` 和 `scripts/test-markdown-link-audit.ps1`。
- Evidence collector coverage 必须通过 `scripts/test-evidence-collector-coverage.ps1`，确保 readiness 检查和证据汇总不会脱节。
- 产品名规范必须通过 `scripts/test-product-name-policy.ps1`，确保公开名称使用 `WatcheRobot`，技术历史名只保留在允许例外中。
- 准备度自评分必须通过 `scripts/test-readiness-score-contract.ps1`，确保 launch gates 未全过时不能声称 100/100。
- Launch gate 关闭计划必须通过 `scripts/test-launch-gate-closeout-plan.ps1`，确保 9 个 gate 都有 owner、证据文件、关闭动作和通过信号。
- Word 参考计划必须通过 `scripts/test-plan-docx-contract.ps1`，确保目标中的 `.docx` 和当前 Markdown 执行计划不脱节。
- DOCX 渲染前置条件必须通过 `scripts/audit-docx-render-prerequisites.ps1` 与 `scripts/test-docx-render-prerequisites-audit.ps1` 明确记录；如果视觉渲染工具不可用，只能作为 unavailable gate，不得当作已完成视觉 QA。
- 目标完成审计必须通过 `scripts/test-goal-completion-audit.ps1`，确保 goal complete 只在所有 launch gates 真正通过后才允许。
- 公开 README 必须通过 `scripts/test-public-readme-contract.ps1`，确保产品定位、Demo 占位、资源入口、社区治理入口和贡献边界没有退化。
- 文档总入口必须通过 `scripts/test-docs-index-contract.ps1`，确保关键文档、脚本和子仓库入口没有从 docs index 中丢失。
- 开发者上手路径必须通过 `scripts/test-developer-onboarding-contract.ps1`，确保 Quick Start、工具链矩阵和 examples 规则没有退化。
- Workspace submodule 信息必须通过 `scripts/test-workspace-submodule-contract.ps1`，确保 `.gitmodules`、gitlink、README 仓库表和 Quick Start 子仓路径一致。
- 发布和交接 runbook 必须通过 `scripts/test-open-source-runbooks.ps1`，确保子 agent 阅读顺序、最小命令和安全发布边界没有被改坏。
- 发布卫生审计和回归测试必须通过 `scripts/audit-publication-hygiene.ps1` 与 `scripts/test-publication-hygiene.ps1`，确保本地导出、临时 pull worktree、子仓路径和 helper 文件不会被误 staged。
- WOS-01~WOS-45 的完整计划和最终状态表必须通过 `scripts/test-wos-coverage.ps1`，防止后续 Codex / 子 agent 压缩上下文时遗漏验收项。
- WOS evidence trace 必须通过 `scripts/test-wos-evidence-trace.ps1`，确保每个 WOS 行都有可追踪证据，而不是只有编号。
- Launch gate 的回归测试必须通过 `scripts/test-open-source-launch-gates.ps1`，防止空 evidence 文件或删除占位文案造成假通过。
- 公开中文入口必须通过 `scripts/audit-open-source-text-quality.ps1`，防止编码损坏或典型 mojibake 混入发布材料。
- 发布前必须按照 [Public Launch Validation Runbook](public-launch-validation.md) 补齐 clean-machine、硬件、GitHub admin、release artifact 和 owner sign-off 证据。
