# Rive Runtime Documentation Map

Checked against the official Rive docs index on 2026-06-05:

- Documentation index: https://rive.app/docs/llms.txt
- Runtime entry point: https://rive.app/docs/runtimes/getting-started

Use this file as the first routing layer when a task mentions a runtime, package, platform, or integration format. Prefer the exact platform section below, then the shared runtime concepts.

## Shared Runtime Pages

- Getting started: https://rive.app/docs/runtimes/getting-started
- Demos and starters: https://rive.app/docs/runtimes/demos
- Feature support: https://rive.app/docs/feature-support
- Runtime sizes: https://rive.app/docs/runtimes/runtime-sizes
- Choose a renderer overview: https://rive.app/docs/runtimes/choose-a-renderer/overview
- Choose a renderer FAQ: https://rive.app/docs/runtimes/choose-a-renderer/faq
- `.riv` file format: https://rive.app/docs/runtimes/advanced-topic/format

Shared rules:

- `.riv` is the binary runtime export format consumed by all Rive runtimes. Store it as a binary file in Git.
- Check Feature Support before relying on a newer editor feature in a runtime.
- Check renderer requirements when the file uses renderer-only features such as vector feathering.
- Prefer Rive Renderer-backed packages for quality, performance, vector feathering, and advanced graphics unless the target runtime or package constraints require otherwise.
- State machines are controlled indirectly through data binding properties or state machine inputs/transitions. Do not mutate internal state machine states directly.
- New code should prefer Data Binding / ViewModel properties when available. Legacy state machine inputs are still useful for older files and as a debugging fallback.
- If a state machine settles, updating a bound property/input or calling play can unsettle it.
- For hosted assets or out-of-band images/fonts/audio, check the runtime's Loading Assets and Fonts/Audio pages before coding.

## Web JS Runtime

Root:

- Getting started: https://rive.app/docs/runtimes/web/web-js

Subpages:

- Canvas vs WebGL2: https://rive.app/docs/runtimes/web/canvas-vs-webgl
- Rive parameters: https://rive.app/docs/runtimes/web/rive-parameters
- Artboards: https://rive.app/docs/runtimes/web/artboards
- Layout: https://rive.app/docs/runtimes/web/layouts
- State Machine Playback: https://rive.app/docs/runtimes/web/state-machines
- Data Binding: https://rive.app/docs/runtimes/web/data-binding
- Loading Assets: https://rive.app/docs/runtimes/web/loading-assets
- Fonts: https://rive.app/docs/runtimes/web/fonts
- Preloading WASM: https://rive.app/docs/runtimes/web/preloading-wasm
- Caching a Rive File: https://rive.app/docs/runtimes/web/caching-a-rive-file
- Playing Audio: https://rive.app/docs/runtimes/web/playing-audio
- Low-level API Usage: https://rive.app/docs/runtimes/web/low-level-api-usage
- Migration Guides: https://rive.app/docs/runtimes/web/migration-guides
- FAQ: https://rive.app/docs/runtimes/web/faq

Implementation notes:

- Packages: `@rive-app/webgl2`, `@rive-app/canvas`, `@rive-app/canvas-lite`, and canvas single variants.
- `@rive-app/webgl2` uses the Rive Renderer and is the default recommendation for advanced or high-fidelity rendering.
- `@rive-app/canvas` is smaller and suitable for simpler graphics.
- `@rive-app/canvas-lite` removes features including text, layout, audio, and scripting.
- Rive can load files with `src`, `buffer`, or a reusable parsed `riveFile`.
- Call `resizeDrawingSurfaceToCanvas()` after load or on resize when managing a canvas directly.
- Clean up explicit web runtime instances with `riveInstance.cleanup()` when they are no longer needed.
- For many WebGL2 instances, use an offscreen/shared renderer option where available to reduce browser WebGL context pressure.

## React Runtime

Root:

- React: https://rive.app/docs/runtimes/react/react

Subpages:

