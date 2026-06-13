# WatcheRobot 开源社区一次性交付计划

本文是给 Codex 主 agent 和子 agent 使用的自包含执行文档。执行时不得依赖历史聊天记录或飞书表格；所有目标、边界、占位符规则和 WOS 明细都以本文为准。

## 1. 执行目标

把当前 `WatcheRobot-Workspace` 和相关子仓库整理成可公开开源的开发者入口。最终外部开发者进入 GitHub 后，可以完成：

了解项目 -> 下载源码 -> 跑通桌面端或 App -> 连接设备 -> 阅读协议 -> 运行最小示例 -> 提交 Issue/PR -> 参与社区。

公开产品名统一为 `WatcheRobot`。历史目录名、远端仓库名和文件名不强制立即重命名，但新增对外文档必须使用 `WatcheRobot`。

## 2. 不确定性规则

严禁虚构链接、社区入口、Demo、Roadmap 时间、License 决策、维护者名单、硬件开放状态或已经完成的能力。

| 类型 | 处理方式 |
| --- | --- |
| 能从仓库验证的事实 | 必须先查 README、代码、配置、release、docs，不问用户，不猜测 |
| 产品/商业/法律决策 | 必须询问用户；无人回复时使用 TODO/TBD |
| 不阻塞结构搭建的信息 | 使用占位符并登记到 `docs/open-questions.md` |
| 影响法律/安全/公开承诺的信息 | 停在 TODO，不写成确定事实 |
| 子 agent 发现不确定点 | 汇总给主 agent，由主 agent 判断是否询问用户 |

占位符格式：

```md
TODO(owner/date): 待确认事项。
TBD: 信息未确认，不能作为公开承诺。
PLACEHOLDER(owner/date): 仅保留结构；必须在 `docs/open-questions.md` 或最终验收报告登记原因、负责人和下一步。
```

## 3. Check 点

| Check 点 | 验收目标 | 通过标准 |
| --- | --- | --- |
| CP0 基线复核 | 复核 WOS-01~45 | 每项都有状态、证据路径、执行动作 |
| CP1 不确定性登记 | 建立 open questions | 所有无法确认的信息进入 `docs/open-questions.md` |
| CP2 安全闸门 | 敏感信息和开源协议风险清理 | WOS-24、WOS-26~29 无 P0 阻塞；未确认 License 用 TBD |
| CP3 首页闭环 | 根 README 变成外部首页 | WOS-01~08 通过；Demo/社区/License 等未确认项用占位符 |
| CP4 开发文档闭环 | Quick Start、版本矩阵、协议入口完成 | WOS-09~17 通过或有明确例外说明 |
| CP5 Examples 闭环 | 最小示例可运行/可验收 | WOS-18~21 通过 |
| CP6 社区治理闭环 | Issue/PR/社区/维护规则完成 | WOS-30~34、WOS-41~43 通过；需管理员权限项列 checklist |
| CP7 发布治理闭环 | Release、Changelog、CI、素材、Showcase 完成 | WOS-35~40、WOS-44~45 通过 |
| CP8 占位符审查 | 防止臆造和漏项 | 所有 TODO/TBD/PLACEHOLDER 都在最终报告列明原因和下一步 |

## 3.1 Target Table / 目标表

| Goal | Priority | Metric | Acceptance Standard | Time Window |
| --- | --- | --- | --- | --- |
| G-01 Public entry clarity | P0 | WOS-01~08 have README/docs evidence | External developer can understand project, resources, repository map, and Quick Start from root entry | D1-D3 |
| G-02 Developer onboarding closure | P0 | WOS-09~21 have docs/examples/tests evidence | Quick Start, toolchain matrix, provisioning, motion, expression, AI, and examples remain locally verifiable | D3-D6 |
| G-03 Governance and uncertainty control | P0 | WOS-24, WOS-26~34, WOS-41~43 have governance files and owner-decision routing | No sensitive data, no guessed owner decisions, all unresolved public facts stay in open questions / owner decision / placeholder register | D1-D10 |
| G-04 Release and remote readiness | P1 | WOS-35~40 have release, changelog, CI, asset, and manifest evidence | Local release metadata and GitHub admin runbooks are ready; remote-only gates stay unavailable until real admin evidence exists | D7-D10 |
| G-05 External validation readiness | P0 | WOS-45 and launch gates have current evidence | Evidence collector, launch gate audit, launch gate closeout plan, launch evidence request pack, clean-machine/hardware/admin/release templates, and final reports show exactly what is passed, unavailable, or blocked | Every round |

