---
name: rive-runtime-development
description: Integrate Rive runtime animations in React, Vite, Tauri, or desktop UI surfaces. Use when working with .riv files, Rive artboards, state machines, state machine inputs, asset loading, renderer choice, or replacing CSS/SVG motion with Rive in VILab.
---

# Rive Runtime Development

## Workflow

1. Route the task through the official runtime map in `references/rive-runtime-doc-map.md`: identify the target format/platform first (`Web JS`, `React`, `React Native`, `Flutter`, `Apple`, `Android`, `Unity`, `Unreal`, `C++`, `Defold`, community runtime, or HTML embed).
2. Inspect the host app: framework, bundler, target window, existing animation states, accessibility role, test style, asset conventions, and platform renderer constraints.
3. Inspect the `.riv` contract before coding: file path, artboard name, state machine name, ViewModel/default instance, input/property names and types, whether assets are embedded/hosted/referenced, whether the file uses text/layout/audio/scripting/vector feathering, and whether a newer runtime version is required.
4. Choose the runtime package:
   - React surfaces: prefer `@rive-app/react-webgl2` when quality, performance, vector feathering, or renderer-only features matter.
   - Simpler React graphics: use `@rive-app/react-canvas` when bundle size matters and the file does not require renderer-only features.
   - Avoid `canvas-lite` when the `.riv` uses text, layouts, audio, scripting, or other advanced features.
5. Put `.riv` files under the app's public/static asset path unless the repo has an existing asset pipeline for binary files. In Vite, `/assets/foo.riv` maps to `public/assets/foo.riv`.
6. Add `*.riv binary` to `.gitattributes` when committing Rive files so line-ending conversion cannot corrupt them.
7. Prefer a small wrapper component around `useRive`; keep Rive lifecycle isolated from the parent component.
8. Map app state to Rive through Data Binding/ViewModel first when available. Use legacy `useStateMachineInput`/`stateMachineInputs` only for older files, compatibility fallback, or runtime inspection. Do not try to mutate internal state machine states directly.
9. If the file exposes ViewModel properties, enable `autoBind: true` when a default ViewModel/default instance is configured, then drive `rive.viewModelInstance` properties. Trigger properties use `.trigger(name)?.trigger()`; number properties use `.number(name).value = n`; color properties use `.color(name)?.rgb(r, g, b)`/`.rgba(...)`.
10. For React, do not depend on `rive` inside `onLoad`; use an effect that watches the returned `rive` instance. Ensure the canvas has nonzero dimensions. Consider `useOffscreenRenderer` when multiple WebGL2 instances may be active.
11. Keep the existing nonvisual accessibility surface: labels, `role="status"`, keyboard behavior, and fallbacks should remain in React/HTML or the host platform UI, not only inside Rive.
12. Verify with typecheck/unit tests and a visual smoke test. For Tauri overlays, verify transparency, canvas sizing, and pointer/event behavior in the actual window.

## React Pattern

Use `useRive` when runtime control is needed:

```tsx
import {
  Alignment,
  Fit,
  Layout,
  useRive,
  useStateMachineInput,
} from '@rive-app/react-webgl2';

const MACHINE = 'VoiceOrb';

export function VoiceRiveOrb(props: {
  active: boolean;
  processing: boolean;
  failed: boolean;
  level: number;
  label: string;
}) {
  const { rive, RiveComponent } = useRive(
    {
      src: '/rive/voice-orb.riv',
      artboard: 'VoiceOrb',
      stateMachines: MACHINE,
      autoplay: true,
      autoBind: true,
      layout: new Layout({ fit: Fit.Contain, alignment: Alignment.Center }),
    },
    { useOffscreenRenderer: true },
  );

  const isRecording = useStateMachineInput(rive, MACHINE, 'isRecording', false);
  const isProcessing = useStateMachineInput(rive, MACHINE, 'isProcessing', false);
  const isFailed = useStateMachineInput(rive, MACHINE, 'isFailed', false);
  const volume = useStateMachineInput(rive, MACHINE, 'volume', 0);

  useEffect(() => {
    if (isRecording) isRecording.value = props.active;
    if (isProcessing) isProcessing.value = props.processing;
    if (isFailed) isFailed.value = props.failed;
    if (volume) volume.value = Math.max(0, Math.min(1, props.level));
  }, [isFailed, isProcessing, isRecording, props.active, props.failed, props.level, props.processing, volume]);

  return (
    <div aria-label={props.label} role="status">
      <RiveComponent className="voice-rive-orb__canvas" />
    </div>
  );
}
```

Notes:
- The Rive component instantiates only after its canvas is mounted. Give its wrapper stable dimensions.
- `useStateMachineInput` can return `null` until the file and runtime instance are ready; guard every assignment.
- `useStateMachineInput` is deprecated for new work in the React docs; prefer ViewModel/Data Binding when a file exposes it.
- For single-state status transitions, boolean inputs are enough. For continuous speech activity, use a numeric input like `volume`.
- Trigger inputs are best for one-shot actions such as `successPulse.fire()`.
- When a file uses ViewModel/Data Binding properties, read `rive.viewModelInstance` after load. Use `viewModelInstance.trigger('successPulse')?.trigger()` for triggers and `viewModelInstance.number('volume')!.value = level` for numbers. Keep a retry path because the canvas, Rive instance, and ViewModel binding may not become ready in the same React render.
- React `onLoad` can fire before the `rive` value returned from `useRive` is available to consumer code. Put playback/data-binding setup that needs `rive` in a `useEffect`.

