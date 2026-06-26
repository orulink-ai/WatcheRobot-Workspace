# App.Center Stage 2 真机验收记录模板

本文档用于记录真实 Watcher 设备上的 App.Center 应用包闭环证据。填写完成前，不应把 App.Center Stage 2 标记为 `100 / 100`。

## 1. 环境信息

| 项目 | 记录 |
| --- | --- |
| 验收日期 |  |
| 验收人员 |  |
| 桌面端分支 / commit |  |
| server 分支 / commit |  |
| ESP32 分支 / commit |  |
| Watcher 设备编号 / MAC |  |
| 电脑 LAN IP |  |
| Watcher IP |  |
| WebSocket 端口 | `8765` |
| UDP discovery 端口 | `37020` |
| App.Center 包源 |  |
| Release channel | stable / prerelease / local |

## 2. 在线连接闭环

| 步骤 | 期望结果 | 实际结果 |
| --- | --- | --- |
| 启动桌面端 watcher-server | `8765` / `8766` 监听正常 |  |
| 打开 App.Center | 未选中设备时显示连接诊断 |  |
| Watcher 进入客户端联网路径 | Watcher 发起 discovery / WebSocket hello |  |
| 查询 `/api/admin/discovered-devices` | `online_hardware_count` 从 `0` 变为 `1` |  |
| App.Center 选中 Watcher | Device status 显示目标设备和 IP |  |

证据粘贴区：

```text

```

## 3. 包源与发布策略

| 步骤 | 期望结果 | 实际结果 |
| --- | --- | --- |
| Stable 发布包 | `ESP-NOW Remote` 显示 `Official package source` |  |
| Stable 官方包源 | URL 使用 `https://`，不指向 `127.0.0.1`、`localhost` 或 `::1` |  |
| Prerelease 或本地调试包 | 如显示 `Developer sample source`，仅用于内测 / 售后 / 开发调试 |  |
| 点击 `Download app` | 页面内下载确认面板出现，不使用系统弹窗 |  |
| 下载确认面板 | 显示来源标签、下载 URL，并说明只下载到桌面端缓存 |  |
| `Esc` 取消下载确认 | 确认面板关闭，不开始下载 |  |

证据粘贴区：

```text

```

## 4. ESP-NOW Remote 下载与安装

| 步骤 | 期望结果 | 实际结果 |
| --- | --- | --- |
| 点击 `Download app` | `ESP-NOW Remote` 进入桌面端缓存 |  |
| 选择暂存包 | 包详情显示 id、version、SHA-256、size |  |
| 点击 `Transfer / install` | 只发送到当前选中 Watcher |  |
| 等待设备回报 | 收到 `installed` 或等价成功状态 |  |

记录：

| 项目 | 值 |
| --- | --- |
| app id | `espnow-remote` |
| package version |  |
| package SHA-256 |  |
| transfer command id |  |
| install result |  |
| ESP32 status event |  |

证据粘贴区：

```text

```

## 5. 打开与卸载

| 步骤 | 期望结果 | 实际结果 |
| --- | --- | --- |
| 点击 `Open on device` 且需要二次确认时 | 页面内确认面板出现，不使用系统弹窗 |  |
| 点击 `Open on device` | 当前选中 Watcher 打开 ESP-NOW Remote |  |
| 设备端回报 | 收到 `opening` 后进入运行状态或收到成功反馈 |  |
| 返回 App.Center 管理视图 | 可继续看到设备端应用状态 |  |
| 点击 `Uninstall from device` | 页面内确认面板说明只卸载设备端应用，不删除桌面端缓存 |  |
| `Esc` 取消卸载确认 | 确认面板关闭，不发送卸载命令 |  |
| 点击 `Uninstall from device` | 只卸载设备端应用，不删除桌面端缓存 |  |
| 刷新 Device apps | `ESP-NOW Remote` 不再显示为已安装 |  |
| 点击 `Remove local` | 页面内确认面板说明只删除桌面端缓存，不卸载 Watcher 应用 |  |
| `Esc` 取消 Remove local | 确认面板关闭，不删除桌面端缓存 |  |
| 确认 `Remove local` | 只删除桌面端缓存，设备端安装状态不被修改 |  |

记录：

| 项目 | 值 |
| --- | --- |
| open command id |  |
| open result |  |
| uninstall command id |  |
| uninstall result |  |
| Device apps refresh result |  |

证据粘贴区：

```text

```

## 6. 断连重连恢复

| 步骤 | 期望结果 | 实际结果 |
| --- | --- | --- |
| 断开 Watcher 网络或退出客户端联网路径 | 桌面端显示设备离线或控制通道不可用 |  |
| 重新进入客户端联网路径 | Watcher 重新上线 |  |
| App.Center 自动或手动刷新设备应用列表 | Device apps 恢复设备端已安装状态 |  |

证据粘贴区：

```text

```

## 7. 签名安全验收

| 包类型 | 期望结果 | 实际结果 |
| --- | --- | --- |
| 合法生产签名包 | 安装成功 |  |
| digest 被篡改 | `install_failed` |  |
| 未受信 public key | `install_failed` |  |
| 错误 issuer | `install_failed` |  |

记录：

| 项目 | 值 |
| --- | --- |
| trusted public key SHA-256 |  |
| valid package command id |  |
| tampered digest command id |  |
| untrusted key command id |  |
| wrong issuer command id |  |

证据粘贴区：

```text

```

## 8. 最终结论

| 项目 | 通过 / 失败 / 待补 |
| --- | --- |
| 在线连接闭环 |  |
| 包源与发布策略 |  |
| 下载与安装 |  |
| 打开与卸载 |  |
| 断连重连恢复 |  |
| 签名安全验收 |  |

结论：

```text

```

若任一项目为失败或待补，App.Center Stage 2 不能标记为完整完成。
