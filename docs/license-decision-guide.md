# License Decision Guide

Codex must not choose a license for WatcheRobot without owner approval. This guide narrows the decision so the owner can approve the final `LICENSE` files quickly.

## Current Known State

| Area | Current evidence | Decision needed |
| --- | --- | --- |
| Root workspace | `LICENSE-TBD.md` | Choose final root license. |
| App | `WatcheRobot_app/LICENSE` exists | Confirm whether root should reference or differ from App license. |
| ESP32 firmware | `WatcheRobot_esp32/LICENSE` and hardware license references exist | Confirm software / hardware license split. |
| Desktop | No root-level license confirmed in this pass | Choose final license. |
| Server | README says license is still needed | Choose final license. |
| STM32 | No root-level license confirmed in this pass | Choose final license. |
| Hardware / structure | ESP32 README references open hardware licensing; structure STL scope is TBD | Confirm hardware and CAD/STL license. |

## Decision Options

| Option | Fit | Tradeoff |
| --- | --- | --- |
| Apache-2.0 for software | Good for permissive commercial/community adoption with patent grant | May differ from existing GPL App license. |
| MIT for software | Very simple permissive license | No explicit patent grant. |
| GPL-3.0 for software | Strong copyleft, aligns if App remains GPL-3.0 | Less permissive for commercial integrations. |
| Dual license | Allows community and commercial tracks | Requires legal/owner process. |
| Separate hardware license | Better for BOM/CAD/STL | Must be documented per asset type. |

## Required Owner Answers

1. Should all software repos use one license, or should App/Firmware/Desktop/Server differ?
2. Should hardware/CAD/STL files use a separate open hardware license?
3. Are dependencies compatible with the chosen license?
4. Should third-party assets be excluded from the license grant?
5. Who is the copyright holder line?

Until these are answered, keep `LICENSE-TBD.md` and do not create a final `LICENSE` that implies approval.
