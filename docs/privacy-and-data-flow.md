# Privacy and Data Flow

WatcheRobot can involve voice, images/video, device events, BLE provisioning data, local runtime config, and cloud AI provider credentials.

## Data Areas

| Area | Data | Primary location | Public guidance |
| --- | --- | --- | --- |
| BLE provisioning | SSID/password during setup | App/Desktop -> ESP32 BLE | Do not log or publish real credentials. |
| Voice | microphone audio / ASR text | ESP32 -> Server -> ASR/LLM/TTS providers | Provider behavior depends on configured runtime. |
| Camera/media | images/video frames where enabled | ESP32 -> Server/Desktop | Do not claim cloud privacy guarantees until provider flow is confirmed. |
| AI config | API keys and provider settings | Server runtime config / desktop local config | Real secrets must stay local or in CI/OS secret storage. |
| Device state | connection, servo, expression, Wi-Fi status | Desktop, server, firmware logs | Avoid exposing private network details in issue logs. |

## Required Public Disclaimer

TODO(owner/date): Confirm final public privacy wording before external launch.

Until then, public docs should say that users must review their chosen ASR, LLM, and TTS provider policies and must not commit real secrets.
