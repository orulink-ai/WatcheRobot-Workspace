# App.Center 产品、架构与 UI 评分卡

本文档用于持续评估 App.Center 是否达到了客户可用、开发者可扩展、架构可维护、UI 易理解的目标。

当前目标不是“代码能跑就算完成”，而是客户可以自然完成：

```text
下载或导入 ESP-NOW Remote
  -> 确认桌面端只是在缓存应用包
  -> 选择一台在线 Watcher
  -> Transfer / install 到设备
  -> Open on device
  -> Uninstall from device
  -> 必要时 Remove local，仅删除桌面缓存
```

## 当前评分

当前综合评分：`95 / 100`

| 维度 | 分数 | 说明 |
| --- | ---: | --- |
| 客户路径清晰度 | 96 | 下载、传输安装、打开、卸载、本地缓存删除已经拆清楚。 |
| UI 一致性 | 96 | Featured app、来源标签、页面内确认面板、连接辅助、状态栏和复制摘要已产品化并接入多语种；仍需要真实窗口走查记录。 |
| 架构边界 | 95 | App.Center、设备控制、桌面缓存、官方源、开发者样例源、连接辅助和摘要生成职责边界更清晰，不再依赖英文标题字符串推断状态。 |
| 开发者扩展性 | 92 | 支持导入/下载 app package，但当前正式支持应用仍只有 ESP-NOW Remote。 |
| 防误操作能力 | 96 | 高风险操作走页面内确认，Esc 可取消，busy 时不会取消正在执行动作。 |
| 多语种完整度 | 95 | App.Center 核心页面、状态提示、连接辅助、操作 hint、复制摘要已覆盖 en / zh-CN / ja；仍需真实窗口下逐页走查。 |
| 真机闭环证据 | 86 | 仍缺完整设备下载、安装、打开、卸载、断连重连恢复的最终记录。 |

## 满分标准

达到 `100 / 100` 必须同时满足：

- 普通客户不需要运行命令、启动样例服务或理解端口细节。
- `ESP-NOW Remote` 默认使用官方包源或桌面端导入包，开发者样例源只用于调试。
- 没有在线 Watcher 时，App.Center 明确显示下一步连接路径。
- 下载只进入桌面缓存，不自动安装设备。
- `Transfer / install` 只作用于当前选中的 Watcher，不广播。
- `Open on device` 只打开当前选中 Watcher 上已安装应用。
- `Uninstall from device` 只卸载当前选中 Watcher 的设备端应用。
- `Remove local` 只删除桌面端缓存，不影响任何 Watcher。
- 所有高风险动作都在 App.Center 页面内确认，不使用原生系统弹窗。
- App.Center 页面语言需要和整个项目匹配，客户可见内容必须走多语种体系。
- 状态栏、连接辅助、确认面板、按钮 tooltip、复制摘要等客户可见内容不能裸露工程英文。
- 断连重连后，Device apps 能恢复设备端已安装应用状态。
- 真机完成 ESP-NOW Remote 下载、安装、打开、卸载闭环。
- 签名成功、digest 篡改、未受信 public key、错误 issuer 都有明确验收记录。

## 当前已完成的证据

- `App.Center` 只展示可下载应用，不混入 Launcher 本地功能。
- `ESP-NOW Remote` 是当前唯一正式支持的 App.Center 可下载应用。
- 下载安装、打开设备端应用、卸载设备端应用、本地缓存删除语义已经拆分。
- 危险动作使用页面内确认面板，不使用 `window.confirm`。
- 下载确认面板显示来源标签和下载 URL，避免客户误以为已经安装到设备。
- 连接辅助使用结构化 `code`，不再依赖英文标题字符串判断状态。
- 浏览器预览入口 `?view=app-center` 已能干净打开 App.Center，不再被硬件接入审批弹窗遮挡；可通过 `npm run appcenter:preview` 复现并生成 `.tmp/ui-audit/app-center-current-preview.png`。
- 连接辅助行标签和值已接入 en / zh-CN / ja。
- App.Center 状态栏动态文案已接入 en / zh-CN / ja。
- App.Center 操作 hint 和设备端 app hint 已接入 en / zh-CN / ja。
- 复制 package summary / device app summary 的字段标签、状态值和操作提示已接入 en / zh-CN / ja。
- `docs/app-center-release-config.zh-CN.md` 明确区分 stable 官方包源和 developer sample source。
- `scripts/verify-release-config.mjs` 用于校验 App.Center 官方包源。
- 预发布可以使用开发者样例源做内测，但不得作为普通客户正式交付路径。

## 当前剩余缺口

当前不能标记为满分的原因：

- 还没有把 `VITE_WATCHER_ESPNOW_REMOTE_PACKAGE_URL` 指向真实官方包源并完成客户路径验证。
- 还缺真实 Tauri 客户端窗口的 UI 走查截图或记录；浏览器预览截图只能证明设计入口可用，不能替代桌面壳层走查。
- 还缺 Watcher 真机在线后的完整 App.Center 闭环验收记录。
- 还缺断连重连后 Device apps 状态恢复的实测记录。
- 还缺签名成功和三类失败路径的真机验收记录。
- 仍需在真实语言切换环境下逐页确认 App.Center 文案、摘要和错误提示没有残留裸英文。

## 架构原则

后续继续迭代时必须遵守：

- 不把 Launcher 本地功能混入 App.Center 可下载应用管理。
- 不把设备端卸载和桌面端缓存删除混为一谈。
- 不把开发者调试入口包装成普通客户入口。
- 不在 UI JSX 中堆复杂业务判断，能抽纯函数就抽纯函数。
- 不复制设备命令发送逻辑，高风险动作只改变确认状态，最终执行走统一入口。
- 不为了临时演示绕过真实设备在线、签名、分片传输和安装状态。
- 发布前必须按 `docs/app-center-release-config.zh-CN.md` 注入并验收官方包源。
- 稳定版发布必须通过 `scripts/verify-release-config.mjs` 校验 App.Center 官方包源。
- 预发布可以使用开发者样例源做内测，但不得作为普通客户正式交付路径。


