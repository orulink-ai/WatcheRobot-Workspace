---
title: "Map hardware and structure resource entry points"
labels: "good first issue, hardware, docs"
---

## Background

ESP32 hardware docs and structure/model assets exist, but the public root docs need a maintained map of what is confirmed public, what is TBD, and what must not be published yet.

## Suggested Files

- `docs/hardware-structure-map.md`
- `docs/open-source-scope.md`
- `docs/assets/README.md`
- `docs/open-questions.md`

## Expected Result

- Keep the table for BOM, GPIO / Pin Map, wiring, STL, STEP, CAD, URDF, and assembly instructions current.
- Mark each item as confirmed, existing-but-unconfirmed, or unavailable.
- Do not copy or expose unapproved assets.

## Acceptance

- Every uncertain hardware or structure item is represented as TODO/TBD.
- No private manufacturing file is added to the root repository.
