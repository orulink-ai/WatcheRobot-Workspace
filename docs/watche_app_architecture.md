# WatcheRobot 嵌入式本地 App 架构整理文档

## 1. 目标

WatcheRobot 启动后进入统一的本地主界面 `Launcher`。

`Launcher` 只负责展示本地固定功能入口。用户点击某个功能后，系统进入对应 APP。每个 APP 只启动自己需要的资源，退出时释放资源并返回 `Launcher`。

`Remote App` 不作为 Launcher 固定入口出现，而是 `App.Center` 中的可下载应用。用户需要先进入 `App.Center`，下载并安装后再打开遥控功能。

最终目标：

| 原则 | 说明 |
|---|---|
| 本地功能独立 | BLE、配网、客户端、语音、App.Center 分别是独立本地 APP |
| 可下载功能走 App.Center | 遥控等扩展功能通过 App.Center 下载、安装、打开 |
| 按需启动资源 | APP 进入时才启动 BLE、Wi-Fi、语音或 ESP-NOW |
| 退出释放资源 | APP 退出后回到 Launcher 并释放资源 |
| 输入职责清晰 | 触摸负责主界面选择，滚轮不参与 APP 选择 |
| 不保留混合主入口 | 原来混在一起的能力拆到对应 APP |

## 2. 最终产品结构

```text
Boot
  -> Launcher
       -> BLE App
          蓝牙连接、手机 App 蓝牙控制
       -> Provision App
          BLE 配网、保存 Wi-Fi 凭据
       -> Client App
          Wi-Fi 客户端连接、WebSocket 指令通道
       -> Voice App
          语音录音、语音聊天、云语音链路
       -> App.Center
          应用列表、下载、安装、卸载、打开应用
             -> Downloaded Apps
                  -> Remote App
                     ESP-NOW 遥控接收、动作下发
```

## 3. 旧主功能如何拆分

原先混合主流程中包含多种能力，这些能力需要全部迁移到明确场景中。

| 原能力 | 新归属 |
|---|---|
| 蓝牙等待连接 | BLE App |
| 蓝牙连接成功反馈 | BLE App |
| 手机 App 蓝牙控制 | BLE App |
| BLE 写入 Wi-Fi 凭据 | Provision App |
| Wi-Fi 凭据保存 | Provision App |
| Wi-Fi 客户端连接 | Client App |
| 服务发现 / WebSocket | Client App |
| 语音录音 | Voice App |
| 语音聊天 | Voice App |
| 云语音链路 | Voice App |
| 应用下载 / 安装 / 卸载 | App.Center |
| 遥控功能 | App.Center 下载后的 Remote App |
| 表情显示 | 各 APP 按场景调用 |
| 舵机 / 动作控制 | 统一走 `control_ingress` |
| 默认启动界面 | Launcher |

处理原则：

| 原则 | 说明 |
|---|---|
| 不再保留混合主入口 | 任何功能都必须归属到具体 APP |
| 不隐式启动重资源 | BLE、Wi-Fi、语音、ESP-NOW 都由 APP 生命周期管理 |
| 不跨场景复用状态 | 每个 APP 进入时建立状态，退出时清理状态 |

## 4. APP 边界

### Launcher

Launcher 是系统默认入口。

| 职责 | 说明 |
|---|---|
| 展示本地固定 APP | BLE、Provision、Client、Voice、App.Center |
| 进入 APP | 用户点击后进入对应场景 |
| 接收返回 | 本地 APP 退出后回到 Launcher |
| 保持轻量状态 | 常态下不启动 BLE、Wi-Fi、语音、云连接 |

Launcher 不负责 BLE 广播、Wi-Fi 自动连接、语音录音、WebSocket 连接、配网逻辑、ESP-NOW 遥控和应用下载。

### BLE App

BLE App 负责手机 App 通过蓝牙连接设备后的控制能力。

进入 BLE App 后：

| 行为 | 说明 |
|---|---|
| 开启 BLE 广播 | 等待手机连接 |
| 显示等待连接界面 | 每次进入都显示等待 BLE |
| 连接成功反馈 | 手机连接成功后播放表情 / 动作反馈 |
| 接收蓝牙控制指令 | 处理动作、表情、状态类命令 |
| 下发运动控制 | 通过 `control_ingress` 进入运动控制层 |