## 3.2 Todo List / 待办事项

| Task | Owner / Agent | Due Window | Deliverable | Verification |
| --- | --- | --- | --- | --- |
| T-01 Baseline and WOS matrix refresh | Repo Audit Agent | D1 | WOS-01~45 status table and evidence paths | `scripts/test-wos-coverage.ps1` |
| T-02 Public README and docs index | Docs Agent | D1-D3 | Root README, Chinese README, docs index, product name policy, resource hub | `scripts/test-public-readme-contract.ps1`, `scripts/test-product-name-policy.ps1`, `scripts/test-docs-index-contract.ps1` |
| T-03 Quick Start and toolchain path | Docs + QA | D3-D4 | Quick Start, toolchain matrix, submodule path contract | `scripts/test-developer-onboarding-contract.ps1`, `scripts/test-workspace-submodule-contract.ps1` |
| T-04 Examples and creator minimum path | Examples Agent | D4-D6 | BLE, motion, expression, AI reminder, creator template examples | `scripts/test-open-source-examples.ps1` |
| T-05 Security, sensitive data, and privacy | Security Agent | D1-D7 | SECURITY, config examples, sensitive scan, privacy/data flow docs | `scripts/check-open-source-readiness.ps1 -SkipGradle` |
| T-06 Uncertainty and owner decision routing | Governance Agent | D1-D10 | Open questions, owner decision record, owner decision brief, placeholder register, no-guesses rule | `scripts/test-owner-decision-record.ps1`, `scripts/test-owner-decision-quality-fixtures.ps1`, `scripts/test-owner-decision-brief.ps1`, `scripts/test-uncertainty-governance-contract.ps1` |
| T-07 GitHub community assets | Governance Agent | D5-D10 | Issue templates, PR template, labels config, good first issue drafts | `scripts/test-github-templates.ps1`, `scripts/test-github-community-assets.ps1` |
| T-08 CI, release, and launch gates | Release + QA | D7-D10 | Readiness workflow, release manifest, launch gate audit, launch gate closeout plan, launch evidence request pack, launch evidence owner requests, launch evidence templates, launch evidence coverage | `scripts/test-open-source-ci-workflow.ps1`, `scripts/test-release-manifest-validation.ps1`, `scripts/test-launch-gate-closeout-plan.ps1`, `scripts/test-launch-evidence-request-pack.ps1`, `scripts/test-launch-evidence-owner-requests.ps1`, `scripts/test-launch-evidence-coverage.ps1`, `scripts/test-open-source-launch-gates.ps1` |
| T-09 Remote publication and admin handoff | Release Agent | After user asks to publish | Safe staging runbook, publication hygiene audit and regression tests, GitHub admin checklist, remote snapshot route | `scripts/test-open-source-runbooks.ps1`, `scripts/audit-publication-hygiene.ps1`, `scripts/test-publication-hygiene.ps1`, `scripts/test-github-web-snapshot-contract.ps1` |
| T-10 Final evidence refresh and self-score | QA Agent | Every round | Updated final report, Chinese summary, Word reference plan, goal completion audit, sub-agent work order pack at `docs/sub-agent-work-orders/README.md`, WOS evidence trace, Markdown link audit, Evidence collector coverage, DOCX render prerequisite audit, evidence collector output, `docs/self-reflection-log.md`, self-reflection score | `scripts/audit-markdown-links.ps1`, `scripts/test-markdown-link-audit.ps1`, `scripts/test-plan-docx-contract.ps1`, `scripts/audit-docx-render-prerequisites.ps1`, `scripts/test-docx-render-prerequisites-audit.ps1`, `scripts/test-goal-completion-audit.ps1`, `scripts/test-readiness-score-contract.ps1`, `scripts/test-self-reflection-log.ps1`, `scripts/test-sub-agent-work-orders.ps1`, `scripts/test-wos-evidence-trace.ps1`, `scripts/test-evidence-collector-coverage.ps1`, `scripts/collect-open-source-evidence.ps1 -SkipGradle` |

## 4. 完整 WOS 执行矩阵