## Official Runtime Page Routing

Use `references/rive-runtime-doc-map.md` whenever the target is not clearly the current VILab React/Tauri overlay. It records the official Rive runtime pages under:

- Shared runtime pages: getting started, demos, feature support, runtime sizes, renderer selection, and `.riv` file format.
- Web JS: core WASM runtime, Canvas vs WebGL2, parameters, artboards, layout, state machines, Data Binding, assets, fonts, WASM preloading, caching, audio, low-level API, migration, FAQ.
- React: component/hook API, parameters/return values, artboards, layout, state machines, Data Binding, assets, fonts, WASM preloading, caching, audio, bitmap rendering, migration.
- React Native: new Nitro runtime, file loading, props, ref methods, error handling, Expo, native SDK override, artboards, layout, state machines, Data Binding, assets, fonts, caching, audio, migration.
- Flutter: Rive Native, widgets/builders/panels/controllers, artboards, layout, state machines, Data Binding, assets, fonts, caching, audio, migration, FAQ, API reference.
- Apple and Android: workers/files/views or composables, artboards, layout, state machines, Data Binding, assets, fonts, caching, audio, logging, migration.
- Unity and Unreal: game-runtime entry points, components, layouts, listeners/triggers, state machines, Data Binding/ViewModels, assets, audio/render targets, runtime asset swapping.
- C++: lowest-level runtime, file/artboard, state machines, Data Binding, asset loading, rendering loop, command queue, renderers, external renderer.
- Defold/community runtimes and HTML embed/3rd-party integrations.

When coding for a platform outside React/Web, read the relevant section in that map first and then open the official linked page if API names or version details matter.

## VILab Overlay Contract

When replacing the VILab floating overlay liquid dot, preserve the current semantic modes from `src/windows/OverlayWindow.tsx`:

- `armed`: recording is active but speech is not detected.
- `speaking`: recording is active and speech activity is detected or held briefly.
- `processing`: audio/text pipeline is running.
- `success`: retained/inserting result state.
- `failed`: failed result with retained text.

Recommended Rive state machine contract:

- Artboard: `VoiceOrb`
- State machine: `VoiceOrb`
- Boolean inputs: `isRecording`, `isSpeaking`, `isProcessing`, `isSuccess`, `isFailed`
- Number input: `volume`, normalized `0..1`
- Optional triggers: `start`, `finish`, `fail`, `reset`

Implementation approach in VILab:

1. Add the `.riv` file under `public/rive/voice-orb.riv`.
2. Add `*.riv binary` to `.gitattributes`.
3. Add the Rive React runtime dependency.
4. Create `src/windows/VoiceRiveOrb.tsx` as an isolated wrapper.
5. In `OverlayWindow.tsx`, replace only the `overlay-bubble-orb` inner liquid DOM with the wrapper while keeping the outer anchor, status label, halo, and status text logic.
6. Keep the CSS liquid orb code until the Rive path has shipped or add a feature flag/fallback so a load failure does not make the overlay blank.
7. Update tests to assert the wrapper receives the derived mode and label, not the internal Rive canvas details.

For files exported with ViewModel properties, prefer this concrete contract:

- Artboard/state machine names must match the exported `.riv` exactly.
- `autoBind: true` must be set.
- Triggers: `speaking`, `stop`, `loading`, `loading2`, `succeed`, `error`.
- Number: `audiolevel`, mapped to `0..100`.
- Optional color property: one ViewModel property of type `color`; VILab samples the native overlay background before showing the floating window and writes `#ffffff` for dark backgrounds or `#000000` for light backgrounds through `.color(name)?.rgb(r, g, b)`.
- Use `loading2` when recording enters processing before `speaking` ever fired in the current recording run. Fall back to `loading` if `loading2` is not exposed by the exported file.
- Drive both `rive.viewModelInstance` and legacy state machine inputs when debugging a designer-provided file, then remove the unused path only after runtime inspection proves which API the file uses.
- Treat `stateMachineInputs()` as an inspection/fallback path, not a gate for data binding. If legacy input inspection returns empty or throws, continue polling and still evaluate `rive.viewModelInstance` so ViewModel/Data Binding controls can drive the animation.

## Verification

- Run `npm run typecheck` after adding the dependency and component.
- Run `npm run test:unit -- src/windows/OverlayWindow.test.tsx` or the repo's supported unit-test command.
- In a browser/Tauri smoke test, confirm the canvas is nonzero sized, transparent background still works, and overlay text remains readable.
- Simulate all overlay states: idle hidden, recording armed, speaking with volume, processing, success/retained, and failed retained.

## References

Read `references/rive-official-notes.md` for compact notes from the Rive runtime docs and links to the official pages.
Read `references/rive-runtime-doc-map.md` for the full official runtime documentation map and platform routing notes.