- Parameters and Return Values: https://rive.app/docs/runtimes/react/parameters-and-return-values
- Artboards: https://rive.app/docs/runtimes/react/artboards
- Layout: https://rive.app/docs/runtimes/react/layouts
- State Machine Playback: https://rive.app/docs/runtimes/react/state-machines
- Data Binding: https://rive.app/docs/runtimes/react/data-binding
- Loading Assets: https://rive.app/docs/runtimes/react/loading-assets
- Fonts: https://rive.app/docs/runtimes/react/fonts
- Preloading WASM: https://rive.app/docs/runtimes/react/preloading-wasm
- Caching a Rive File: https://rive.app/docs/runtimes/react/caching-a-rive-file
- Playing Audio: https://rive.app/docs/runtimes/react/playing-audio
- Rendering to a Bitmap: https://rive.app/docs/runtimes/react/rendering-to-a-bitmap
- Migration Guides: https://rive.app/docs/runtimes/react/migration-guides

Implementation notes:

- Packages: `@rive-app/react-webgl2`, `@rive-app/react-canvas`, `@rive-app/react-canvas-lite`.
- Prefer `@rive-app/react-webgl2` for Rive Renderer support. Use canvas packages only when size or feature constraints justify it.
- Use `<Rive />` for simple render-only playback.
- Use `useRive` when code needs the `rive` instance, state machine control, Data Binding, asset loading, events, pause/play, or custom runtime behavior.
- Isolate `useRive` inside a wrapper component when the Rive component is conditionally mounted.
- The `RiveComponent` canvas needs a nonzero container size.
- Do not rely on the `rive` instance inside `onLoad`; React docs recommend using a `useEffect` watching `rive` instead.
- `useStateMachineInput` is deprecated for new work; prefer Data Binding where the file exposes ViewModels.
- With `autoBind: true`, the bound default ViewModel instance is available as `rive.viewModelInstance` after load.
- ViewModel property hooks include boolean, string, number, enum, color, and trigger hooks. Direct `rive.viewModelInstance` access is acceptable inside a small wrapper that owns the Rive lifecycle.

## React Native Runtime

Root:

- React Native: https://rive.app/docs/runtimes/react-native/react-native

Subpages:

- Loading Rive Files: https://rive.app/docs/runtimes/react-native/loading-rive-files
- Props: https://rive.app/docs/runtimes/react-native/props
- Rive Ref Methods: https://rive.app/docs/runtimes/react-native/rive-ref-methods
- Error Handling: https://rive.app/docs/runtimes/react-native/error-handling
- Adding Rive to Expo: https://rive.app/docs/runtimes/react-native/adding-rive-to-expo
- Native SDK Version Customization: https://rive.app/docs/runtimes/react-native/native-version-customization
- Artboards: https://rive.app/docs/runtimes/react-native/artboards
- Layout: https://rive.app/docs/runtimes/react-native/layouts
- State Machine Playback: https://rive.app/docs/runtimes/react-native/state-machines
- Data Binding: https://rive.app/docs/runtimes/react-native/data-binding
- Loading Assets: https://rive.app/docs/runtimes/react-native/loading-assets
- Fonts: https://rive.app/docs/runtimes/react-native/fonts
- Caching a Rive File: https://rive.app/docs/runtimes/react-native/caching-a-rive-file
- Playing Audio: https://rive.app/docs/runtimes/react-native/playing-audio
- Migration Guide: https://rive.app/docs/runtimes/react-native/migration-guide

Implementation notes:

- Prefer the new Nitro-based runtime for new projects.
- Observe platform requirements before implementation: React Native, Expo SDK, iOS, Android SDK, Xcode, JDK, and Nitro Modules versions.
- For renderer defaults, configure iOS and Android renderer choices where needed.
- Use refs and documented ref methods for imperative control; keep error handling explicit.

## Flutter Runtime

Root:

- Flutter: https://rive.app/docs/runtimes/flutter/flutter

Subpages:

- Rive Native for Flutter: https://rive.app/docs/runtimes/flutter/rive-native
- Artboards: https://rive.app/docs/runtimes/flutter/artboards
- Layout: https://rive.app/docs/runtimes/flutter/layouts
- State Machine Playback: https://rive.app/docs/runtimes/flutter/state-machines
- Data Binding: https://rive.app/docs/runtimes/flutter/data-binding
- Loading Assets: https://rive.app/docs/runtimes/flutter/loading-assets
- Fonts: https://rive.app/docs/runtimes/flutter/fonts
- Caching a Rive File: https://rive.app/docs/runtimes/flutter/caching-a-rive-file
- Playing Audio: https://rive.app/docs/runtimes/flutter/playing-audio
- Migration Guide: https://rive.app/docs/runtimes/flutter/migration-guide
- FAQ: https://rive.app/docs/runtimes/flutter/faq
- API Reference: https://rive.app/docs/runtimes/flutter/api-reference

