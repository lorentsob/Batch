---
phase: 15-memory-durability-content-separation
verified: 2026-03-14T20:38:00+0100
status: partially-verified
score: 5/5 implementation truths verified in code plus local automated coverage; manual device UAT pending
---

# Phase 15: Memory Durability & System Content Separation Verification Report

**Phase Goal:** Protect persisted user data across app updates, add manual JSON backup or restore, and separate bundled system content from demo seed and user-owned SwiftData records.  
**Verified:** 2026-03-14T20:38:00+0100  
**Status:** partially-verified

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | SwiftData persistence is now owned by an explicit `VersionedSchema` plus `SchemaMigrationPlan` | ✓ VERIFIED | `Levain/Persistence/LevainSchema.swift`, `Levain/Persistence/ModelContainerFactory.swift` |
| 2 | Persistent bootstrap no longer auto-deletes the on-disk store as a recovery path | ✓ VERIFIED | `Levain/Persistence/ModelContainerFactory.swift` |
| 3 | User-owned data can be exported and restored through a versioned JSON payload | ✓ VERIFIED | `Levain/Services/BackupService.swift`, `Levain/Features/Starter/SettingsView.swift` |
| 4 | Official system formulas are bundled JSON and no longer depend on hardcoded templates or demo seed | ✓ VERIFIED | `Levain/Resources/system_formulas.json`, `Levain/Services/SystemFormulaLoader.swift`, `Levain/Features/Bakes/BakeCreationView.swift` |
| 5 | `Nuovo bake` still exposes system templates on an empty store, while saved recipes remain separate | ✓ VERIFIED | `Levain/Features/Bakes/BakeCreationView.swift`, `LevainUITests/BakesFlowUITests.swift` |

**Score:** 5/5 truths verified in code and local automation

## Automated Checks

- ✅ `xcodebuild -project Levain.xcodeproj -scheme Levain -destination 'platform=iOS Simulator,name=iPhone 17' test`
  Result: unit tests and Swift Testing suites passed; the combined UI pass hit simulator preflight `Busy` instability after earlier UI suites had already started passing.
- ✅ `xcodebuild -project Levain.xcodeproj -scheme Levain -destination 'platform=iOS Simulator,id=27A991FD-EBF5-4F33-AE7E-0E225BB5E06F' -only-testing:LevainUITests -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 test`
  Result: serial UI verification passed for `LevainUITests`, `KnowledgeFlowUITests`, and `NotificationRouteUITests`; `BakesFlowUITests` locators were then tightened against the real accessibility tree.
- ✅ `xcodebuild -project Levain.xcodeproj -scheme Levain -destination 'platform=iOS Simulator,id=27A991FD-EBF5-4F33-AE7E-0E225BB5E06F' -only-testing:LevainUITests/BakesFlowUITests -parallel-testing-enabled NO -maximum-concurrent-test-simulator-destinations 1 test`
  Result: `BakesFlowUITests` passed after final stabilization of empty-state and bundled-template locators.

## Human Verification Required

Manual device verification is still required for the durability promises that simulator automation cannot prove.

### 1. Update-over-existing-data pass
**Test:** Install a build with real local data on an iPhone, then install the new build over it.  
**Expected:** Starters, refresh logs, saved recipes, bakes, and bake steps remain intact with no silent reset.

### 2. Backup round-trip
**Test:** Export a backup JSON, reinstall or clear the app, import the backup, and compare restored data plus reminders.  
**Expected:** Restored logical state matches the export and notifications resync cleanly.

### 3. Fresh-launch bundled-template separation
**Test:** Launch with an empty store and no demo seed, then open `Nuovo bake`. Repeat with `LEVAIN_SEED_SAMPLE_DATA=1`.  
**Expected:** Bundled system templates remain available in both cases, while demo seed stays an internal-only path and does not become the official template source.

## Gaps Summary

No code-level or local-automation gaps remain for the implemented Phase 15 scope. Residual risk is limited to real-device durability checks that cannot be proven from simulator-only runs.

---
*Verified: 2026-03-14T20:38:00+0100*  
*Verifier: Codex*
