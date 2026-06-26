### 0.1 图片补充说明：App.Center 卸载链路

开头总览图中的 `App.Center` 除了“应用列表、下载、安装、打开”之外，还需要明确包含“卸载已安装应用”的路径。建议阅读图时按下面逻辑理解：

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

对应产品交互建议：未安装应用点击后显示 `下载 / 取消`；已安装应用点击后显示 `打开 / 卸载 / 取消`。卸载时由 App.Center 删除本地应用包，并清除安装状态。正在运行的应用不直接卸载，需要先退出回到 App.Center 后再执行卸载。
