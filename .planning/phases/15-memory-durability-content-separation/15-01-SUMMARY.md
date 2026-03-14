---
phase: 15-memory-durability-content-separation
plan: 01
status: complete
completed: 2026-03-14
---

## Summary

### Task 1: Introduce explicit schema source of truth

- Added `LevainSchema.swift` with `LevainSchemaV1`, containing every persisted model currently owned by SwiftData.
- Added `LevainMigrationPlan` as the explicit migration-plan anchor for future schema evolution.

### Task 2: Remove destructive persistent-store recovery

- `ModelContainerFactory.swift` now creates containers from `LevainSchema.current` and `LevainMigrationPlan.self`.
- The old destructive recovery path was removed; persistent bootstrap now falls back to an in-memory container instead of deleting the local store.
- The new inline rule documents that future persisted-model changes require explicit schema ownership.

### Task 3: Align tests with the schema baseline

- Added `ModelTestSupport.swift` so tests can create in-memory contexts from the same schema and migration plan as production code.
- Updated `SeedDataLoaderTests.swift` to use the shared schema-aware helper.

## Files Modified

- `Levain/Persistence/LevainSchema.swift`
- `Levain/Persistence/ModelContainerFactory.swift`
- `LevainTests/TestSupport/ModelTestSupport.swift`
- `LevainTests/SeedDataLoaderTests.swift`
