# App.Center Stage 2 验收记录模板

> 目标：证明 App.Center 应用包方案已经满足客户下载、安装、打开、卸载、断连恢复、签名安全和 UI 可理解性的交付要求。

## 1. 基本信息

| 项目 | 记录 |
| --- | --- |
| ESP32 端口 | COM32 |
| ESP32 固件 commit | 待记录 |
| Watcher 设备 ID / MAC | 待真机联调记录 |
| Desktop app commit | 待记录 |
| Server commit | 待记录 |
| 验收人 | 待记录 |
| 验收时间 | 2026-06-25 |

## 2. 自动化验证证据

运行命令：

```powershell
cd "D:\GithubRep\WatcheRobot-Workspace\WatcheRobot_client\Watcher Desktop App"
npm run appcenter:verify:run
```

本轮结果：

```text
Automated checks completed.
Manual device flow, device-side signing acceptance, and customer UI review evidence are still required for 100/100.
```

| 检查项 | 结果 | 证据 |
| --- | --- | --- |
| Desktop App.Center static guard tests | 通过 | `26 passed` |
| App.Center signing fixture generation | 通过 | 生成 valid / tampered / untrusted key / wrong issuer 四类验收包 |
| Desktop typecheck | 通过 | `tsc --noEmit` 无错误 |
| Desktop renderer build | 通过 | `vite build` 成功 |
| Server protocol tests | 通过 | `20 passed` |
| App.Center sample catalog checks | 通过 | `apps.json` 和 `espnow_remote.pkg` 本地 HTTP smoke test 通过 |
| ESP32 build | 通过 | `WatcheRobot-S3.bin binary size 0x221420 bytes`，app 分区 `0x400000`，剩余约 47% |

补充验证：

```powershell
cd "D:\GithubRep\WatcheRobot-Workspace\WatcheRobot_client\Watcher Desktop App"
node --test ./scripts/app-center-workflow-copy.test.mjs
npm run typecheck
```

结果：

```text
tests 11
pass 11
tsc --noEmit passed
```

说明：App.Center 现在有干净的 UI 预览入口，可通过 `?view=app-center` 直接打开 App.Center 模块，便于后续真实桌面窗口截图和客户视角走查。

真实桌面客户端推荐启动方式：

```powershell
cd "D:\GithubRep\WatcheRobot-Workspace\WatcheRobot_client\Watcher Desktop App"
$env:WATCHER_INITIAL_DASHBOARD_VIEW = "app-center"
npm run dev
```

说明：`scripts/run-dev.mjs` 会把 `WATCHER_INITIAL_DASHBOARD_VIEW` 映射为前端可见的 `VITE_WATCHER_INITIAL_DASHBOARD_VIEW`，因此真实 Tauri 桌面窗口可以直接进入 App.Center，不需要手动从 Dashboard 切换模块。

2026-06-25 真实桌面启动证据：

| 检查项 | 结果 | 证据 |
| --- | --- | --- |
| Tauri 主进程 | 通过 | `watcher-desktop.exe` 已启动 |
| WebView2 renderer | 通过 | `msedgewebview2.exe` 已启动并绑定 `watcher-desktop.exe` |
| Vite dev server | 通过 | `http://localhost:54321` 返回 `200` |
| Watcher WebSocket | 通过 | `0.0.0.0:8765` 处于 Listen |
| Watcher HTTP 服务 | 通过 | `127.0.0.1:8766` 处于 Listen；`/health` 返回 `405`，说明服务端已响应但该路径/方法不允许 |
| App.Center 本地样例源 | 通过 | `http://127.0.0.1:8767/apps.json` 返回 `200` |
| Watcher 在线状态 | 未通过闭环前置条件 | `GET /api/admin/discovered-devices` 返回 `online_hardware_count=0`，`devices=[]`，`discovered_devices=[]` |
| Watcher 上线轮询 | 未通过闭环前置条件 | 2026-06-25 20:57:46 至 20:58:43 连续 12 次轮询，`online_hardware_count` 始终为 `0` |
| Watcher 二次上线轮询 | 未通过闭环前置条件 | 2026-06-25 21:00:02 至 21:00:38 连续 8 次轮询，`online_hardware_count` 始终为 `0` |
| ESP32 串口只读检查 | 无有效新证据 | `COM32` 可打开，但 20 秒纯串口读取未捕获新日志；无法证明设备已进入客户端连接模式 |
| App.Center 真实视觉走查 | 待确认 | 需要人工查看桌面窗口是否直接进入 App.Center，并按客户视角检查首屏、ESP-NOW Remote 卡片、导入/下载、安装管理、卸载文案 |