退出 BLE App 后：

| 行为 | 说明 |
|---|---|
| 停止 BLE 广播 | 不继续等待连接 |
| 断开 BLE 连接 | 手机端不应显示仍保持连接 |
| 清理连接状态 | 下次进入重新等待连接 |
| 清理反馈状态 | 不重复播放连接成功反馈 |

BLE App 不处理 Wi-Fi 配网，配网属于 Provision App。

### Provision App

Provision App 负责第一次配网或重新配网。

进入 Provision App 后：

| 行为 | 说明 |
|---|---|
| 开启 BLE 配网能力 | 手机通过 BLE 写入 Wi-Fi 信息 |
| 接收 SSID / password | 保存到本地 |
| 写入 NVS | Wi-Fi 凭据持久化 |
| 短暂连接验证 | 验证 Wi-Fi 是否可用 |
| 显示配网状态 | 等待、连接中、成功、失败 |

退出 Provision App 后：

| 行为 | 说明 |
|---|---|
| 关闭 BLE | 不继续广播配网服务 |
| 断开 Wi-Fi | 不因为配网成功就常驻联网 |
| 保留凭据 | 下次 Wi-Fi 类 APP 可直接连接 |
| 返回 Launcher | 回到主界面 |

Provision App 不处理蓝牙遥控指令，也不负责客户端或语音链路。

### Client App

Client App 负责通过 Wi-Fi 连接客户端或服务端。

进入 Client App 后：

| 行为 | 说明 |
|---|---|
| 启动 Wi-Fi | 使用已保存凭据联网 |
| 服务发现 | 查找客户端或服务端 |
| 建立 WebSocket | 形成指令通道 |
| 接收远端控制指令 | 处理状态、表情、动作等命令 |
| 下发运动控制 | 统一走 `control_ingress` |

退出 Client App 后：

| 行为 | 说明 |
|---|---|
| 关闭 WebSocket | 停止远端连接 |
| 停止 discovery | 不再扫描服务 |
| 断开 Wi-Fi | 回到轻量状态 |
| 清理 transport 状态 | 下次进入重新连接 |

Client App 不负责语音聊天，语音能力属于 Voice App。

### Voice App

Voice App 负责语音聊天。

进入 Voice App 后：

| 行为 | 说明 |
|---|---|
| 启动 Wi-Fi | 使用已保存凭据联网 |
| 启动录音 | 初始化并启动语音 recorder |
| 建立语音云链路 | 支持语音聊天 |
| 处理语音按钮 | 触发语音输入 / 停止 / 状态切换 |
| 播放语音反馈 | TTS 或语音状态反馈 |

退出 Voice App 后：

| 行为 | 说明 |
|---|---|
| 停止录音 | 释放音频资源 |
| 挂起云音频 | 停止语音链路 |
| 断开 Wi-Fi | 不保持网络常驻 |
| 清理语音 UI | 回到 Launcher |

Voice App 不负责客户端遥控、BLE 配网、BLE 控制或应用下载。

### App.Center

App.Center 是应用商店，也是扩展功能入口。

进入 App.Center 后：

| 行为 | 说明 |
|---|---|
| 启动 Wi-Fi | 拉取应用列表需要联网 |
| 获取应用列表 | 从远端读取 apps.json |
| 展示应用 | 显示可下载和已安装应用 |
| 下载应用包 | 保存到本地存储 |
| 安装 / 卸载 | 管理本地应用状态 |
| 打开已安装应用 | 进入对应下载应用 |
| 管理 Remote App | Remote App 通过这里下载、安装、打开 |

退出 App.Center 后：

| 行为 | 说明 |
|---|---|
| 下载中禁止退出 | 避免破坏下载流程 |
| 断开 Wi-Fi | 不保持网络常驻 |
| 保留安装状态 | 已安装应用继续存在 |
| 返回 Launcher | 回到主界面 |

App.Center 不负责配网、蓝牙控制、语音聊天或客户端连接。

### Remote App

Remote App 是 App.Center 中的可下载应用，不是 Launcher 固定入口。

用户路径：

