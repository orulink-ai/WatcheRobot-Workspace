# App.Center 客户使用流程与连接诊断

本文档面向客户、开发者和售后调试人员，说明如何从桌面端 App.Center 完成可下载应用的管理流程。

当前阶段只有 `ESP-NOW Remote` 是正式支持的可下载 App.Center 应用。Launcher 里的蓝牙、客户端、语音、配网等功能是设备本地固定功能，不通过桌面端 App.Center 安装、打开或卸载。

## 1. 客户视角的完整路径

```text
打开桌面端 App.Center
  ↓
确认桌面端 watcher-server 已启动
  ↓
在 Watcher 上进入客户端联网路径
  ↓
桌面端发现并选中在线 Watcher
  ↓
下载或导入 ESP-NOW Remote 应用包
  ↓
检查包信息、签名、大小和兼容性
  ↓
Transfer / install 到选中的 Watcher
  ↓
安装成功后 Open on device
  ↓
需要删除时 Uninstall from device
```

普通客户不应需要运行命令、手动启动脚本或理解端口细节。桌面端应自动启动 watcher-server，并在 App.Center 中用可理解的状态卡提示连接问题。

开发者或售后人员可以使用样例源、签名工具和验收脚本进行调试，但这些工具不应成为普通客户下载、安装、打开或卸载应用的必经步骤。

`127.0.0.1:8767` 是开发者调试样例源，不是普通客户必经下载入口。正式发布路径应使用官方包源或桌面端导入的应用包；如果界面显示开发者样例源不可达，普通客户不需要启动脚本，应改用官方来源或售后提供的应用包。

桌面端发布包可以通过 `VITE_WATCHER_ESPNOW_REMOTE_PACKAGE_URL` 注入 `ESP-NOW Remote` 的官方包源。未配置官方包源时，界面只会退回开发者样例源，用于本地联调和售后复现，不应作为客户正式交付路径。

App.Center 卡片必须直接显示当前来源标签：`Official package source` 表示客户正式下载路径，`Developer sample source` 表示本地调试路径。

## 2. App.Center 不负责的事情

App.Center 只管理可下载应用包，不管理设备本地固定功能。

它不负责：

- 删除 Launcher 本地功能。
- 删除蓝牙 App、客户端 App、语音 App、配网 App。
- 广播安装到所有 Watcher。
- 在没有选中设备时静默发送安装、打开或卸载命令。

## 3. 没有在线 Watcher 时客户应该看到什么

当 App.Center 没有选中在线 Watcher 时，界面必须告诉客户下一步，而不是只显示空状态。

应显示的信息包括：

- 桌面端服务是否已经运行。
- 当前桌面端用于局域网发现的地址，例如 `192.168.1.105:8765`。
- UDP discovery 端口，例如 `37020`。
- 当前控制通道状态。
- 入口按钮 `Open connection guide`，跳转到 Hardware Connect 页面。

客户看到 `Waiting for Watcher on the LAN` 时，含义是：

```text
电脑端服务已经准备好
Watcher 还没有完成 LAN discovery 或 WebSocket hello
请在 Watcher 上进入客户端联网路径
```

客户看到 `Watcher discovered, waiting for control channel` 时，含义是：

```text
电脑已经收到 Watcher 的 UDP discovery
Watcher 还没有完成 WebSocket 控制通道握手
请保持 Watcher 在客户端 App 或 App.Center 联网模式
```

## 4. 下载、打开和卸载的语义

`Download app` 只表示把应用包下载到桌面端缓存，不代表已经安装到 Watcher。

`Transfer / install` 表示把当前桌面端缓存的应用包发送到当前选中的 Watcher，并由设备端 install manager 安装。

`Open on device` 只打开当前选中的 Watcher 上已经安装的 App.Center 应用。

`Uninstall from device` 只卸载当前选中的 Watcher 上的 App.Center 应用，不删除桌面端缓存。

`Remove local` 只删除桌面端缓存，不卸载任何 Watcher 设备上的应用。

## 5. 面向开发者的添加应用原则

开发者可以导入或下载自定义 `.watcherapp`、`.watcher-app`、`.pkg` 或 JSON manifest 包，用于调试包格式、签名、SHA-256 和分片传输链路。

但是能否真正安装和运行，最终由设备端 install manager 决定。

第一阶段正式支持的可下载应用只有：

```text
id: espnow-remote
name: ESP-NOW Remote
```

其他自定义包可以进入桌面端检查和传输流程，但设备端可能因为 entry、权限、签名、兼容性或固件能力不足而拒绝安装。

## 6. 满分交付标准

要把 App.Center 评为 `100 / 100`，必须同时满足：

- 客户能按界面提示完成连接，不需要猜测应该进入哪个设备模式。
- 没有在线 Watcher 时，App.Center 能清楚显示桌面端 LAN 地址和下一步操作。
- 只能对选中的单台 Watcher 传输、打开或卸载应用，不能广播。
- 桌面端缓存删除和设备端卸载语义完全分离。
- ESP-NOW Remote 能完成下载、安装、打开、卸载闭环。
- Watcher 断连重连后，桌面端能恢复设备端已安装应用列表。
- 签名成功、digest 篡改、未受信 public key、错误 issuer 都有明确验收结果。
- 自动化测试能保护接口字段、数据流、UI 文案和状态机边界。

## 7. 当前仍需真机验证的项目

当前代码侧已经具备 App.Center 应用包管理、连接诊断、设备端命令和防回退测试的基础能力。

仍需真机确认：

- Watcher 进入客户端联网路径后，桌面端 `online_hardware_count` 从 `0` 变为 `1`。
- `ESP-NOW Remote` 能通过官方包源或导入包完成下载/导入。
- 应用包能传输并安装到选中的 Watcher。
- `Open on device` 能启动设备端应用。
- `Uninstall from device` 能删除设备端应用，且不删除桌面端缓存。
- 断连重连后 `Device apps` 能恢复已安装应用状态。