| 编号 | 优先级 | 目标 | 当前判断 | 执行动作 | 交付物 | 验证方式 | 负责人 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| WOS-01 | P0 | 主仓库定位统一 | 待完善，命名混用 | 统一公开名称为 `WatcheRobot`，保留历史仓库名说明 | README 命名说明 | 搜索 README/docs 不再混乱使用多个公开名 | Docs Agent |
| WOS-02 | P0 | 一句话介绍 | 未完善 | README 顶部写明开源桌面具身智能机器人 / Open-source desktop embodied AI robot | README 首屏 | 1 分钟内读懂项目定位 | Docs Agent |
| WOS-03 | P0 | 项目对象 | 未完善 | 增加适用对象：开发者、硬件玩家、AI 应用开发者、普通用户 | README 产品介绍 | 非内部成员可说明项目是什么 | Docs Agent |
| WOS-04 | P0 | Demo 展示 | 未完善 | 加入真实产品图/GIF/视频；未确认则使用占位符 | `docs/assets/` + README Demo | 链接真实存在；占位符进入 open questions | Docs Agent |
| WOS-05 | P0 | 开源资源总入口 | 待完善 | 聚合 App、Desktop、Server、ESP32、STM32、Hardware、Structure、Docs、Examples | README Resource Hub | 关键入口 2 次点击内可达 | Docs Agent |
| WOS-06 | P0 | 子仓库关系 | 基本已完善 | 补是否必须一起使用、默认分支、更新方式、提交边界 | README 子仓表 | 子仓职责和配套关系清楚 | Repo Agent |
| WOS-07 | P0 | 项目结构图 | 未完善 | 绘制 App/Desktop/Server/Firmware/Hardware 数据流图 | `docs/architecture.md` | Mermaid 可渲染，关系不夸大 | Architecture Agent |
| WOS-08 | P0 | 快速开始 | 未完善 | 写外部开发者 Quick Start：clone、submodule、依赖、启动入口 | `docs/quick-start.md` | 干净环境按步骤可执行 | Docs + QA |
| WOS-09 | P0 | 依赖版本 | 待完善 | 汇总 Node、Yarn、Python、React Native、Rust/Tauri、ESP-IDF、STM32 工具链 | `docs/toolchain-matrix.md` | 版本来自真实配置或 README | Architecture Agent |
| WOS-10 | P0 | App 开发说明 | 待完善 | 聚合依赖安装、Android/iOS 运行、常见问题 | App Quick Start | App 新人能启动或知道阻塞点 | App Owner |
| WOS-11 | P0 | 桌面端开发说明 | 待完善 | 聚合桌面端依赖、启动命令、首次配置、服务端关系 | Desktop Quick Start | `npm install` / `npm run dev` 路径清楚 | Desktop Owner |
| WOS-12 | P1 | 服务端开发说明 | 子仓较完善，根入口不足 | 从根文档链接服务端 README，补端口/环境变量摘要 | Server 文档入口 | 服务端启动和配置路径明确 | Server Owner |
| WOS-13 | P1 | 固件开发说明 | 子仓较完善，需状态说明 | 聚合 ESP32/STM32 编译、烧录、串口、日志、恢复入口 | Firmware Quick Start | ESP32/STM32 当前状态不混淆 | Firmware Owner |
| WOS-14 | P1 | BLE 协议文档 | 已有，需聚合 | 根入口链接 BLE Service、Characteristic、ACK/NACK、错误码文档 | BLE 文档入口 | 外部开发者能定位协议真源 | Firmware Owner |
| WOS-15 | P0 | Wi-Fi 配网协议 | 待完善 | 写 BLE 配网、Wi-Fi 下发、ready、失败重试、自动识别规则 | `docs/provisioning.md` | 对照 DESK-CONN ready/恢复项覆盖 | Desktop + Firmware |
| WOS-16 | P1 | 硬件资料入口 | 已有，根入口不足 | 聚合 BOM、Pin Map、接线图、主控板、外设说明 | Hardware 入口 | README 可跳转到硬件资料 | Hardware Agent |
| WOS-17 | P1 | 结构件入口 | 待完善 | 聚合 STL/URDF/CAD；未确认开放项用 TBD，不承诺 | Structure 入口 | 结构件资源和限制说明清楚 | Hardware Agent |
| WOS-18 | P0 | 动作库说明 | 待完善 | 写动作文件位置、命名、触发方式、参数、最小动作示例 | `docs/motion-guide.md` | 可从文档发送一次动作 | Examples Agent |
| WOS-19 | P1 | 表情库说明 | 已有但需外部化 | 把 AnimPack/表情状态整理成创作者可读文档 | `docs/expression-guide.md` | 可从文档切换指定表情 | Examples Agent |
| WOS-20 | P1 | AI 接入说明 | 子仓已有，需产品化 | 说明 ASR、LLM、TTS、OpenClaw 配置、可替换性、默认推荐 | `docs/ai-integration.md` | 新人知道配置放哪里 | Server + Docs |
| WOS-21 | P0 | 最小示例 | 未完善 | 新建 3 个 examples：BLE 控制、发送动作、切换表情；可选 AI 对话 | `examples/` | 每个 example 有 README、运行命令、smoke test | Examples Agent |
| WOS-22 | P1 | 文档目录 | 已有但薄 | 建立 docs 总入口，避免关键说明散落 | `docs/README.md` | 所有关键文档集中索引 | Docs Agent |
| WOS-23 | P0 | 配置模板 | 基本已有，需复核 | 汇总 `.env.example` / `config.example.json`，说明字段用途 | 配置模板清单 | 无真实密钥，字段说明完整 | Security Agent |
| WOS-24 | P0 | 敏感信息清理 | 未完善，有 Android 签名字段风险 | 清理发布签名密码样式字段，改为 local/example/CI Secret | 安全清理 PR | `rg password/token/key/secret` 无 P0 风险 | Security Agent |
| WOS-25 | P1 | `.gitignore` | 基本已完善 | 复核缓存、构建产物、日志、证书、个人路径 | `.gitignore` 复核记录 | 无明显本地缓存进入 Git | Repo Agent |
| WOS-26 | P0 | License | 未完善 | License 未经用户确认不得臆造；先列候选和影响，确认后落地 | LICENSE 或 `LICENSE-TBD.md` | 每个关键仓有明确协议或 TBD | Governance Agent |
| WOS-27 | P0 | 贡献指南 | 未完善 | 根仓新增 CONTRIBUTING，说明 Issue、PR、代码规范、分支、中文 commit | `CONTRIBUTING.md` | 新贡献者可按文档提 PR | Governance Agent |
| WOS-28 | P0 | 行为准则 | 未完善 | 根仓新增 CODE_OF_CONDUCT | `CODE_OF_CONDUCT.md` | 社区协作规则明确 | Governance Agent |
| WOS-29 | P0 | 安全说明 | 未完善 | 根仓新增 SECURITY，说明漏洞、密钥泄露、私有数据反馈方式 | `SECURITY.md` | 安全问题反馈路径明确 | Security Agent |
| WOS-30 | P1 | Issue 模板 | 待完善 | 增加 Bug、Feature、Docs、Hardware、Connection 模板 | `.github/ISSUE_TEMPLATE/*` | 模板覆盖软件/硬件/连接问题 | Governance Agent |
| WOS-31 | P1 | PR 模板 | 待完善 | 增加修改内容、测试方式、影响范围、关联子仓提交字段 | PR 模板 | PR 必填测试和影响范围 | Governance Agent |
| WOS-32 | P1 | Label 体系 | 未完善或需远端验证 | 输出 labels 配置，不假设已创建 | `docs/github-labels.md` | 管理员可按清单配置 | Governance Agent |
| WOS-33 | P1 | Good First Issue | 未完善 | 准备 5 个新手任务，覆盖 docs/examples/app/firmware/hardware | issue 草案 | 每个 issue 有背景、文件、预期、验收 | PM + Agents |
| WOS-34 | P1 | Discussions / 社区入口 | 未完善或需远端权限 | README 提供已确认社区入口；未确认则 TODO | Community 区块 | 外部用户知道去哪提问或看到待确认 | Governance Agent |
| WOS-35 | P1 | Release 机制 | 待完善 | 写 App/Desktop/Firmware/Server 版本发布规则和同步关系 | `docs/release-policy.md` | 可解释多子仓版本兼容 | Release Agent |
| WOS-36 | P1 | Changelog | 待完善 | 根仓补 CHANGELOG 模板；缺失子仓补或链接 | `CHANGELOG.md` | 版本变化可追踪 | Release Agent |
| WOS-37 | P1 | CI 检查 | 待完善 | 定义最小 CI：lint/typecheck/build/docs link/examples smoke | CI 策略或 workflow | 至少根仓有可执行检查计划 | Release Agent |
| WOS-38 | P1 | 可下载产物 | 已有但需聚合 | README 链接真实桌面安装包、固件包、校验值、版本说明；final manifest 的 artifact name 必须唯一，artifact `required` 必须是 JSON boolean，artifact `path_or_url` 必须是 http(s) URL 或可追踪仓库/构建路径，不能是描述性标签；未知则 TBD | Release 入口 | 外部用户能找到可下载包或看到待补项 | Release Agent |
| WOS-39 | P1 | 多语言 | 基本已完善，需统一 | README 核心内容中英同步；关键 Quick Start 至少中英入口 | 中英 README/docs | 海外开发者能读核心路径 | Docs Agent |
| WOS-40 | P1 | 品牌素材 | 待完善 | 统一 Logo、产品图、Demo 图、README 图片到 `docs/assets/`；缺失用占位符 | assets 规范 | 命名清晰，无散落素材 | Docs Agent |
| WOS-41 | P1 | 维护者说明 | 未完善 | 维护者名单未确认时用 TODO，不虚构姓名/邮箱 | `docs/maintainers.md` | 外部用户知道维护规则或待确认 | Governance Agent |
| WOS-42 | P1 | 分支策略 | 待完善 | 明确 main/dev/release、子仓默认分支、配套提交关系 | `docs/branch-policy.md` | 分支用途不混淆 | Governance Agent |
| WOS-43 | P1 | 主分支保护 | 未完善或需权限 | 输出 GitHub Settings Checklist，不声称已开启 | `docs/github-settings-checklist.md` | 管理员可照单开启 | Governance Agent |
| WOS-44 | P1 | 用户作品入口 | 未完善 | 新增 Showcase/Gallery 入口、投稿规则、授权说明；无作品时用占位 | `docs/showcase.md` | 用户知道如何提交作品 | Docs Agent |
| WOS-45 | P0 | 外部开发闭环 | 未完善 | 用最终验收表跑通了解、下载、运行、连接、协议、Issue、PR 全路径 | `docs/open-source-readiness-final.md` | P0 全通过，P1 无阻塞 | QA Agent |

