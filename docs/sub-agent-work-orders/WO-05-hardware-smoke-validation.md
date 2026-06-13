# WO-05: Hardware Smoke Validation

| Field | Instruction |
| --- | --- |
| Primary agent | Firmware / QA Agent |
| Start condition | A safe powered WatcheRobot test device, firmware version, and connection path are available. |
| Scope | Capture hardware smoke evidence for BLE ping, servo, expression, provisioning, and AI reminder paths. |
| Inputs | `docs/public-launch-validation.md`, `docs/launch-evidence/templates/hardware-smoke.md`, `docs/provisioning.md`, `docs/motion-guide.md`, and `docs/expression-guide.md`. |
| Allowed actions | Run safe smoke tests, record device and firmware versions, record commands and responses, and update `docs/launch-evidence/hardware-smoke.md` only with observed results. |
| Do not | Do not move servos beyond safe ranges, use unknown batteries, mark simulated dry-runs as hardware evidence, or claim `Status: Passed` without a real device run. |
| Required verification | `docs/launch-evidence/hardware-smoke.md`, `scripts/audit-open-source-launch-gates.ps1`, and `scripts/test-open-source-launch-gates.ps1`. |
| Stop and escalate | Stop if behavior is unsafe, firmware protocol differs from docs, battery/mechanical state is uncertain, or any command response is ambiguous. |
| Deliverable | Completed hardware evidence file, safety notes, pass/fail/unavailable summary, and TODO/TBD/PLACEHOLDER items requiring firmware owner review. |
| Self-score note | This can close hardware-dependent WatcheRobot gates only when evidence is real, complete, and current. |

## Evidence Checklist

- Device ID / hardware revision:
- Firmware versions:
- power supply and safety setup:
- BLE ping expected ACK / observed result:
- Servo action expected ACK / observed result:
- Expression switch expected ACK / observed result:
- Wi-Fi provisioning ready state expected ACK / observed result:
- AI reminder flow expected ACK / observed result:
- serial/app logs:

Dry-run example tests remain local confidence only; they do not replace hardware smoke evidence.
