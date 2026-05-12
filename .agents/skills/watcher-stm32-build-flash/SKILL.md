---
name: watcher-stm32-build-flash
description: 构建、定位并烧录 WatcheRobot STM32F103 固件。用于识别 `WatcheRobot_stm32` 工程根目录、编译固件、生成 `watcheRobot_STM32.bin/.hex`、通过 ST-LINK + OpenOCD 烧录、验证烧录成功，或排查本项目的 CMake/Ninja/ARM GCC/OpenOCD/ST-LINK 环境问题。
---

# STM32 构建与烧录

## 项目根目录

当当前目录同时包含以下文件和目录时，把它作为 `<project-root>`：

```text
CMakeLists.txt
CMakePresets.json
watcheRobot_STM32.ioc
Core\
Drivers\
User\
```

如果当前目录不匹配，就查找包含这些文件和目录的路径；找不到再询问用户本机 `WatcheRobot_stm32` checkout 路径。

所有构建和烧录命令都从 `<project-root>` 运行。不要假设固定盘符或用户名。

固件目标名是 `watcheRobot_STM32`。Debug 二进制默认在：

```text
<project-root>\build\Debug\watcheRobot_STM32.bin
```

## 工具检查

构建或烧录前，检查本地工具：

```powershell
cmake --version
ninja --version
arm-none-eabi-gcc --version
arm-none-eabi-objcopy --version
arm-none-eabi-size --version
openocd --version
```

需要确认 ST-LINK 时，检查设备管理器。健康状态通常表现为 USB 设备下有 `STM32 STLink`，且没有黄色警告图标。

## 构建固件

在 `<project-root>` 下配置并构建 Debug 固件：

```powershell
cmake --preset Debug
cmake --build --preset Debug
```

预期产物：

```text
build\Debug\watcheRobot_STM32
build\Debug\watcheRobot_STM32.bin
build\Debug\watcheRobot_STM32.hex
build\Debug\watcheRobot_STM32.map
```

裸 Flash 烧录使用 `build\Debug\watcheRobot_STM32.bin`，地址 `0x08000000`。

## 使用 OpenOCD 烧录

在 `<project-root>` 下通过 ST-LINK 烧录 Debug 二进制：

```powershell
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program build/Debug/watcheRobot_STM32.bin verify reset exit 0x08000000"
```

如果 SWD 连接不稳定，降低 adapter speed：

```powershell
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "adapter speed 1000" -c "program build/Debug/watcheRobot_STM32.bin verify reset exit 0x08000000"
```

## 成功判据

OpenOCD 输出同时包含以下内容时，视为烧录成功：

```text
Programming Finished
Verified OK
Resetting Target
```

有用的连接信号包括：

```text
STLINK ...
Target voltage: ...
Cortex-M3 processor detected
```

`Adding extra erase range` 警告通常可以接受，只要后面跟着 `Verified OK`；它表示 OpenOCD 按 Flash 页边界扩展了擦除范围。

## 常见修复

如果 CMake 一直使用旧的绝对 Ninja 路径，删除 stale cache 后重新配置：

```powershell
Remove-Item -Recurse -Force build\Debug
cmake --preset Debug
```

如果 `cmake --preset Debug` 找不到 Ninja：

```powershell
where.exe ninja
```

然后确认 Ninja 已安装，并在新 PowerShell 会话中可用。

如果 OpenOCD 找不到 `interface/stlink.cfg` 或 `target/stm32f1x.cfg`，定位 OpenOCD `scripts` 目录，或重新安装 xPack OpenOCD：

```powershell
winget install --id xpack-dev-tools.openocd-xpack -e
```

如果 OpenOCD 连接不上芯片，检查：

- ST-LINK USB 驱动已安装，设备管理器无警告。
- SWDIO、SWCLK、GND、目标板供电连接正确。
- OpenOCD 能检测到 target voltage。
- 尝试 `adapter speed 1000` 降速。

## 路径说明

路径有空格时，先用引号进入 `<project-root>`，再执行相对命令：

```powershell
cd "D:\My Projects\WatcheRobot_stm32"
cmake --preset Debug
cmake --build --preset Debug
openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program build/Debug/watcheRobot_STM32.bin verify reset exit 0x08000000"
```
