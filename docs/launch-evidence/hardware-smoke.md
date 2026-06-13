# Hardware Smoke Validation Evidence

Status: Draft
Owner: Firmware / QA owner
Date: 2026-06-11
Environment: Current local Windows workspace shell in `D:\CodeProjects\WatcheRobot-Workspace`; no physical smoke-test device was connected for this evidence file.
Evidence: The launch gate audit previously reported `docs/launch-evidence/hardware-smoke.md` as missing. This draft records the blocker and the required safe hardware validation route. Device ID / hardware revision, firmware versions, power supply and safety setup, BLE ping, servo action, expression switch, Wi-Fi provisioning ready state, AI reminder flow, serial/app logs, and expected ACK / observed result evidence are not available yet.
Result: Blocked because Hardware smoke validation was not executed. No safe powered device was connected. BLE ping was not run.
Follow-up: Connect a safe powered test device, record device ID / hardware revision, firmware versions, power supply and safety setup, BLE ping, servo action, expression switch, Wi-Fi provisioning ready state, AI reminder flow, serial/app logs, and expected ACK / observed result for each step, then change Status to Passed only if all checks are complete.

## Required Checks

- Device ID / hardware revision: Not captured because no safe powered device was connected.
- Firmware versions: Not captured from hardware.
- Power supply and safety setup: Not captured because no safe powered device was connected.
- BLE ping expected ACK / observed result: BLE ping was not run against hardware.
- Servo action expected ACK / observed result: Servo action was not run against hardware.
- Expression switch expected ACK / observed result: Expression switch was not run against hardware.
- Wi-Fi provisioning ready state expected ACK / observed result: Wi-Fi provisioning was not run against hardware.
- AI reminder flow expected ACK / observed result: AI reminder flow was not run against hardware.
- Serial/app logs: serial/app logs are not available.
