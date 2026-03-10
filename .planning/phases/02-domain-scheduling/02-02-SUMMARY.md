# Phase 2: Domain Scheduling - Execution Plan 02 Summary

## 🎯 Completed Objectives
Implemented the core scheduling logic and domain helpers for backward step generation and timeline management.

## 🛠️ Changes Made

### 1. Enhanced Domain Models
- **Bake Model**:
  - Added `progress` (0.0 to 1.0) based on completed step count.
  - Added `nextActionableStep` (alias for `activeStep`) to clarify intent for UI.
  - Added `isOverdue(now:)` flag derived from the active step.
  - Added `completedStepCount` and `totalStepCount` helpers.
- **BakeStep Model**:
  - Added `isRunning` and `isPending` boolean flags.
  - Added `currentProgress(now:)` which calculates elapsed percentage for running steps based on planned duration.

### 2. Robust Scheduling Service (`BakeScheduler`)
- **Backward Generation**: Verified `generateSteps` correctly walks backward from `targetBakeDateTime`, populating all metadata from formula templates.
- **Timeline Shifting**: Validated `shiftFutureSteps` only affects incomplete steps after the anchor, preserving historical "actual" timing while updating remaining "planned" timing.
- **Auto-Sync**: Ensure `Bake.targetBakeDateTime` is updated whenever the last step's planned end shifts.

### 3. Execution Logic Hardening
- Strictly separated `plannedStart/End` from `actualStart/End`.
- Statuses are never auto-mutated by the scheduler; they require explicit `start()`, `complete()`, or `skip()` calls from the user/UI layer.
- Late/Overdue state remains a derived UI label based on current time vs. planned end.

## 🧪 Verification Results
- **Build**: `BUILD SUCCEEDED`.
- **Logic**: Confirmed that `SeedDataLoader` creates a coherent bake graph where the first steps can be completed while remaining steps stay scheduled.
- **Relationship**: Parent-child links are established during generation to ensure SwiftData can persist the entire graph in one save.

## ⏭️ Next Steps
- Implement the unit test foundation to lock in these scheduling rules (Plan 02-03).
