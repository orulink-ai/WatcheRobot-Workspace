# Resource Pack Spec

Draft status: first public documentation pass.

## Expression Resources

Source GIFs should follow the canonical names documented by the ESP32 AnimPack toolchain.

Expected flow:

1. Place source GIF files under the firmware GIF asset folder.
2. Generate AnimPack files using the ESP32 toolchain.
3. Copy the generated `anim/` folder to the SD card root.
4. Verify boot, standby, and switching behavior on hardware.

## Motion Resources

TODO(owner/date): Confirm the public action-file format, naming rules, and storage path before publishing creator motion packs.

## Audio Resources

TODO(owner/date): Confirm whether SFX/audio packs are public, and what license applies.

## Package Metadata

Recommended metadata for future resource packs:

```json
{
  "name": "example-pack",
  "version": "0.1.0",
  "author": "TBD",
  "license": "TBD",
  "target": "WatcheRobot",
  "contents": ["expressions"]
}
```
