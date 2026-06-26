## 0. 项目架构总览

本节用于说明 WatcheRobot 本地 App 的启动入口、固定功能、可下载扩展、App.Center 安装/卸载链路、运行时资源管理和统一控制链路。

### 0.1 总览图

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

### 0.2 App.Center 安装与卸载链路

App.Center 不只负责下载和打开应用，也负责已安装应用的卸载。开头总览图中的 `App.Center` 应按下面逻辑理解：

```text
App.Center
  -> App List
       -> Not Installed App
            -> Download
            -> Install
            -> Open
       -> Installed App
            -> Open
            -> Uninstall
                 -> Delete Local Package
                 -> Clear Install Record
                 -> Return to App List
```

对应产品交互建议：

| 应用状态 | 点击后的操作 |
|---|---|
| 未安装 | 下载 / 取消 |
| 已安装 | 打开 / 卸载 / 取消 |
| 正在运行 | 先退出应用，再回到 App.Center 卸载 |

卸载时由 App.Center 删除本地应用包，并清除安装状态。正在运行的应用不直接卸载，避免运行时资源、文件句柄或状态记录残留。

### 0.3 应用分发架构补充

如果希望把下载、导入、安装和校验逻辑单独讲清楚，可以保留下面这条独立分发链路。它强调两条下载路径最终都进入设备侧统一安装管理器。

```text
Remote App Repository
  -> App.Center
       -> Download App Package
       -> app_install_manager
       -> app_package_verifier
       -> installed_app_store
       -> Downloaded App Shell

Desktop Client
  -> Import Local App Package
       -> Transfer to Watcher
       -> app_install_manager
       -> app_package_verifier
       -> installed_app_store
       -> Downloaded App Shell
```

### 0.4 两种补充方式对比

| 方案 | 适合保留的场景 | 优点 | 代价 |
|---|---|---|---|
| 并入原架构总览 | 希望开篇一张图覆盖系统全貌，包括 App 生命周期、资源管理和应用分发 | 阅读路径集中，能看出 App.Center、桌面端、安装管理器和下载应用之间的关系 | 信息密度更高，后续维护时容易牵动整张总览 |
| 独立应用分发图 | 希望把本体下载和桌面端下载/导入作为单独设计议题讨论 | 分发链路更清晰，便于补充包格式、图标策略、签名校验、回滚等细节 | 读者需要先看总览，再看分发链路 |
| 推荐取舍 | 如果文档面向实现讨论，建议保留独立分发链路；如果文档只做高层介绍，保留总览即可 | 两种表达可以先保留，最终发布前建议只保留一种主表达 | 避免同一信息重复维护 |

## 1. 目标
