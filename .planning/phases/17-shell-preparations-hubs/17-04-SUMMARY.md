---
phase: 17-shell-preparations-hubs
plan: 04
status: complete
---

## Summary

Added the additive v2 SwiftData schema migration boundary before kefir models land.

### Changes

- **`Levain/Persistence/LevainSchema.swift`**: Added `LevainSchemaV2` (version 2.0.0) with the same 6 model types as V1. Updated `LevainSchema.current` to use V2 models. Added a lightweight `v1ToV2` migration stage to `LevainMigrationPlan`. The V1→V2 stage is lightweight (no column changes); the boundary exists to give Phase 19 a clean insertion point for `KefirBatch` without improvising schema work.
- **`Levain/Persistence/ModelContainerFactory.swift`**: No changes needed — it already references `LevainSchema.current` and `LevainMigrationPlan`, which now point to V2.
- **`LevainTests/PersistenceMigrationTests.swift`** (new): 9 focused tests covering schema version identifiers, V2 model list completeness, in-memory container bootstrap, entity survival after migration, and migration stage count.

### Verification

- Build: SUCCEEDED
- PersistenceMigrationTests: 9/9 passed
- No destructive recovery paths introduced