Implementation notes:

- Import from `package:rive/rive.dart`.
- Initialize Rive early with `RiveNative.init()` when possible.
- Use `RiveWidget`, `RiveWidgetBuilder`, `RivePanel`, shared render textures/surfaces, and controllers based on resource-management needs.
- Choose `Factory.rive` for Rive Renderer or `Factory.flutter` for Flutter rendering.
- If Flutter/Impeller rendering differs from the editor, test with `flutter run --no-enable-impeller` before filing renderer bugs.

## Apple Runtime

Root:

- Apple: https://rive.app/docs/runtimes/apple/apple

Subpages:

- FAQ: https://rive.app/docs/runtimes/apple/faq
- Resource Usage: https://rive.app/docs/runtimes/apple/resource-usage
- Artboards: https://rive.app/docs/runtimes/apple/artboards
- Layout: https://rive.app/docs/runtimes/apple/layouts
- State Machine Playback: https://rive.app/docs/runtimes/apple/state-machines
- Data Binding: https://rive.app/docs/runtimes/apple/data-binding
- Loading Assets: https://rive.app/docs/runtimes/apple/loading-assets
- Fonts: https://rive.app/docs/runtimes/apple/fonts
- Caching a Rive File: https://rive.app/docs/runtimes/apple/caching-a-rive-file
- Playing Audio: https://rive.app/docs/runtimes/apple/playing-audio
- Logging: https://rive.app/docs/runtimes/apple/logging
- Migration Guides: https://rive.app/docs/runtimes/apple/migration-guides
- Migrating from Legacy: https://rive.app/docs/runtimes/apple/migrating-from-legacy

Implementation notes:

- Supports UIKit/AppKit and SwiftUI through `RiveUIView` and SwiftUI representables.
- Prefer Swift Package Manager.
- Use `Worker`, `File`, and `Rive` objects; keep worker lifetime in mind.
- Calls from Rive objects must be on the main thread, enforced by `@MainActor`.
- Creating a `Rive` object can auto-bind the default ViewModel instance.

## Android Runtime

Root:

- Android: https://rive.app/docs/runtimes/android/android

Subpages:

- Artboards: https://rive.app/docs/runtimes/android/artboards
- Layout: https://rive.app/docs/runtimes/android/layouts
- State Machine Playback: https://rive.app/docs/runtimes/android/state-machines
- Data Binding: https://rive.app/docs/runtimes/android/data-binding
- Loading Assets: https://rive.app/docs/runtimes/android/loading-assets
- Fonts: https://rive.app/docs/runtimes/android/fonts
- Caching a Rive File: https://rive.app/docs/runtimes/android/caching-a-rive-file
- Playing Audio: https://rive.app/docs/runtimes/android/playing-audio
- Logging: https://rive.app/docs/runtimes/android/logging
- Rendering to a Bitmap: https://rive.app/docs/runtimes/android/rendering-to-a-bitmap
- Getting Started Legacy API: https://rive.app/docs/runtimes/android/legacy-getting-started
- Migrating from Legacy: https://rive.app/docs/runtimes/android/migrating-from-legacy

Implementation notes:

- Prefer the new Jetpack Compose API for new projects. The legacy View API uses `RiveAnimationView`.
- Add `app.rive:rive-android` and initialize Rive before use.
- Compose API uses an explicit Rive worker; keep the worker alive for all resources created from it.
- Load files through `RiveFileSource` such as `RawRes` or `Bytes`, then render with the `Rive` composable.
- Enable logging with `RiveLog.logger` during integration debugging.

## Unity Runtime

Root:

- Unity: https://rive.app/docs/game-runtimes/unity/unity

Subpages:

