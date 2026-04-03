---
phase: 19-milk-kefir-batch-core
plan: 01
status: complete
---

## Summary

Added the batch-first `KefirBatch` persistence foundation, kefir-specific operational enums, and the additive V3 schema migration for Phase 19.

### Changes

- **`Levain/Models/KefirBatch.swift`** (new): Added the persisted kefir batch model with durable operational fields only: timestamps, routine, storage mode, alerts flag, source-batch linkage, optional reactivation, archive timestamp, and lightweight use/differentiation notes. Operational state and primary-action suggestion are derived from those facts instead of being persisted as a second truth.
- **`Levain/Models/DomainEnums.swift`**: Added `KefirStorageMode`, `KefirBatchState`, and `KefirPrimaryAction` so kefir storage/routing semantics stay separate from the existing bread/starter enums.
- **`Levain/Persistence/LevainSchema.swift`**: Added `LevainSchemaV3` (version `3.0.0`) with `KefirBatch` as an additive model. The live `LevainMigrationPlan` now uses one lightweight `V1 → V3` hop because the historical `V2` checkpoint is schema-identical to `V1`, and SwiftData rejects duplicate version checksums in active stages.
- **`LevainTests/TestSupport/DomainFixtures.swift`**: Added deterministic kefir batch fixtures for room-temperature, fridge, freezer, and derived-batch scenarios.
- **`LevainTests/KefirBatchTests.swift`** (new): Added focused state-derivation coverage for room, fridge, freezer, archived, and derived-batch flows, including the no-culture-required first batch path.
- **`LevainTests/PersistenceMigrationTests.swift`**: Updated migration assertions for V3 and added persistence coverage confirming kefir batches save cleanly without a culture model.
- **`Levain.xcodeproj/project.pbxproj`**: Registered the new model and unit-test files in the Xcode targets.

### Verification

- Build: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — **SUCCEEDED**
- Unit tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/KefirBatchTests` — **7/7 passed**
- Migration tests: `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainTests/PersistenceMigrationTests` — **12/12 passed**
- No destructive recovery path was introduced; the existing non-destructive bootstrap remains intact while the schema grows additively.
