# Skill 审核清单

## 基础检查

- `SKILL.md` 存在。
- frontmatter 包含 `name` 和 `description`。
- `name` 与目录 slug 一致。
- `description` 说明了明确触发场景。
- skill 放在正确的一级领域目录下。
- `registry/skills.yaml` 已登记。

## 内容检查

- 正文包含可执行流程。
- 没有把大量参考资料堆进 `SKILL.md`。
- 长示例、详细规则、领域资料已拆到 `references/`。
- 模板类文件放在 `assets/templates/`。
- 脚本只在需要确定性执行时添加。

## 安全检查

- 不包含密钥、令牌、账号密码或内部敏感数据。
- 不硬编码个人机器路径。
- 涉及外部服务时说明数据会发送到哪里。
- 涉及破坏性操作时要求确认。

## 维护检查

- owner 明确。
- maturity 合理。
- tags 有助于搜索。
- 版本号符合语义化版本。
- 废弃 skill 标记为 `deprecated`，并说明替代方案。
