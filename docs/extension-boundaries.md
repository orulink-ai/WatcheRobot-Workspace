# Extension Boundaries

This document tells external developers what they can safely extend first.

| Area | First extension path | Status |
| --- | --- | --- |
| BLE commands | Use `00FF / FF01` JSON messages and examples | Ready for examples |
| Servo / motion | Start with `ctrl.servo.angle` and motion docs | Basic path documented |
| Expressions | Use AnimPack sources and state commands | Needs release-by-release validation |
| AI providers | Follow server provider docs | Existing server docs available |
| Desktop UI | Follow desktop app docs and design-system rules | Existing docs available |
| Mobile App | Use `useBluetooth` and BLE protocol builders | Existing module docs available |
| Hardware / structure | TBD pending public hardware scope | Needs owner confirmation |

Do not present unsupported runtime plugin isolation as complete. The creator template in this phase is a minimum example path, not a full app store or sandbox.