- Getting Started: https://rive.app/docs/game-runtimes/unity/getting-started
- Fundamentals: https://rive.app/docs/game-runtimes/unity/fundamentals
- Components: https://rive.app/docs/game-runtimes/unity/components
- Best Practices: https://rive.app/docs/game-runtimes/unity/best-practices
- Layouts: https://rive.app/docs/game-runtimes/unity/layouts
- Listeners: https://rive.app/docs/game-runtimes/unity/listeners
- State Machines: https://rive.app/docs/game-runtimes/unity/state-machines
- Data Binding: https://rive.app/docs/game-runtimes/unity/data-binding
- Loading Assets: https://rive.app/docs/game-runtimes/unity/loading-assets
- Audio: https://rive.app/docs/game-runtimes/unity/audio
- Procedural Rendering: https://rive.app/docs/game-runtimes/unity/procedural-rendering
- Runtime Asset Swapping: https://rive.app/docs/game-runtimes/unity/runtime-asset-swapping
- FAQ: https://rive.app/docs/game-runtimes/unity/faq
- Health bar tutorial: https://rive.app/docs/game-runtimes/unity/tutorials/health-bar

Implementation notes:

- Supports Unity LTS 2021+ including Unity 6.
- Uses the Rive Renderer and tracks the latest C++ runtime.
- Rendering backends include WebGL, Metal, D3D11, D3D12, OpenGL, and Vulkan depending on platform.
- For crashes, collect `Editor.log` immediately and use the rive-unity issue workflow.

## Unreal Runtime

Root:

- Unreal Engine: https://rive.app/docs/game-runtimes/unreal/unreal

Subpages:

- Getting Started: https://rive.app/docs/game-runtimes/unreal/getting-started
- Observing ViewModel Changes: https://rive.app/docs/game-runtimes/unreal/observing-viewmodel-changes
- Using Triggers: https://rive.app/docs/game-runtimes/unreal/using-triggers
- Runtime Asset Swapping: https://rive.app/docs/game-runtimes/unreal/runtime-asset-swapping
- World-Space RenderTargets: https://rive.app/docs/game-runtimes/unreal/in-world-textures

Implementation notes:

- Supports Unreal Engine 5.7.3+.
- Current supported platforms: Windows and macOS.
- Rendering uses Rive's native renderer through Unreal RHI and render thread integration.
- New integrations should use ViewModels; legacy state machine events/direct inputs are deprecated.

## C++ Runtime

Root:

- C++ overview: https://rive.app/docs/runtimes/cpp/overview

Subpages:

- Getting Started: https://rive.app/docs/runtimes/cpp/getting-started
- File & Artboard: https://rive.app/docs/runtimes/cpp/file-and-artboard
- State Machines: https://rive.app/docs/runtimes/cpp/state-machines
- Data Binding: https://rive.app/docs/runtimes/cpp/data-binding
- Asset Loading: https://rive.app/docs/runtimes/cpp/asset-loading
- Rendering Loop: https://rive.app/docs/runtimes/cpp/rendering-loop
- Command Queue: https://rive.app/docs/runtimes/cpp/command-queue
- Renderers: https://rive.app/docs/runtimes/cpp/renderers
- External Renderer: https://rive.app/docs/runtimes/cpp/external-renderer

Implementation notes:

- `rive-cpp` is the lowest-level runtime. Higher-level Apple, Android, Flutter, Unity, and Unreal runtimes wrap it.
- Use it when embedding Rive in a C++ app/game engine, targeting a new platform, or plugging into a custom renderer/render graph.
- Architecture separates file/artboard/state machine evaluation from renderer/render context.
- Rendering backends include D3D11, D3D12, Metal, Vulkan, and OpenGL/WebGL.

## Defold and Community Runtimes

- Defold: https://rive.app/docs/game-runtimes/defold
- Angular: https://rive.app/docs/runtimes/community-runtimes/angular
- C#: https://rive.app/docs/runtimes/community-runtimes/c-sharp
- Qt / QtQuick: https://rive.app/docs/runtimes/community-runtimes/qt-quick
- RiveCMP: https://rive.app/docs/runtimes/community-runtimes/rive-cmp

Community runtime rule:

- Treat community runtimes as adapter-specific. Prefer official runtime docs for state machine, ViewModel, renderer, and file-format concepts, then verify the community wrapper's API surface before coding.

## Integrations

- 3rd Party Integrations: https://rive.app/docs/integrations/overview
- HTML Embed: https://rive.app/docs/integrations/html-embed

Integration notes:

- Use HTML Embed for no-code/custom-HTML surfaces.
- For application code, prefer the official runtime package for the target platform so you can control state machines, ViewModels, assets, events, and lifecycle explicitly.