## 5. 创作者生态补充项

| 编号 | 优先级 | 目标 | 执行动作 | 交付物 |
| --- | --- | --- | --- | --- |
| WCE-01 | P0 | 开源范围说明 | 写明已开放、暂不开放、后续开放及原因；不确定项用 TBD | `docs/open-source-scope.md` |
| WCE-02 | P0 | Roadmap | 写明 EVT、开源、Makuake、Beta、量产阶段；日期未确认不编造 | `docs/roadmap.md` |
| WCE-03 | P0 | 创作者模板最小版 | 给表情/动作/AI 扩展提供最小模板入口 | `examples/creator-template-minimal` |
| WCE-04 | P0 | 扩展能力边界 | 明确外部开发者能改哪些部分，不能改哪些部分 | `docs/extension-boundaries.md` |
| WCE-05 | P0 | 隐私与数据流说明 | 说明语音、摄像头、LLM、TTS、云服务、本地客户端数据流；未知项标 TODO | `docs/privacy-and-data-flow.md` |
| WCE-06 | P1 | 资源包规范 | 定义表情包、动作包、音频包目录和命名 | `docs/resource-pack-spec.md` |
| WCE-07 | P1 | 作品提交规范 | 说明用户如何提交动作、表情、外壳、Demo、教程 | `docs/community-submissions.md` |
| WCE-08 | P2 | 完整 Gallery 运营 | 后续维护社区作品展示页；无作品不虚构案例 | `docs/showcase.md` 后续扩展 |