## 3. ESP32 烧录与启动验证

烧录端口：

```powershell
COM32
```

启动日志：

```text
D:\GithubRep\WatcheRobot-Workspace\WatcheRobot_esp32\firmware\s3\build-no-wake\monitor-com32-20260625-195407.log
```

| 检查项 | 结果 | 证据 |
| --- | --- | --- |
| 固件烧录 | 通过 | 烧录后进入 monitor 并输出启动日志 |
| Launcher 启动 | 通过 | `launcher_ready` |
| 触摸初始化 | 通过 | `touch_ready=1` |
| 旋钮初始化 | 通过 | `knob_ready=1` |
| SD 卡资源 | 通过 | SD 卡识别成功，`anim` 目录和 30 个资源条目可见 |
| STM32 链路 | 通过 | `MCU link baseline restore completed`，`link_state=READY` |
| 崩溃检查 | 通过 | 未发现 panic / abort / Guru Meditation / 重启循环 |
| Wi-Fi 状态 | 注意 | Launcher 阶段出现一次历史凭据连接失败日志：`WiFi connect failed or disconnected: ssid=orulink`，当前不判定为阻塞 |

## 4. 真机 App.Center 流程

> 当前状态：待真实桌面客户端连接在线 Watcher 后验证。自动化测试和 ESP32 构建不能替代这一项。

| 步骤 | 预期结果 | 结果 |
| --- | --- | --- |
| 打开 Desktop App.Center，并只选择 1 台在线 Watcher | App.Center 显示当前设备可操作状态 | 待验证 |
| 导入或下载 ESP-NOW Remote 应用包 | 应用包出现在 Staged apps 中 | 待验证 |
| 点击安装到设备 | 传输和安装完成，设备状态变为 installed | 待验证 |
| 点击 Open on device | Watcher 进入 ESP-NOW Remote 应用 | 待验证 |
| 回到 App.Center 后点击 Uninstall from device | 只卸载设备侧可下载应用，不删除桌面缓存 | 待验证 |
| Refresh device apps | 已卸载应用不再出现在设备应用列表 | 待验证 |
| 断开再重连 Watcher | 设备应用状态重新同步，没有 stale global fallback | 待验证 |

## 5. 生产签名安全验收

生成验收包命令：

```powershell
cd "D:\GithubRep\WatcheRobot-Workspace\WatcheRobot_client\Watcher Desktop App"
npm run appcenter:signing-fixtures -- --out "C:\Users\Administrator\AppData\Local\Temp\watcher-appcenter-signing-fixtures-verify"
```

本轮生成结果：

| 项目 | 记录 |
| --- | --- |
| Fixture directory | `C:\Users\Administrator\AppData\Local\Temp\watcher-appcenter-signing-fixtures-verify` |
| trustedIssuer | `watche-test-issuer` |
| wrongIssuer | `watche-wrong-issuer` |
| trustedPublicKeySha256 | `bb382324e8a97ffd6e17838cb8c79e5dc888006ce3419271263869c76aa565ec` |
| untrustedPublicKeySha256 | `faf3dd2daa8f0697817fdf7e2d30846182ee275bca24ac5f59bca7433b7bfd2a` |

将 `trustedPublicKeySha256` 和 `trustedIssuer` 配置到 ESP32 后，逐个安装以下包：

| 包 | 预期结果 | 结果 |
| --- | --- | --- |
| `01-valid-trusted.pkg` | 安装成功 | 待设备侧验证 |
| `02-tampered-digest.pkg` | 返回 `install_failed` | 待设备侧验证 |
| `03-untrusted-key.pkg` | 返回 `install_failed` | 待设备侧验证 |
| `04-wrong-issuer.pkg` | 返回 `install_failed` | 待设备侧验证 |

## 6. 客户 UI 审查

> 审查原则：从普通客户视角检查，不阅读协议文档也应该知道下一步做什么。

