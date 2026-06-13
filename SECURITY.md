# Security Policy

## Supported Scope

This policy covers the WatcheRobot workspace and the linked App, Desktop, Server, ESP32, and STM32 repositories.

Security-sensitive topics include:

- API keys, tokens, signing keys, certificates, or private server credentials
- unintended collection or exposure of voice, image, video, Wi-Fi, or device data
- unsafe OTA, firmware flashing, or local network behavior
- vulnerabilities in BLE provisioning, WebSocket control, desktop packaging, or server APIs

## Reporting

TODO(owner/date): Confirm the private security contact or security advisory process before public launch.

Until that is confirmed:

- Do not post live credentials or private user data in public issues.
- Open a minimal public issue that says a private security report is needed, without disclosing exploit details.
- If you are an internal maintainer, escalate through the internal security / product channel.

## Secret Handling

- Real secrets must live in ignored local files, environment variables, OS keychains, or CI secrets.
- Checked-in `*.example.*` files must contain placeholders only.
- Android signing values, Tauri signing keys, Sparkle keys, API keys, and cloud provider tokens must not be committed.

## Verification

Before a public release, run a scan for:

```powershell
rg -n "password|token|api[_-]?key|secret|keystore|storePassword|keyPassword|BEGIN .*KEY|PRIVATE KEY" .
```

Review matches manually. Empty example fields and documentation placeholders are acceptable; real credentials are blocking.
