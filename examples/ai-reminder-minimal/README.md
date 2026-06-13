# AI Reminder Minimal

This example exercises the local WatcheRobot Server HTTP management API without requiring a BLE device. It is not a full free-form AI chat example; it is a minimal server-side AI / scheduling path that can be run before hardware is connected.

Protocol evidence:

- `WatcheRobot_server/docs/en/reference/http-management-api.md`
- Default HTTP management endpoint: `http://127.0.0.1:8766`
- Endpoint used by this example: `POST /api/admin/scheduled-intents`

## Start the Server

```powershell
yarn server:start:checked
```

Or follow `WatcheRobot_server/README.md`.

## Run

```powershell
python ai_reminder_minimal.py --text "Remind me to drink water in one minute"
```

Dry run without a server:

```powershell
python ai_reminder_minimal.py --dry-run
```

## Expected Result

- If the server is running, the script prints the JSON response from `/api/admin/scheduled-intents`.
- A successful response should include a scheduling status such as `created`, or a clear `clarify`, `rejected`, or `not_scheduled` result.
- If the server is not running, the script exits with an HTTP connection error.
- In `--dry-run` mode, the script prints the URL and request payload without making a network request.

Manual validation with an online hardware client is still required before marking reminder playback public-ready.
