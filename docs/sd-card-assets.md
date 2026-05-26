# SD 卡动画资源同步

本文档说明 workspace 根目录的 SD 卡动画资源命令。它面向“已经生成好 AnimPack 资源，需要快速写入 SD 卡验证”的日常流程。

## 命令

检查当前源资源和目标 SD 卡，不写入文件：

```powershell
yarn sd:check
```

同步最新生成资源到唯一已挂载的可移动盘：

```powershell
yarn sd
```

显式指定 SD 卡盘符：

```powershell
yarn sd F:
```

重新运行 ESP32 动画资源生成脚本后再同步：

```powershell
yarn sd:generate F:
```

## 行为

- 默认源目录来自 `WatcheRobot_esp32/firmware/s3/release/*/sdcard/anim` 中最近修改的 `anim` 目录。
- 默认目标目录是 SD 卡根目录下的 `anim`，例如 `F:\anim`。
- 同步时会清理目标 `anim` 目录，再完整复制源资源，保证 SD 卡内容与当前生成物一致。
- 底层同步脚本会对源目录和目标目录做文件列表与 SHA-256 哈希校验，校验失败会返回非零退出码。
- 如果只检测到一个已挂载且带文件系统的可移动盘，`yarn sd` 会自动使用它。
- 如果检测到多个可移动盘，脚本会停止并要求显式传入目标盘符，避免误写。
- 脚本默认拒绝写入非可移动盘；只有确认需要写入固定盘目录时才使用 `-Force`。

## 资源布局

同步完成后，SD 卡应该包含：

```text
<sd-root>/
  anim/
    anim_manifest.bin
    boot.animpack
    happy.animpack
    ...
```

固件运行时会从 `/sdcard/anim/anim_manifest.bin` 读取 manifest，并按 manifest 引用同目录下的 `.animpack` 文件。

## 常见问题

### 没有检测到 SD 卡

确认 SD 卡已经挂载为 Windows 盘符，并且 `yarn sd:check F:` 可以访问目标盘。

### 电脑上插了多个可移动盘

使用显式盘符：

```powershell
yarn sd F:
```

### 想同步指定源目录

可以直接调用包装脚本并传入 `-SourceDir`：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/sync-sd-assets.ps1 -SourceDir WatcheRobot_esp32\firmware\s3\release\V2.3.0\sdcard\anim F:
```

### 设备提示找不到动画 manifest

检查 SD 卡是否是如下路径，而不是多套了一层目录：

```text
F:\anim\anim_manifest.bin
```
