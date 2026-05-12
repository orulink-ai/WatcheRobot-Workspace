---
name: watche-design-animation-import
description: 处理 WatcheRobot 动画导入流程。当用户要求更新/导入/刷新 GIF 动画、使用飞书动画表、生成 V2 SD 卡 AnimPack 资源、同步或烧写动画资源到 SD 卡时使用。该流程处理设计侧 GIF 目录或本地日期目录，通过 `lark-cli` 获取中文源名到英文动画类型的映射，校验 ESP32 已注册动画类型，更新 `assets/gif`，重新生成 RGB565 字节序正确的 `anim_manifest.bin` 和 `.animpack`，并可选同步到 SD 卡。
---

# 设计动画导入

用户要求获取、导入、刷新、诊断、生成或同步 WatcheRobot 动画资源时使用。这个流程由 Codex 执行；除非用户明确要求命令，否则不要让用户手动运行脚本。

## 操作约定

- “刷入 SD 卡”“更新当前动画”“按飞书表导入 GIF”“同步最新动画到 F 盘”“检查动画资源映射”等请求都触发本 skill。
- 默认固件根目录从当前工作区自动发现，通常是 `<workspace-root>\WatcheRobot_esp32\firmware\s3`；也可用 `WATCHE_S3_FIRMWARE_ROOT` 或 `--repo-root` 覆盖。
- 源 GIF 目录从用户消息推断；如果没给，使用设计根目录下最新的 `YYYY.MM.DD` 文件夹。
- 设计根目录可能是 WebDAV/网络路径，自动发现有超时风险。超时后停止并询问用户明确的 `--source-date-dir`，不要反复重试。
- SD 卡根目录从用户消息推断；没给就不要同步到 SD。
- 必须先 dry-run 预检并读取报告。
- 用户要求 apply/sync 且预检没有 blocker 时，在同一轮继续执行 apply/generate/sync。
- 遇到未映射 GIF、映射冲突、目标未注册、压缩包格式不支持、GIF 尺寸不是 206x206 时，停止并报告 blocker。
- 默认使用飞书映射。飞书读取超时或鉴权失败时，要求完成 `lark-cli auth login`，或提供 `--mapping-json <file>`。
- 执行后总结 recognized/unmapped/conflicts、是否使用 RGB565 swap、manifest 数量、SD 同步结果和改动文件。

## 默认工作区

- 固件根目录：`<workspace-root>\WatcheRobot_esp32\firmware\s3`，或 `WATCHE_S3_FIRMWARE_ROOT` / `--repo-root`
- 设计根目录：按用户提供路径，或 `WATCHE_DESIGN_ROOT` / `WATCHER_DESIGN_ROOT`
- 当前源目录模式：`YYYY.MM.DD`
- 本地源 GIF 目录：`assets/gif`
- 生成的 SD bundle：`release/<PROJECT_VER>/sdcard/anim`
- 飞书 Base token：通过 `FEISHU_BASE_TOKEN` / `LARK_BASE_TOKEN` 或 `--feishu-base-token` 提供
- 飞书 table ID：通过 `FEISHU_TABLE_ID` / `LARK_TABLE_ID` 或 `--feishu-table-id` 提供
- 飞书映射字段：`文本`、`对应英文`、`GIF文件`
- 设计根目录自动发现超时：20 秒，可用 `--design-root-timeout-seconds` 调整，`0` 表示禁用
- 飞书映射超时：30 秒，可用 `--feishu-timeout-seconds` 调整，`0` 表示禁用

## 流程

1. 先运行 dry-run：

   ```powershell
   python "<skill-dir>\scripts\import_watcher_design_anims.py" --repo-root "<esp32-root>\firmware\s3" --feishu-mapping
   ```

   如果设计目录超时，询问用户准确的日期 GIF 目录，再用 `--source-date-dir <path>` 重跑。飞书超时或鉴权失败时，让用户完成 `lark-cli auth login`，或提供本地 mapping JSON。

2. 改资源前读取报告。以下情况视为 blocker：
   - 源 GIF 文件名无法映射到 ESP32 已注册动画类型
   - 多个源 GIF 映射到同一注册类型
   - 映射目标在固件中未注册
   - 不支持的压缩包格式
   - 尺寸不是 206x206，除非固件已明确改过尺寸要求

3. 优先用 `--feishu-mapping` 从飞书导出映射。需要手工修正时，添加 `--mapping-json <file>`；手工映射覆盖飞书映射。
4. 重新生成 AnimPack 时，RGB565 字节序必须匹配固件配置：
   - 脚本在 `sdkconfig` 或 `sdkconfig.defaults` 中发现 `CONFIG_LV_COLOR_16_SWAP=y` 时会自动添加 `--lv-color-16-swap`。
   - 这可以避免 swapped LVGL 构建使用未 swap RGB565 数据导致颜色错误。
5. 需要更新 SD 卡时，在确认目标是可移动卡后传入 `--sync-target-root F:\`。

## 内部命令

这些命令给 Codex 执行，不是要求用户手动运行。

dry-run 最新设计日期目录：

```powershell
python "<skill-dir>\scripts\import_watcher_design_anims.py" --repo-root "<esp32-root>\firmware\s3" --feishu-mapping
```

dry-run 指定日期目录：

```powershell
python "<skill-dir>\scripts\import_watcher_design_anims.py" --repo-root "<esp32-root>\firmware\s3" --source-date-dir "<design-root>\2026.04.28" --feishu-mapping
```

应用映射、重新生成并同步到 SD：

```powershell
python "<skill-dir>\scripts\import_watcher_design_anims.py" --repo-root "<esp32-root>\firmware\s3" --feishu-mapping --apply --generate --sync-target-root F:\
```

可选手工 override JSON 可以是 source-to-target：

```json
{
  "微笑": "happy",
  "感叹号": "error"
}
```

也可以是 target-to-source-list：

```json
{
  "happy": ["微笑"],
  "error": ["感叹号"]
}
```

## 注册类型真源

已注册动画类型的唯一真源是目标仓库中的 `tools/generate_anim_assets.py::ANIM_TYPES`。不要在 skill 里维护第二份硬编码类型列表。无法解析 `ANIM_TYPES` 时，停止并报告注册真源不可用。

不要静默导入既不在飞书 `对应英文` 字段、也不在 ESP32 `ANIM_TYPES` 中的设计状态名；在产品/固件映射明确前，把它们报告为 unmapped。

## 回复格式

- 说明选择的源日期目录。
- 说明是否使用飞书映射，包括 `feishu_records` 和 `feishu_mapping_entries`。
- 总结 recognized、unmapped、conflicting、unsupported 动画文件。
- 明确是否使用 `--lv-color-16-swap`。
- 如果应用了资源，列出被覆盖的 canonical GIF。
- 如果执行了生成或 SD 同步，报告准确输出目录和验证结果。
