---
name: skill-authoring
description: 当用户需要在企业 skills 仓库中创建、归类、审核、迁移或废弃 skill 时使用。该 skill 规范 skill 的目录放置、命名、元数据、文件结构、质量标准和注册方式。
---

# Skill 创建规范

## 使用场景

当用户提出以下需求时，使用本 skill：

- 创建新的企业 skill
- 判断一个 skill 应放入哪个领域目录
- 拆分、合并、迁移或废弃已有 skill
- 编写或审查 `SKILL.md`
- 更新 `registry/skills.yaml` 或 `registry/categories.yaml`
- 设计某个领域下的 skill 分类体系

## 仓库约定

企业正式 skill 放在根目录 `skills/` 下，按一级领域分类：

```text
skills/
  _meta/
  embedded/
  software-engineering/
  algorithms/
  ai-ml/
  devops/
  security/
  docs/
```

`reference/` 仅用于存放参考材料、外部样例和临时拆解对象，不作为正式 skill 来源。

## 创建流程

1. 明确 skill 要解决的具体任务，而不是只记录宽泛知识。
2. 根据 `references/category-guide.md` 选择领域目录。
3. 使用小写字母、数字和连字符命名目录，例如 `stm32-debugging`。
4. 创建 `SKILL.md`，并只把触发条件和核心流程写入正文。
5. 将详细规范、长示例和领域资料放入 `references/`。
6. 将可复用模板放入 `assets/templates/`。
7. 如需确定性执行，才添加 `scripts/`。
8. 在 `registry/skills.yaml` 中登记 skill。
9. 按 `references/review-checklist.md` 做一次审核。

## 标准目录

最小结构：

```text
skills/<domain>/<skill-slug>/
  SKILL.md
```

完整结构：

```text
skills/<domain>/<skill-slug>/
  SKILL.md
  references/
  assets/
    templates/
  scripts/
  tests/
```

不要默认创建 README、CHANGELOG、安装指南等额外文档。skill 应优先服务 agent 执行，不是普通项目文档。

## SKILL.md 要求

Frontmatter 必须包含：

```yaml
---
name: skill-slug
description: 清楚说明该 skill 做什么，以及什么情况下应该使用。
---
```

正文应包含：

- 使用场景
- 输入和输出
- 执行流程
- 需要读取的 references
- 验证或交付标准

正文应保持精简。超过 500 行时，优先拆到 `references/`。

## 分类判断

优先按 skill 解决的问题归类，而不是按使用的工具归类。

- 嵌入式固件、MCU、RTOS、驱动、总线、硬件调试放入 `embedded/`
- 软件工程、代码审查、重构、测试、API、CI 放入 `software-engineering/`
- 数据结构、算法题、优化、复杂度分析放入 `algorithms/`
- 模型、RAG、评测、提示词、训练和推理放入 `ai-ml/`
- 部署、容器、Kubernetes、发布和运维放入 `devops/`
- 安全审计、威胁建模、漏洞修复、权限设计放入 `security/`
- 技术写作、架构文档、API 文档放入 `docs/`
- 创建和治理 skill 的能力放入 `_meta/`

如果一个 skill 横跨多个领域，放入主要交付结果所在的领域，并在注册表中补充 tags。

## 质量标准

一个可合入的 skill 应满足：

- 触发条件具体，避免覆盖过宽。
- 流程可执行，避免只写理念。
- 命名稳定，不依赖团队黑话。
- 引用资料按需加载，不把大段参考内容塞进 `SKILL.md`。
- 没有硬编码个人路径、临时密钥或内部敏感信息。
- 已更新 `registry/skills.yaml`。

## 参考资料

- 分类规则：`references/category-guide.md`
- 审核清单：`references/review-checklist.md`
- 命名规则：`references/naming.md`
- 模板：`assets/templates/SKILL.md`
