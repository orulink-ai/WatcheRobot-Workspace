# Rive Official Runtime Notes

Source pages checked on 2026-06-05:

- Complete docs index for runtime page discovery: https://rive.app/docs/llms.txt
- Getting started with Rive runtimes: https://rive.app/docs/runtimes/getting-started
- Feature support: https://rive.app/docs/feature-support
- Choose a Renderer: https://rive.app/docs/runtimes/choose-a-renderer/overview
- Runtime sizes: https://rive.app/docs/runtimes/runtime-sizes
- .riv file format: https://rive.app/docs/runtimes/advanced-topic/format
- React runtime: https://rive.app/docs/runtimes/react/react
- React parameters and return values: https://rive.app/docs/runtimes/react/parameters-and-return-values
- React state machine playback: https://rive.app/docs/runtimes/react/state-machines
- React layout: https://rive.app/docs/runtimes/react/layouts
- React artboards: https://rive.app/docs/runtimes/react/artboards
- React loading assets: https://rive.app/docs/runtimes/react/loading-assets
- Web Canvas vs WebGL2: https://rive.app/docs/runtimes/web/canvas-vs-webgl
- Web Rive parameters: https://rive.app/docs/runtimes/web/rive-parameters
- Web state machine playback: https://rive.app/docs/runtimes/web/state-machines
- Web data binding: https://rive.app/docs/runtimes/web/data-binding
- React data binding: https://rive.app/docs/runtimes/react/data-binding
- React Native runtime and subpage inventory: https://rive.app/docs/runtimes/react-native/react-native
- Flutter runtime and subpage inventory: https://rive.app/docs/runtimes/flutter/flutter
- Apple runtime and subpage inventory: https://rive.app/docs/runtimes/apple/apple
- Android runtime and subpage inventory: https://rive.app/docs/runtimes/android/android
- Unity runtime and subpage inventory: https://rive.app/docs/game-runtimes/unity/unity
- Unreal runtime and subpage inventory: https://rive.app/docs/game-runtimes/unreal/unreal
- C++ runtime and subpage inventory: https://rive.app/docs/runtimes/cpp/overview
- HTML Embed: https://rive.app/docs/integrations/html-embed
- Editor state machine overview: https://rive.app/docs/editor/state-machine/state-machine
- Exporting for runtime: https://rive.app/docs/editor/exporting/exporting-for-runtime

For the complete runtime page inventory grouped by platform, see `rive-runtime-doc-map.md`.

## Core Runtime Facts

- Rive runtimes are open-source libraries for loading and controlling `.riv` animations in apps, games, and websites.
- Rive publishes official runtimes for Web, React, React Native, Flutter, Apple, Android, Unity, Unreal, and C++.
- Rive runtime export creates a `.riv` file; runtime export is a paid-plan feature in the Rive editor.
- For Git, mark `*.riv binary` so line-ending normalization cannot corrupt the binary.

## React Runtime

- `@rive-app/react-webgl2` wraps the WebGL2 runtime and uses the Rive Renderer. It is the recommended React option when quality and performance matter.
- `@rive-app/react-canvas` wraps the Canvas 2D runtime. It is smaller and acceptable for simpler graphics that do not need renderer-only features such as vector feathering.
- `@rive-app/react-canvas-lite` is smaller but removes features including text, layout, audio, and scripting engines.
- The React runtime provides a default `<Rive />` component for simple playback and `useRive` for full control.
- `useRive` returns a `rive` instance and a `RiveComponent`; isolate it in a wrapper when conditional rendering is involved.
- The canvas must have nonzero layout dimensions. The React runtime can handle resizing and device-pixel-ratio scaling when using `RiveComponent`.

## State Machines

- State machines are controlled indirectly through inputs/transitions or data binding, not by directly mutating internal states.
- Provide `stateMachines` explicitly. Prefer a single state machine string per artboard.
- `autoplay: true` starts playback on load. The instance can also `play()`, `pause()`, `stop()`, or `reset()`.
- `useStateMachineInput(rive, machineName, inputName, initialValue)` returns a nullable input reference.
- State machine input references expose `name`, `value`, and `fire()` for trigger inputs.
- A state machine may settle when no changes are pending; updating inputs or calling play can unsettle it.
- In the Web runtime, `stateMachineInputs(machineName)` can be used to inspect instantiated legacy inputs by name/type. If it returns an empty list, first verify `artboard`, `stateMachines`, load timing, and whether the file actually exposes modern data binding properties instead of legacy inputs.
- The Web runtime also exposes path APIs such as `fireStateAtPath(name, path)` and `setNumberStateAtPath(name, value, path)`. These are useful fallbacks, but they do not replace binding the correct state machine or ViewModel instance.
- `reset({ stateMachines, autoplay, autoBind })` recreates the artboard/state machine instances from the entry state and can be used after changing playback configuration.

## Data Binding and View Models

- Newer Rive files may expose runtime controls as ViewModel properties. In that model, trigger and number names can look identical to state machine input names, but must be driven through `rive.viewModelInstance`.
- Set `autoBind: true` when the designer assigned a default ViewModel and default instance in the editor. The runtime will bind the default ViewModel instance to the artboard and state machine.
- After load, access the bound instance with `rive.viewModelInstance`. Write numbers with `rive.viewModelInstance?.number('audiolevel')?.value = 42` and fire triggers with `rive.viewModelInstance?.trigger('speaking')?.trigger()`.
- React also provides ViewModel hooks such as `useViewModelInstanceNumber` and `useViewModelInstanceTrigger`; direct `rive.viewModelInstance` access is often simpler inside a small wrapper that already owns the Rive instance lifecycle.
- If a `.riv` file contains strings like `ViewModel`, `Instance`, or the Rive editor describes the API as exposed ViewModel properties, wire data binding first. Keeping legacy `stateMachineInputs` as a fallback is safe while the exact file contract is being confirmed.

## Layout and Artboards

- If no artboard is specified, the runtime uses the default artboard from the Rive file, or the first artboard if no default is set.
- Only one artboard can be rendered at a time.
- Common fit modes: `Contain` default, `Cover`, `Fill`, `FitWidth`, `FitHeight`, `ScaleDown`, `None`, and `Layout`.
- Use `Fit.Layout` only when the artboard was designed with Rive Layouts.
- For a compact overlay icon, start with `new Layout({ fit: Fit.Contain, alignment: Alignment.Center })`.

## Assets

- Embedded assets are easiest but can enlarge `.riv` files.
- Hosted assets load from Rive CDN and require compatible Rive plans.
- Referenced assets keep `.riv` smaller but require an `assetLoader`.
- The React `assetLoader` API is available with `useRive`, not the default `<Rive />` component.

## VILab-Specific Notes

- VILab is a React/Vite/Tauri app; public assets can be addressed from `/...` paths.
- The floating overlay already computes `active`, `processing`, `failed`, `retained`, `failureRetained`, `speechLevel`, `hasSpeechInput`, and `liquidOrbMode`.
- Reuse that logic and map it into Rive inputs. Avoid moving accessibility labels and text status into Rive.
- For the voice floating orb file, the current exported interface names are `speaking`, `stop`, `loading`, optional `loading2`, `succeed`, `error`, and `audiolevel`. Use `loading2` when processing starts before speech ever happened in the current recording run; fall back to `loading` if `loading2` is not exposed. The file also contains `ViewModel1` and `Instance`, so drive both data binding (`viewModelInstance.trigger/number`) and legacy state machine inputs until the Rive contract is explicitly changed.