```text
Launcher
  -> App.Center
       -> 下载 / 安装 Remote App
            -> 打开 Remote App
```

Remote App 负责 ESP-NOW 遥控。

进入 Remote App 后：

| 行为 | 说明 |
|---|---|
| 启动 ESP-NOW RX | 接收遥控端数据 |
| 解析遥控数据 | 例如电位器角度 |
| 转换运动指令 | 生成舵机控制请求 |
| 下发动作 | 通过 MCU / 控制层执行 |
| 显示遥控状态 | 明确当前处于遥控模式 |

退出 Remote App 后：

| 行为 | 说明 |
|---|---|
| 停止 ESP-NOW RX | 挂起接收任务 |
| 清理遥控状态 | 避免残留数据影响下次进入 |
| 返回 App.Center 或 Launcher | 按产品流程决定 |

Remote App 不负责 BLE 控制、BLE 配网、语音聊天、客户端连接，也不负责自己的下载管理。

### Downloaded App Shell

Downloaded App Shell 是已下载轻量应用的运行壳。

| 职责 | 说明 |
|---|---|
| 读取 manifest | 获取应用名称、描述、动画、状态 |
| 展示应用界面 | 根据 manifest 显示内容 |
| 提供打开入口 | 作为 App.Center 下载应用的本地入口 |

限制：

| 限制 | 说明 |
|---|---|
| 不支持任意 C 代码动态加载 | 当前不是完整插件系统 |
| 不适合复杂游戏逻辑 | 需要更强运行时 |
| 不负责下载管理 | 下载、安装、卸载属于 App.Center |
| 不负责系统资源管理 | 资源由 runtime 和 APP 声明控制 |

## 5. 资源管理规则

每个 APP 进入时申请资源，退出时释放资源。

| APP | 进入时资源 | 退出时动作 |
|---|---|---|
| Launcher | 无重资源 | 保持空闲 |
| BLE App | BLE | 关闭 BLE |
| Provision App | BLE + 短暂 Wi-Fi 验证 | 关闭 BLE / Wi-Fi |
| Client App | Wi-Fi + WebSocket | 关闭 WebSocket / Wi-Fi |
| Voice App | Wi-Fi + 语音 + 云链路 | 停止语音 / 断开 Wi-Fi |
| App.Center | Wi-Fi | 断开 Wi-Fi |
| Remote App | ESP-NOW | 停止 ESP-NOW |
| Downloaded App Shell | 按 manifest / runtime 声明 | 按资源声明释放 |

统一规则：

| 规则 | 说明 |
|---|---|
| APP 不能私自长期占用资源 | BLE/Wi-Fi/语音/ESP-NOW 必须纳入生命周期 |
| 退出必须清理 | 防止再次进入时状态错乱 |
| Launcher 保持轻量 | 回到 Launcher 后尽量关闭重资源 |
| App.Center 下载中锁定退出 | 避免下载包损坏 |

## 6. 输入规则

新的输入规则要避免滚轮和触摸互相污染。

| 输入 | 职责 |
|---|---|
| 触摸点击 | 选择并进入 APP |
| 触摸滑动 | 滚动 Launcher 列表 |
| 滚轮旋转 | 不参与 Launcher 选择 |
| 滚轮按下 | 不作为 APP 进入确认 |
| 电源长按 | 系统级关机 |
| APP 内退出 | 通过统一 Exit overlay 返回 |

要求：

| 要求 | 说明 |
|---|---|
| 触摸和滚轮状态分离 | 两者不共享选择状态 |
| Launcher 不依赖滚轮高亮 | 避免选择错乱 |
| 滚轮不触发 APP 进入 | 避免误进入 |
| Exit overlay 统一 | 避免每个 APP 自己写一套退出逻辑 |

## 7. 代码拆分方向

当前 `app_main.c` 承担过多职责，建议拆成三层。

```text
main/
  app_main.c
    系统启动、硬件初始化、APP 注册、主循环

  apps/
    launcher_app.c
    ble_app.c
    provision_app.c
    client_app.c
    voice_app.c
    app_center_app.c
    downloaded_app.c

  runtime/
    watcher_app_runtime.c
    app_resource_manager.c
    app_input_router.c
    local_exit_overlay.c
```

