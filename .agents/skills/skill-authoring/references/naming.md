# Skill 命名规则

## 目录名

目录名使用 slug：

- 只使用小写字母、数字和连字符
- 不使用空格、下划线、中文或特殊符号
- 长度建议不超过 64 个字符
- 优先使用动宾结构或明确能力名

推荐：

```text
code-review
stm32-debugging
rag-evaluation
api-design
release-automation
```

不推荐：

```text
skill1
common
AI工具
my_best_skill
```

## name 字段

`SKILL.md` frontmatter 中的 `name` 应与目录 slug 一致。

```yaml
---
name: code-review
description: ...
---
```

## description 字段

`description` 是触发 skill 的关键，应包含：

- 这个 skill 做什么
- 什么情况下应该使用
- 关键任务、文件类型或工作流

不要写成泛泛的宣传语。

推荐：

```yaml
description: 当用户需要审查代码变更、识别缺陷、回归风险、测试缺口或可维护性问题时使用。
```

不推荐：

```yaml
description: 一个强大的代码工具。
```