## 6. 子 Agent 调用策略

| 子 Agent | 负责内容 | 调用时机 | 输出 |
| --- | --- | --- | --- |
| Repo Audit Agent | WOS-01~45 状态复核、路径证据 | D1、D10 | 基线表、最终验收表 |
| Docs Agent | README、docs 总入口、Quick Start、FAQ、Showcase | D1-D10 | 外部文档集和占位符清单 |
| Architecture Agent | 架构图、版本矩阵、数据流、扩展边界 | D2-D5 | 架构和工具链文档 |
| Security Agent | 敏感信息、配置模板、SECURITY、隐私数据流 | D1-D7 | 安全清理和隐私文档 |
| Examples Agent | BLE、动作、表情、创作者模板 | D4-D8 | examples 目录 |
| Governance Agent | License、贡献指南、行为准则、Issue/PR 模板、维护者、分支策略 | D5-D10 | 社区治理文件 |
| Release Agent | Release、Changelog、CI、GitHub 设置清单 | D7-D10 | 发布治理文件 |
| QA Agent | TDD 验收、链接检查、闭环验证、占位符审查 | 每个 CP 节点 | 验收报告 |

## 7. TDD / 验收驱动规则

- 文档类：链接和本地路径必须存在；Quick Start 必须有命令、预期结果、失败处理。
- 安全类：执行敏感词扫描；空值 example 不算泄露，真实值和默认签名密码算阻塞。
- Examples 类：每个 example 必须有 README、依赖、运行命令、预期输出、手动 smoke test。
- 治理类：CONTRIBUTING、PR 模板、Good First Issue 都必须有可执行验收标准。
- Owner 决策类：`docs/open-questions.md` 和 `docs/owner-decision-record.md` 必须通过 `scripts/test-owner-decision-record.ps1` 和 `scripts/test-owner-decision-quality-fixtures.ps1`，OQ-001~OQ-009 必须完整且只出现一次；Open 项保持 TBD，Closed 项必须有 owner、valid non-future date、final decision 和 concrete traceable evidence / source marker；缺失、重复或额外 OQ ID、泛泛 owner approval 或 `command output was reviewed` 都不能关闭决策（search anchor: owner decision non-future date；owner decision traceable evidence）。
- Owner 交接类：`docs/owner-decision-brief.md` 必须通过 `scripts/test-owner-decision-brief.ps1`，每个 OQ 必须映射到阻塞 gate、证据类型和批准后需更新的文件。
- 不确定性治理类：计划、open questions、owner decision、placeholder register、handoff 和最终报告必须通过 `scripts/test-uncertainty-governance-contract.ps1`，确保未确认事项继续走询问用户、owner 决策或 TODO/TBD/PLACEHOLDER，不被写成公开承诺。
- Launch evidence 类：`docs/launch-evidence/templates/` 必须通过 `scripts/test-launch-evidence-templates.ps1`，模板保持 Draft，真实证据只能在执行后复制到 `docs/launch-evidence/`，Passed evidence 必须包含完整 owner/date/environment/evidence/result/follow-up 字段；`Date` 必须是有效 `YYYY-MM-DD` 且不能是未来日期（search anchor: non-future launch evidence date），`Evidence` 必须包含具体 URL、仓库路径、精确命令、截图/日志路径、checksum 值、issue/PR 编号、release artifact URL、transcript/recording 路径或 commit hash 等 concrete traceable source marker；泛泛写 `command output was reviewed` 不能关闭 gate；全文不能包含 TODO/TBD/PLACEHOLDER/REPLACE_ME/UNKNOWN pending token。
- Launch evidence coverage 类：`scripts/test-launch-evidence-coverage.ps1` 必须证明 9 个 launch gate 都有 evidence 文件、模板、launch gates 文档入口、closeout plan、request pack、final report 和 handoff 引用。
- Launch gate evidence-bound 类：`scripts/test-open-source-launch-gates.ps1` 必须证明 README、License、owner decision、release manifest 或远端 GitHub 状态变化不能在缺少匹配 `docs/launch-evidence/*.md` Passed evidence 时关闭 gate。
- Launch evidence 请求包类：`docs/launch-evidence-request-pack.md` 必须通过 `scripts/test-launch-evidence-request-pack.ps1`，覆盖 9 个 launch gate 和 OQ-001~OQ-009，且不能把请求包当作通过证据。
- Launch evidence owner request 类：`docs/launch-evidence-owner-requests.md` 必须通过 `scripts/test-launch-evidence-owner-requests.ps1`，覆盖 9 个 launch gate 的 copy-ready owner/admin/QA 请求草稿、目标 evidence 文件和回复字段。
- CI workflow 类：`.github/workflows/open-source-readiness.yml` 必须通过 `scripts/test-open-source-ci-workflow.ps1`，保留 PR/push 触发、recursive submodules、Python、pwsh 和 `-SkipGradle` readiness 命令。
- Markdown link audit 类：README、docs、examples 和 `.github` 中的本地 Markdown 链接与 heading anchor 必须通过 `scripts/audit-markdown-links.ps1` 和 `scripts/test-markdown-link-audit.ps1`，防止外部开发者入口断链。
- Evidence collector coverage 类：`scripts/check-open-source-readiness.ps1`、`scripts/collect-open-source-evidence.ps1`、最终报告和交接文档必须通过 `scripts/test-evidence-collector-coverage.ps1`，确保本地 readiness 检查不会从证据汇总中漂移。
- README 契约类：英文和中文 README 必须通过 `scripts/test-public-readme-contract.ps1`，保留产品定位、Demo 占位、资源入口、社区治理入口和贡献边界。
- 文档索引类：英文和中文 docs index 必须通过 `scripts/test-docs-index-contract.ps1`，保留关键文档、脚本闸门和子仓库 README 入口。
- 产品名一致性类：公开名称必须使用 `WatcheRobot`；`docs/product-name-policy.md` 必须通过 `scripts/test-product-name-policy.ps1`，技术历史名只能留在允许例外中。
- 自评分契约类：最终报告、中文摘要和交接文档必须通过 `scripts/test-readiness-score-contract.ps1`，launch gates 未全部通过时不得声称 100/100。
- 自评日志类：`docs/self-reflection-log.md` 必须通过 `scripts/test-self-reflection-log.ps1`，每轮自评分必须带有 readiness、evidence collector、launch gate audit 和 diff check 依据。
- Launch gate 关闭类：`docs/launch-gate-closeout-plan.md` 必须通过 `scripts/test-launch-gate-closeout-plan.ps1`，每个 gate 必须有 owner、证据文件或来源、关闭动作和通过信号。
- Word 参考计划类：根目录中匹配 `*Codex*Sub-Agent*.docx` 的 Word 计划必须通过 `scripts/test-plan-docx-contract.ps1`，保持与 `docs/open-source-delivery-plan.md` 的关键目标、验收表和新契约同步；如果视觉渲染未完成，必须运行 `scripts/audit-docx-render-prerequisites.ps1` 和 `scripts/test-docx-render-prerequisites-audit.ps1` 记录 `TemporaryDirectory`、`soffice`、`pdftoppm` 和替代 Word/PDF 渲染通道状态。
- Goal 完成审计类：`docs/goal-completion-audit.md` 必须通过 `scripts/test-goal-completion-audit.ps1`，明确哪些要求已有证据、哪些外部 gate 未关闭，以及何时才允许标记 complete。
- 开发者上手类：Quick Start、工具链矩阵和 examples README 必须通过 `scripts/test-developer-onboarding-contract.ps1`，保留 clone、submodule、启动命令、工具链和 smoke-test 规则。
- Runbook 类：发布和交接文档必须通过 `scripts/test-open-source-runbooks.ps1`，禁止危险 Git 命令，保留阅读顺序、work orders 和最小验证命令。
- 发布卫生类：`.gitignore`、发布 runbook 和 staging 风险规则必须通过 `scripts/audit-publication-hygiene.ps1` 与 `scripts/test-publication-hygiene.ps1`，确保本地导出、临时 pull worktree、output 目录、子仓路径、无关根级 `.docx`（search anchor: root docx staging）和 helper 文件不会被误 staged。
- 子 agent work order 类：`docs/sub-agent-work-orders/README.md` 和 WO-01~WO-07 必须通过 `scripts/test-sub-agent-work-orders.ps1`，确保每个子 agent 任务包都有输入、允许动作、禁止事项、验证命令、升级条件、交付物和自评分说明。
- WOS 覆盖类：执行计划、英文最终报告和中文最终摘要必须通过 `scripts/test-wos-coverage.ps1`，确保 WOS-01~WOS-45 没有遗漏或额外编号。
- WOS evidence trace 类：英文最终报告和中文最终摘要必须通过 `scripts/test-wos-evidence-trace.ps1`，确保 WOS-01~WOS-45 每行都有非空状态、可追踪 evidence、剩余阻塞或无阻塞说明，不能只保留编号。

## 8. 自我反思评分

每轮执行后更新 `docs/open-source-readiness-final.md`：

- 当前得分（0-100）
- 已完成项
- 阻塞项
- 下轮提分动作
- 是否存在臆造、未验证或命名不一致问题
