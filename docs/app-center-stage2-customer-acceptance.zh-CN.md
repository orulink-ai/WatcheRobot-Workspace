# App.Center Stage 2 客户验收清单

本文档用于判断 App.Center 应用包方案是否达到客户可用、开发者可扩展、架构可维护的交付标准。

当前阶段正式支持的可下载应用只有 `ESP-NOW Remote`。Launcher 内置的蓝牙、客户端、语音、配网等本地功能不属于 App.Center 可下载应用，不应被 App.Center 安装或卸载。

## 1. 产品路径验收

客户从 App.Center 进入时，必须能理解下面的路径：

```text
获取应用包
  ↓
选择一台在线 Watcher
  ↓
传输并安装
  ↓
打开设备端应用
  ↓
按需卸载设备端应用
```

验收标准：

- App.Center 首屏能看到 `ESP-NOW Remote`。
- 未下载时，客户能看到下载入口。
- 正式客户路径使用官方包源或桌面端导入包，不要求客户启动本地样例源。
- 官方发布包可通过 `VITE_WATCHER_ESPNOW_REMOTE_PACKAGE_URL` 注入默认下载源；未配置时只允许退回开发者样例源。
- 已暂存时，客户能看到传输安装入口。
- 已安装时，客户能看到打开和卸载入口。
- 桌面端本地缓存删除和设备端卸载必须明确区分。
- 没有在线 Watcher 时，界面必须告诉客户下一步应该连接设备，而不是只显示空状态。

## 2. 连接诊断验收

当没有在线 Watcher 时，App.Center 必须显示可操作诊断。

验收标准：

- 显示 `Waiting for Watcher on the LAN` 或等价提示。
- 显示桌面端 LAN 服务地址，例如 `192.168.x.x:8765`。
- 显示 UDP discovery 端口，例如 `37020`。
- 显示控制通道状态。
- 提供 `Open connection guide` 入口，跳转到 Hardware Connect。

客户含义：

```text
电脑端服务已经准备好
Watcher 还没有完成 discovery / WebSocket 连接
请在 Watcher 上进入客户端联网路径
```

## 3. 安装与卸载语义验收

必须保持以下语义，不允许混淆：

| 操作 | 含义 | 不应发生 |
| --- | --- | --- |
| Download app | 下载到桌面端缓存 | 不应安装到设备 |
| Transfer / install | 发送到当前选中的 Watcher 并安装 | 不应广播给所有设备 |
| Open on device | 打开当前选中 Watcher 上已安装的应用 | 不应打开未安装应用 |
| Uninstall from device | 卸载当前选中 Watcher 上的 App.Center 应用 | 不应删除桌面端缓存 |
| Remove local | 删除桌面端缓存 | 不应卸载任何设备应用 |

## 4. 自动化防回退验收

当前已建立的防回退层：

- 服务端 `/api/admin/discovered-devices` 暴露 `discovery.local_ip` 和 `discovery.ws_port`。
- 服务端测试保护 discovery 元数据字段。
- Dashboard 统一解析并传递 `discoveryRuntime`。
- App.Center 使用 `discoveryRuntime.localIp` 和 `discoveryRuntime.wsPort` 生成连接诊断。
- App.Center 静态守卫保护连接诊断文案、跳转入口和客户流程文档。

这些自动化守卫只能证明静态契约和 UI 语义没有明显回退，不能替代真机验收。

## 5. 真机闭环验收

必须在真实 Watcher 上完成：

```text
Watcher 进入客户端联网路径
  ↓
桌面端 online_hardware_count 从 0 变 1
  ↓
下载 ESP-NOW Remote
  ↓
Transfer / install 成功
  ↓
Open on device 成功
  ↓
Uninstall from device 成功
  ↓
断连重连后 Device apps 状态恢复
```

验收记录应包含：

- 桌面端服务地址。
- Watcher IP。
- `online_hardware_count` 变化。
- 安装 command id。
- 打开 command id。
- 卸载 command id。
- 设备端 `evt.app.package.status` 或 `evt.app.package.list` 回报。

## 6. 安全验收

正式发布前必须验证签名路径：

- 合法生产签名包安装成功。
- digest 被篡改的包被拒绝。
- 未受信 public key 的包被拒绝。
- 错误 issuer 的包被拒绝。
- 失败时设备端回报 `install_failed`。

## 7. 当前评分

当前基于代码、文档和自动守卫的评分：

| 维度 | 分数 | 说明 |
| --- | ---: | --- |
| 客户路径清晰度 | 94 | 下载、安装、打开、卸载语义已经清楚 |
| 连接诊断 | 95 | 已能显示 LAN 服务地址并跳转 Hardware Connect |
| 架构边界 | 92 | App.Center、Dashboard、server discovery 边界清楚 |
| 自动化防回退 | 94 | 接口字段、数据流、UI 文案、客户文档均有守卫 |
| 真机闭环证据 | 70 | 仍缺完整安装、打开、卸载、重连恢复实测 |
| 安全签名证据 | 80 | 方案存在，仍需真机 fixture 验证 |

综合评分：`92 / 100`。

## 8. 距离满分还缺什么

要达到 `100 / 100`，不能只靠静态代码和文档，需要补齐以下证据：

- 真机在线闭环完成。
- ESP-NOW Remote 安装、打开、卸载均成功。
- 断连重连后 Device apps 状态恢复。
- 签名成功和三类失败路径全部通过真机验证。
- 客户从空状态进入连接引导，再回到 App.Center 的路径无歧义。

完成以上项目后，才可以把目标标记为完整完成。
