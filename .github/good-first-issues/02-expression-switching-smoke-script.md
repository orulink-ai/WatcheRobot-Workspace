---
title: "Add an expression switching smoke script"
labels: "good first issue, examples, firmware"
---

## Background

`examples/switch-expression-minimal/README.md` documents a minimal `evt.ai.status` payload and the shared BLE sender now has an `ai-status` command. The remaining work is a hardware-verified smoke path for the current release firmware.

## Suggested Files

- `examples/switch-expression-minimal/README.md`
- `examples/ble-control-minimal/ble_control_minimal.py`
- `docs/expression-guide.md`

## Expected Result

- Document the exact firmware route that accepts `evt.ai.status`.
- Record expected ACK / status / display behavior.
- If the route differs, update the docs and example together.

## Acceptance

- The script can be syntax-checked locally.
- The README includes dependencies, command, expected result, and manual smoke-test steps.
- Any unsupported release behavior is documented as TODO/TBD rather than guessed.
