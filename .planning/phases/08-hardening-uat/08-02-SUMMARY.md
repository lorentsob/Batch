# 08-02 Summary — Empty States and Internal Polish

## Status: ✅ Complete

**Completed:** 2026-03-10  
**Plan:** `08-02-PLAN.md` — Empty states, internal polish, seed decoupling  
**Depends on:** 08-01 ✅

---

## What Was Implemented

### Task 1: Decoupled First Launch from Automatic Seeding

**Modified: `Levain/Persistence/SeedDataLoader.swift`**
Refactored the loader into a clearer contract:
- `ensureSeedData(in:)` remains the explicit, idempotent public entry point. It inserts content only once per store lifetime (guarded by `didSeedSampleData` on `AppSettings`).
- Added `resetAndSeed(in:)` for in-memory test contexts that need to bypass the idempotency flag without clearing the persistent flag from a user-facing store.
- Extracted shared `insertSampleContent(in:settings:)` to avoid duplication between both entry points.
- Added documentation comments stating that normal first launch must NOT call either method automatically.

The decoupling from RootTabView was already done in 08-01 (bootstrap only seeds when `AppLaunchOptions.shouldSeedSampleData == true`). 08-02 solidifies the API surface on the loader side.

### Task 2: Align Empty States with PRD First-Launch Guidance

**Modified: `Levain/DesignSystem/Components/EmptyStateView.swift`**
Added `MultiActionEmptyStateView` alongside the existing single-action `EmptyStateView`. The new component presents multiple labeled action buttons aligned left, each with a system image, making it suitable for the Today first-launch surface without introducing a heavyweight onboarding screen.

**Modified: `Levain/Features/Today/TodayView.swift`**
The Today empty state now uses `MultiActionEmptyStateView` with the three PRD-mandated actions:
- **Nuovo bake** → navigates to Bakes tab
- **Aggiungi starter** → navigates to Starter tab
- **Esplora consigli** → navigates to Knowledge tab

Other tabs remain unchanged — their existing single-action empty states (`BakesView`, `StarterView`, `KnowledgeView`) are already concise and action-first, so no modifications were needed.

### Task 3: SeedDataLoader Unit Tests

**New file: `LevainTests/SeedDataLoaderTests.swift`**
5 focused tests covering the seed contract:

| Test | Covers |
|------|--------|
| `testEnsureSeedDataInsertsOnFirstCall` | Content present after first seed |
| `testEnsureSeedDataIdempotent` | Second call is a no-op |
| `testEnsureSeedDataSetsFlag` | `didSeedSampleData` set to `true` |
| `testFreshStoreHasNoContent` | Empty store is clean before seeding |
| `testResetAndSeedOverridesFlag` | `resetAndSeed` works after flag is true |

---

## Verification Results

| Check | Result |
|-------|--------|
| `xcodebuild build CODE_SIGNING_ALLOWED=NO` | ✅ BUILD SUCCEEDED |
| `xcodebuild test -only-testing:LevainTests/SeedDataLoaderTests` | ✅ 5/5 tests passed |
| First launch shows Nuovo bake / Aggiungi starter / Esplora consigli | ✅ MultiActionEmptyStateView in TodayView |
| Sample seed remains explicit and idempotent | ✅ ensureSeedData contract + tests |
| No automatic seeding on normal first launch | ✅ AppLaunchOptions guards in RootTabView |

---

## Files Modified

- `Levain/Persistence/SeedDataLoader.swift` — refactored + resetAndSeed + docs
- `Levain/DesignSystem/Components/EmptyStateView.swift` — added MultiActionEmptyStateView
- `Levain/Features/Today/TodayView.swift` — Today empty state → PRD action trio
- `LevainTests/SeedDataLoaderTests.swift` — **new**, 5 tests

---

## Residual Gaps / Risks

- `MultiActionEmptyStateView` uses `UUID` for `Action.id` which means identity is ephemeral — acceptable for this non-animated list.
- The "Esplora consigli" label differs slightly from the PRD canonical "Explore tips" because the app is Italian-first. This is by design.
- `BakesView` and `StarterView` empty states were reviewed and left unchanged — they already meet the action-first criteria with "Crea formula" and "Nuovo starter" CTAs.
