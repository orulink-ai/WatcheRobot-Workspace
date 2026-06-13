# Hardware and Structure Map

This document maps known hardware, structure, model, and visual resources in the current workspace. It does not grant public-release approval. Anything marked TBD must stay out of the public launch package until the hardware / legal / product owner confirms it.

## Confirmed Documentation Entry Points

| Resource | Current path | Public status | Notes |
| --- | --- | --- | --- |
| ESP32 BOM | `WatcheRobot_esp32/docs/hardware/bom.md` | Present in subrepo | Confirm license and release scope before public launch. |
| ESP32 GPIO / Pin Map | `WatcheRobot_esp32/docs/hardware/gpio-mapping.md` | Present in subrepo | Useful public hardware reference if approved. |
| ESP32 hardware directory | `WatcheRobot_esp32/hardware/` | Placeholder only | Currently contains `.gitkeep` in this checkout. |
| STM32 hardware notes | `WatcheRobot_stm32/Documents/` | Present in subrepo | Review each file for public wording and private paths. |

## Structure / Model Assets Found

| Resource | Current path | Public status | Notes |
| --- | --- | --- | --- |
| Split STL model index | `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/models/index.ts` | TBD | Used by desktop model viewer; public CAD/print permission is not confirmed. |
| Base STL | `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/models/watcherobot-base-link.stl` | TBD | Do not advertise as printable release asset until approved. |
| Link 1 STL | `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/models/watcherobot-link-1.stl` | TBD | Do not advertise as printable release asset until approved. |
| Link 2 STL | `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/models/watcherobot-link-2.stl` | TBD | Do not advertise as printable release asset until approved. |
| Preview STL | `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/models/watcherobot-preview.stl` | TBD | Do not use as public assembly source without review. |

## Expression and Demo Assets Found

| Resource | Current path | Public status | Notes |
| --- | --- | --- | --- |
| Desktop expression GIF/PNG set | `WatcheRobot_client/Watcher Desktop App/src/design-system/resources/robot/expressions/` | TBD | Good candidate for README/demo after brand/license review. |
| ESP32 GIF source assets | `WatcheRobot_esp32/firmware/s3/assets/gif/` | TBD | Pair with AnimPack docs before public use. |
| App screenshots | `WatcheRobot_app/docs/images/` | TBD | Review for outdated UI, private data, and brand approval. |

## Release Decision Checklist

- [ ] Confirm whether BOM and GPIO docs may be public.
- [ ] Confirm whether STL files are public, preview-only, or internal-only.
- [ ] Confirm whether STEP/CAD source exists and whether it may be public.
- [ ] Confirm assembly instructions owner and minimum safe-build warning.
- [ ] Confirm image/GIF/logo/demo assets for README first viewport.
- [ ] Confirm license for hardware and structure files separately from software license.

Open decision: `docs/open-questions.md` OQ-005.