App.Center 下载应用相关：

```text
main/apps/downloaded/
  remote_app.c
    App.Center 下载后的 ESP-NOW 遥控应用

  downloaded_app_shell.c
    通用轻量应用壳
```

服务层建议：

| 服务 | 职责 |
|---|---|
| `ble_control_service` | BLE 连接与蓝牙控制命令 |
| `ble_provision_service` | BLE 配网 |
| `client_transport_service` | discovery / WebSocket / reconnect |
| `voice_session_service` | 录音、语音状态、云语音 |
| `remote_runtime_service` | ESP-NOW 遥控运行 |
| `control_ingress` | 所有动作控制统一入口 |

## 8. 落地顺序

### 第一步：清理 Launcher

| 事项 | 目标 |
|---|---|
| 开机进入 Launcher | 默认不启动重资源 |
| Launcher 只展示本地固定 APP | BLE、Provision、Client、Voice、App.Center |
| Remote 不出现在 Launcher | Remote 只从 App.Center 进入 |
| 移除混合主入口 | 所有能力分散到对应 APP |

### 第二步：拆蓝牙和配网

| 事项 | 目标 |
|---|---|
| BLE App 只做蓝牙控制 | 不处理配网 |
| Provision App 只做配网 | 不处理遥控指令 |
| BLE 状态可重置 | 退出后再次进入行为一致 |

### 第三步：拆 Wi-Fi 客户端和语音

| 事项 | 目标 |
|---|---|
| Client App 管理客户端连接 | discovery / WebSocket 独立 |
| Voice App 管理语音链路 | recorder / cloud voice 独立 |
| 退出时网络释放 | Wi-Fi 不常驻 |

### 第四步：整理 App.Center 和下载应用

| 事项 | 目标 |
|---|---|
| App.Center 只做应用商店 | 下载、安装、卸载、打开 |
| Remote 作为下载应用 | 不作为 Launcher 固定入口 |
| Downloaded Shell 管理轻量应用 | 读取 manifest 并展示 |
| 下载中禁止退出 | 保证应用包完整性 |

### 第五步：整理输入系统

| 事项 | 目标 |
|---|---|
| 触摸负责 Launcher 选择 | 点击进入 APP |
| 滚轮不参与选择 | 不影响高亮和跳转 |
| Exit overlay 统一 | 本地 APP 都能干净退出 |

## 9. 验收标准

| 场景 | 通过标准 |
|---|---|
| 开机 | 进入 Launcher，不自动开启 BLE/Wi-Fi |
| Launcher | 只显示 BLE、Provision、Client、Voice、App.Center |
| Remote 入口 | 只在 App.Center 中出现 |
| BLE App | 每次进入都等待手机连接，退出后断开 |
| Provision App | 可完成配网，退出后 Wi-Fi 不常驻 |
| Client App | 进入后才连接 Wi-Fi 和 WebSocket，退出后释放 |
| Voice App | 进入后才启动语音，退出后停止录音和网络 |
| App.Center | 可下载、安装、卸载、打开应用 |
| Remote App | 通过 App.Center 安装后打开，ESP-NOW 遥控独立运行 |
| 输入系统 | 触摸负责选择，滚轮不影响 Launcher |
| 资源状态 | 多次切换 APP 后无明显残留状态 |

## 10. 最终结果

重构完成后，系统形态是：

```text
Launcher 是本地固定功能入口。
BLE、Provision、Client、Voice、App.Center 是本地固定 APP。
Remote 等扩展能力从 App.Center 下载、安装、打开。
每个 APP 只管理自己的资源。
退出 APP 后资源释放并返回上一级。
触摸负责主界面选择。
滚轮不再参与 Launcher 选择。
```

后续新增功能时，只需要判断：

| 问题 | 结果 |
|---|---|
| 是本地固定功能，还是可下载扩展功能？ | 决定放 Launcher 还是 App.Center |
| 需要哪些资源？ | 决定 BLE / Wi-Fi / 语音 / ESP-NOW 生命周期 |
| 如何退出和清理？ | 防止状态污染 |
| 是否需要下载、安装、卸载？ | 决定是否走 App.Center |

这样可以避免新的功能继续堆回混合主流程里。
