# Concerns

**Analysis Date:** 2026-04-03

## Current Risks

- Phase 22 adds more SwiftData scope after V4, so migration work must stay additive and conservative.
- Notification routing is well covered in tests, but real delivery/tap lifecycle behavior still benefits from one device-level pass before release.
- Phase 21 removed obvious repeated `Oggi` recomputation, but no dedicated Instruments artifact is stored for a before/after performance baseline.
- Persistent bootstrap now fails explicitly instead of degrading silently; this is safer, but there is still no user-facing recovery/import path if a real store becomes unreadable.

## Product Risks

- Culture/grain tracking can overtake the batch-first kefir model if it becomes mandatory or too prominent in the UI.
- Knowledge can drift toward a generic recipe/reference library if Phase 22 adds filters/content without keeping the planner-first boundary.
- Bread and starter flows should remain operationally stronger than editorial or journaling features; the app loses focus if browsing starts to dominate action surfaces.

## Technical Risks

- Shared kefir presentation helpers should stay presentation-scoped; turning them into a generic fermentation abstraction would recreate the complexity the PRD rejects.
- The project still depends on Apple simulator tooling for meaningful verification, so local environment drift remains a testing constraint.

## Mitigations

- Keep schema changes additive, model names concrete, and migration stages minimal.
- Preserve direct-object routing through `AppRouter` rather than creating per-feature navigation ownership.
- Use deterministic seed scenarios plus targeted unit/UI suites to validate cross-domain behavior quickly.
- Keep new Phase 22 surfaces optional-first and anchored to operational flows, not secondary dashboards.

---
*Concerns analysis: 2026-04-03*
*Update when risks are resolved or new ones appear*
