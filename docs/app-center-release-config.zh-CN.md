# App.Center 官方包源发布配置

本文档说明桌面端发布包如何接入 `ESP-NOW Remote` 的正式下载源。

## 目标

普通客户打开 App.Center 时，应看到可理解的正式下载入口，而不是开发者本地样例源。

正式路径应满足：

- 客户不需要运行 `scripts/app-center-sample-server.ps1`。
- 客户不需要理解 `127.0.0.1:8767`。
- 客户可以通过 App.Center 直接下载或导入 `ESP-NOW Remote` 应用包。
- 开发者样例源只用于本地联调、售后复现和协议验证。

## 官方包源变量

桌面端通过下面的 Vite 环境变量注入官方包源：

```text
VITE_WATCHER_ESPNOW_REMOTE_PACKAGE_URL=https://example.com/apps/espnow_remote.pkg
```

开发和售后调试时，也可以使用不带 `VITE_` 的变量：

```text
WATCHER_ESPNOW_REMOTE_PACKAGE_URL=https://example.com/apps/espnow_remote.pkg
```

`scripts/run-dev.mjs`、`scripts/build-windows-release.mjs` 和 `scripts/build-macos-release.mjs` 会把它映射为前端可见的 `VITE_WATCHER_ESPNOW_REMOTE_PACKAGE_URL`。

配置后，App.Center 的 `ESP-NOW Remote` 卡片显示：

```text
Official package source
```

未配置时，App.Center 会退回开发者样例源：

```text
http://127.0.0.1:8767/espnow_remote.pkg
Developer sample source
```

这个 fallback 只允许用于开发、测试和售后复现，不应作为客户正式交付路径。

## 发布验收

每次发布桌面客户端前，必须确认：

- `VITE_WATCHER_ESPNOW_REMOTE_PACKAGE_URL` 指向可访问的正式包源。
- 如果使用 `WATCHER_ESPNOW_REMOTE_PACKAGE_URL`，确认开发脚本已经正确映射到前端环境。
- 稳定版发布会通过 `scripts/verify-release-config.mjs` 强制检查官方包源。
- 稳定版官方包源必须使用 `https://`，不能指向 `127.0.0.1`、`localhost` 或 `::1`。
- 稳定版官方包源必须指向受支持的应用包文件：`.pkg`、`.watcherapp`、`.watcher-app` 或 `.json`。
- 正式包源返回的是可安装的 `ESP-NOW Remote` app package。
- App.Center 卡片显示 `Official package source`。
- 下载确认面板显示正式 URL。
- 下载完成后应用包进入桌面端缓存。
- 设备在线后，`Transfer / install` 能安装到当前选中的 Watcher。
- `Open on device` 能打开设备端应用。
- `Uninstall from device` 能卸载设备端应用。
- `Remove local` 只删除桌面端缓存。

## Stable 与 prerelease 策略

Stable 发布是面向普通客户的正式交付，必须配置官方包源。

```text
WATCHER_RELEASE_CHANNEL=stable
WATCHER_ESPNOW_REMOTE_PACKAGE_URL=https://example.com/apps/espnow_remote.pkg
```

Stable 发布如果缺少官方包源，或者官方包源不是 `https://`，`scripts/verify-release-config.mjs` 必须失败。

Prerelease 发布可以用于开发者、售后和内测人员验证 App.Center 流程，因此允许临时使用开发者样例源。但 prerelease 包如果显示 `Developer sample source`，只能用于调试、演示和内测，不应交付给普通客户作为正式安装路径。

## 本地调试

开发者可以继续使用本地样例源验证下载链路：

```text
http://127.0.0.1:8767/espnow_remote.pkg
```

如果 App.Center 显示 `Developer sample source`，说明当前构建没有注入官方包源。

此时普通客户不应继续操作，应使用正式发布包、官方包源或售后提供的应用包。

## 不允许的交付方式

- 不允许要求普通客户启动本地 HTTP server。
- 不允许把 `127.0.0.1` 写进客户说明作为正式下载入口。
- 不允许把开发者样例源称为官方源。
- 不允许让客户在不知道设备是否在线的情况下安装应用。
- 不允许把下载到桌面端缓存描述成已经安装到 Watcher。