| 场景 | 验收标准 | 结果 |
| --- | --- | --- |
| App.Center 首屏 | 能看懂 `Get package -> Pick Watcher -> Install or manage` 三步流程 | 自动化文案检查通过，待真实客户端 UI 走查 |
| 首屏下一步提示 | 当前下一步 guidance 具备可访问性语义：`role="status"` / `aria-live="polite"` | 自动化文案检查通过，待真实客户端 UI 走查 |
| ESP-NOW Remote 入口 | 首屏能直接看到可下载应用卡片，而不是只暴露开发者导入工具 | 自动化检查通过，待真实客户端 UI 走查 |
| App.Center 预览入口 | 能直接打开 App.Center 进行 UI 验收，不必先手动从 Dashboard 切模块 | 已新增并验证 `?view=app-center` 和 `WATCHER_INITIAL_DASHBOARD_VIEW=app-center`，守卫测试、typecheck 和完整 Stage2 自动化验收均通过 |
| 浏览器 renderer 走查 | 在普通浏览器中打开 renderer，用截图证明真实布局 | 2026-06-25 尝试：Vite `127.0.0.1:5173` 可访问，本地样例源 `127.0.0.1:8767/apps.json` 返回 200；新增 `?view=app-center` 后，Chrome headless 仍无法稳定产出 App.Center 截图，不能作为 UI 通过证据；后续使用真实 Tauri 桌面客户端窗口走查 |
| 下载失败提示 | 本地样例源未启动时，提示用户启动 sample server 或手动导入包 | 自动化检查通过 |
| 空状态 | 告诉用户下一步应导入或下载应用包，而不是空白面板 | 自动化检查通过，待真实客户端 UI 走查 |
| Staged apps | 能明确当前选中了哪一个应用包 | 待真实客户端 UI 走查 |
| Install and manage | 主要操作清晰：传输安装、打开设备应用、卸载设备应用 | 待真实客户端 UI 走查 |
| Device status | 能看懂设备是否在线、是否 busy、是否 installed | 自动化状态类别检查通过，待真实客户端 UI 走查 |
| Remove local | 明确只删除桌面本地缓存，不卸载设备应用 | 自动化文案检查通过 |
| Uninstall from device | 明确只卸载设备侧 App.Center 应用，不删除桌面缓存 | 自动化文案检查通过 |
| 技术细节 | 协议、签名、frame 等细节不压过客户主流程 | 待真实客户端 UI 走查 |

## 7. 当前评分

| 维度 | 当前评分 | 说明 |
| --- | --- | --- |
| 架构隔离 | 96 / 100 | 本地 Launcher、本地 app、App.Center 可下载 app 边界已建立，仍需更多真机闭环证据 |
| 客户使用流程 | 97 / 100 | 下载、导入、传输、安装、打开、卸载路径已形成，真实客户端闭环待验证 |
| App.Center 下载/安装模型 | 97 / 100 | 应用包模型和样例源通过自动化验证，生产签名设备侧验收待完成 |
| 客户端 UI | 97 / 100 | 首屏流程、应用卡片、失败提示、危险操作文案已有守卫，仍需真实 UI 走查 |
| 自动化验收覆盖 | 96 / 100 | 桌面、服务端、ESP32 构建和样例源均已覆盖；硬件交互仍需人工证据 |
| 真机闭环证据 | 85 / 100 | 已完成烧录和启动验证，尚未完成 App.Center 真机安装/打开/卸载闭环 |

综合评分：`96 / 100`

## 8. 结论

| 项目 | 是否通过 |
| --- | --- |
| 自动化检查 | 通过 |
| ESP32 烧录与启动 | 通过 |
| 真机安装/打开/卸载流程 | 待验证 |
| 生产签名安全验收 | 待验证 |
| 客户 UI 审查 | 待真实客户端走查 |

最终结论：

```text
当前不能标记为 100/100 通过。

已证明：桌面端、服务端、样例源、ESP32 构建、ESP32 烧录启动均通过。

阻塞 100/100 的剩余证据：
1. 真实桌面客户端连接在线 Watcher 后，完成 ESP-NOW Remote 下载/导入、安装、打开、卸载、刷新和断连重连恢复。
2. 使用签名验收包完成设备侧 valid / tampered / untrusted key / wrong issuer 四类安装策略验证。
3. 用真实桌面客户端做客户视角 UI 走查，确认首屏、空状态、安装管理和危险操作都符合普通客户习惯；普通浏览器 headless renderer 当前停留在 preboot/loading，不能替代桌面端验收。

2026-06-25 当前真实阻塞点：
桌面客户端、服务端和 App.Center 本地样例源均已启动，但服务端设备状态接口返回 online_hardware_count=0，且 2026-06-25 20:57:46 至 20:58:43 连续 12 次轮询、21:00:02 至 21:00:38 连续 8 次轮询仍为 0，因此还不能执行安装/打开/卸载真机闭环。需要先让 Watcher 进入客户端/Wi-Fi 连接模式并连接到当前桌面服务端。
```
