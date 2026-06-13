# AI Integration

WatcheRobot AI integration currently lives primarily in `WatcheRobot_server` and the desktop client.

## Sources

- Server README: `WatcheRobot_server/README.md`
- Server docs: `WatcheRobot_server/docs/README.md`
- Desktop OpenClaw notes: `WatcheRobot_client/Watcher Desktop App/src/modules/openclaw/README.md`

## Runtime Areas

| Area | Current role |
| --- | --- |
| ASR | Speech recognition provider runtime |
| LLM | Communication brain / language model provider |
| TTS | Speech synthesis provider runtime |
| OpenClaw | Execution brain / task execution backend |
| Scheduler | Local reminders and delayed actions |

## Configuration Rules

- Real provider secrets must not be committed.
- Public docs may show placeholder values only.
- Runtime config should use the server's documented config/runtime and local override model.

TODO(owner/date): Confirm the public default provider recommendation for overseas users before README launch.
