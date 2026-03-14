---
phase: 15-memory-durability-content-separation
plan: 02
status: complete
completed: 2026-03-14
---

## Summary

### Task 1: Define backup payload and export path

- Added `BackupService.swift` with `BackupPayloadV1` and DTO records for starters, starter refreshes, saved recipes, bakes, and bake steps.
- Export uses explicit JSON encoding with `schemaVersion` and `exportedAt` metadata instead of serializing SwiftData models directly.

### Task 2: Implement replace-current restore and reminder resync

- Restore now validates the payload version, clears current user data, recreates the object graph with stable identifiers, and saves the restored dataset back into SwiftData.
- Technical `AppSettings` flags remain outside the payload; restore only resets `didSeedSampleData` defensively.
- The settings flow triggers `notificationService.resyncAll` after a successful import so reminders match restored state.

### Task 3: Add minimal settings surface for export/import

- Added a lightweight `SettingsView` sheet reachable from the Starter tab gear button.
- Added `ActivityView` to share exported JSON backups through the system share sheet.
- Import is guarded by explicit destructive confirmation before replacing the current data.

## Files Modified

- `Levain/Services/BackupService.swift`
- `Levain/Features/Shared/ActivityView.swift`
- `Levain/Features/Starter/SettingsView.swift`
- `Levain/Features/Starter/StarterView.swift`
- `LevainTests/BackupServiceTests.swift`
