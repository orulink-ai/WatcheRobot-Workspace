---
name: watche-project-onboarding
description: 带新人完成 WatcheRobot 项目新手引导，并在新人上手、答疑、复盘过程中持续识别和沉淀 SOP 缺口。Use when a newcomer needs to understand the WatcheRobot workspace, App/Desktop/Server/Firmware repo boundaries, build/flash/debug workflows, project-specific skills, delivery rules, or when reviewing newcomer questions to update onboarding references automatically.
---

# WatcheRobot Project Onboarding

## 目标

用教练式流程带新人理解 WatcheRobot 项目，并维护本 skill 本身。执行时不仅要答疑，还要判断新人问题是否暴露 SOP 缺口；满足沉淀条件时，直接更新本 skill 的 `SKILL.md` 或 `references/`，在最终报告中说明变更和 PR 审查重点。

## 模式

- `引导模式`：新人首次加入、需要了解项目结构、常用工作流、构建烧录、服务联调、提交规则时使用。
- `复盘模式`：负责人或成员提供新人上手问题、答疑记录、踩坑摘要时使用，用于判断并更新 onboarding SOP。

## 必读 references

- 进入引导模式时先读 `references/project-map.md` 和 `references/key-workflows.md`。
- 需要安排实操或判断是否完成 onboarding 时读 `references/onboarding-checklist.md`。
- 新人需要快速掌握 yarn 指令、调试脚本、workspace 脚本或 skill 路由时读 `references/debug-scripts-and-skills.md`。
- 新人问常见问题时读 `references/newcomer-faq.md` 和 `references/common-pitfalls.md`。
- 遇到有价值但未确认的架构、协议、硬件、发布策略问题时更新 `references/pending-review.md`。
- 生成结束报告时使用 `assets/templates/onboarding-report.md`。

## 引导流程

1. 判断新人背景：询问负责方向、是否有硬件台架、目标是只读了解还是完成真实构建/烧录。
2. 讲项目地图：说明 meta repo、`WatcheRobot_app`、`WatcheRobot_client`、`WatcheRobot_server`、`WatcheRobot_esp32`、`WatcheRobot_stm32` 的边界和分仓提交要求。
3. 讲调试入口：教新人如何快速找到并使用 yarn 指令、workspace 脚本、专项调试 skill。
4. 讲关键工作流：按新人方向介绍现有 skill 和脚本入口，不复制专项 skill 的完整内容。
5. 安排实操路径：在只读导览、构建烧录练习、小改动练习中选择合适路径。
6. 过程中答疑：回答问题时判断它是一次性问题、FAQ、reference 细节、主流程缺口，还是待负责人审核项。
7. 结束前必须追问：`现在还有哪些地方不理解、不确定，或者你觉得文档/流程没讲清楚？`
8. 自我迭代：按下面规则直接更新本 skill 或 references。
9. 输出报告：列出新人完成情况、未解决事项、自动沉淀内容、PR 审查重点和建议下一步。

## 自我迭代规则

把新人问题记录为候选知识缺口。满足以下任意两条时，直接沉淀：

- 下一个新人也大概率会遇到。
- 会阻塞构建、烧录、监控、联调、提交、发布或阶段性交付。
- 是 WatcheRobot 项目特有约定，不是通用工具知识。
- 现有 skill 或 references 没有覆盖，或者覆盖不够清楚。
- 错误理解会造成较高成本，例如刷错固件、改错仓库、提交脏文件、破坏双 MCU 配套关系。
- 新人在对话中反复追问，说明现有解释不足。

## 更新位置判断

- 更新 `SKILL.md`：仅当主流程、触发条件、模式、自我迭代规则、结束报告要求需要变化。
- 更新 `references/project-map.md`：仓库边界、目录职责、分仓提交、项目地图类知识。
- 更新 `references/key-workflows.md`：构建、烧录、监控、联调、动画导入、发布、交付、代码审查入口。
- 更新 `references/debug-scripts-and-skills.md`：yarn 指令、脚本发现方法、调试入口、skill 路由和安全边界。
- 更新 `references/onboarding-checklist.md`：新人检查点、实操练习、完成标准。
- 更新 `references/newcomer-faq.md`：高复用问答。
- 更新 `references/common-pitfalls.md`：常见误区、错误操作、风险提示。
- 更新 `references/pending-review.md`：有沉淀价值但事实需要负责人确认的问题。

## 不要沉淀的内容

- 个人本机路径、个人串口号、个人缓存目录。
- 一次性日志、临时报错、未复现的猜测。
- 与项目无关的通用工具教程。
- 未确认的架构、协议、硬件标准或发布策略事实。
- 密钥、token、内部敏感信息。

## 沉淀写法

- 把个人信息泛化成项目规则，例如把 `COM7` 写成 `当前机器识别到的串口`。
- 新增内容要短、可执行、可被下一个新人使用。
- 不要把同一信息同时写进 `SKILL.md` 和 references。
- 修改后在报告里列出文件、原因、判断依据和 PR 审查重点。

## 交付标准

每次 onboarding 结束时输出：

- 新人已理解的项目范围和工作流。
- 已完成或未完成的实操检查点。
- 仍未解决的问题。
- 本次已自动更新的 onboarding 文件。
- 每个更新的触发原因和沉淀依据。
- 需要负责人在 PR 中重点审核的内容。
