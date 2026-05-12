---
name: embedded-pr-robustness-review
description: 合并前审查嵌入式固件 PR 的鲁棒性、稳定性、并发、内存生命周期、硬件资源、协议边界、状态机、存储/OTA、日志、看门狗和错误恢复风险。当用户要求 PR review、嵌入式代码审查、ESP-IDF/FreeRTOS C/C++ 改动审查、MCU link 或线协议改动审查、HAL/driver/service 层改动审查、WatcheRobot S3 固件审查时使用。
---

# 嵌入式 PR 鲁棒性审查

## 目的

用这个 skill 审查普通格式检查容易漏掉的固件缺陷：竞态、堆内存生命周期错误、ISR/task 误用、协议边界条件、硬件资源冲突、不安全降级、缺少验证证据等。

默认只做审查，不改代码、不烧录硬件、不运行硬件脚本，除非用户明确要求执行。

## 快速开始

1. 用常规仓库工具了解 PR 上下文，优先使用 `git diff`、`git status`、`rg` 和定向读取文件。
2. 本地仓库可用时，可运行只读上下文收集器：

   ```powershell
   python <skill-dir>\scripts\collect_pr_review_context.py --repo .
   ```

3. 读取通用检查清单：`references/embedded-review-checklist.md`。
4. 如果仓库是 WatcheRobot S3，或改动涉及 `components/`、`main/`、MCU 通信、HAL、LVGL/display、animation、camera、OTA、BLE、Wi-Fi、service 代码，再读取 `references/watche-s3-risk-map.md`。
5. 输出格式参考 `references/review-output-template.md`。

## 审查流程

1. 确定审查范围：变更文件、API、模块归属、生成资源、配置和测试文件。
2. 按风险域分类：内存、并发、ISR/task 边界、队列/定时器/事件循环、协议解析、硬件资源、状态机、存储/OTA、日志、看门狗、错误恢复。
3. 检查跨层契约：HAL/driver API、协议接口、service 所有权、全局状态、启动/关闭顺序、调用方/被调用方错误语义。
4. 人工审查高风险路径：先看变更代码，再看邻近调用方，再看初始化和恢复路径。
5. 将风险和验证证据匹配起来。高风险嵌入式改动不能只靠 build 通过。
6. 先输出问题，按严重程度排序。即使没有代码问题，也要说明缺少的测试或硬件验证。

## 严重程度

- `Blocker`：可能导致崩溃、内存破坏、数据丢失、设备变砖、不安全硬件状态、协议死锁、看门狗复位循环，或高风险代码缺少合并前必须的验证。
- `High Risk`：可能出现现场故障、竞态、泄漏、资源冲突、恢复失败、状态机破坏或 API 契约破坏，应修复或显式接受风险后再合并。
- `Medium`：影响可控的鲁棒性缺口、边界条件缺失、可观测性不足、弱降级或非关键行为缺少定向测试。
- `Low`：维护性或诊断问题，短期不太会失败，但可能掩盖未来缺陷。

## 输出要求

必须包含这些部分：

- `Blockers`
- `High Risk`
- `Medium/Low`
- `Missing Verification`
- `No Finding Areas`

每个问题都要包含严重程度、文件/行号、问题、鲁棒性影响、建议修复和建议验证。如果某一部分没有发现问题，写 `None found`。

如果宿主支持行内评论，且用户要求 review，对可执行的问题使用 `::code-comment{...}`，行范围保持精确。

## 验证建议

只推荐检查项；除非用户明确要求，不运行硬件相关检查。

- 构建/配置：`idf.py build`、`sdkconfig.defaults*`、component manager 依赖改动。
- Host tests：协议核心、parser、CRC/COBS、frame 处理、纯状态机和序列化的 CTest/CMake host 测试。
- 硬件 smoke：烧录/监控、启动日志、看门狗稳定性、外设初始化、传感器/执行器路径、显示/音频/相机路径。
- 压力/回归：重连循环、畸形帧、队列饱和、heap/PSRAM 压力、SD/SPI 争用、Wi-Fi/BLE 重连、OTA 失败路径。

WatcheRobot S3 硬件验证时，只有在用户明确要求执行时，才使用 `watche-s3-flash-monitor`、`watche-dual-mcu-bringup` 等相关 skill。

## 附带资料

- `references/embedded-review-checklist.md`：通用嵌入式审查清单。
- `references/watche-s3-risk-map.md`：WatcheRobot S3 模块风险图和建议验证。
- `references/review-output-template.md`：最终审查输出模板。
- `scripts/collect_pr_review_context.py`：只读 PR 上下文收集器。
