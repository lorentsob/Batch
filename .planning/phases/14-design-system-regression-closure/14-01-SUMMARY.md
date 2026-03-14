---
phase: 14-design-system-regression-closure
plan: 01
status: complete
completed: 2026-03-14
---

## Summary

### Task 1: Enforce light-only surfaces and chrome

- `LevainApp.swift` now forces `.preferredColorScheme(.light)` so iOS dark mode no longer leaks into the app.
- `RootTabView.swift` explicitly applies light toolbar color schemes and visible app-surface backgrounds to tab and navigation bars.
- `BakeCreationView.swift` now hides the default form scroll background, uses `Theme.Surface.app`, and keeps the sheet presentation background aligned with the light design system.

### Task 2: Fix destructive bake confirmation flow

- `BakeDetailView.swift` replaces the system `confirmationDialog` with a bottom-anchored custom destructive sheet for cancel/delete actions.
- Cancel now calls the normal persistence + notification sync path, so reminder cleanup happens immediately.
- Delete now clears the bakes navigation stack and triggers a full notification resync to remove orphaned reminders.
- `BakeReminderPlanner.swift` now returns no reminders for cancelled or completed bakes, closing a trust gap that existed even before deletion.

### Task 3: Rework cancelled and overdue bake-detail visuals

- `BakeHeaderCard` turns into a danger-emphasis card when a bake is cancelled.
- Remaining non-terminal timeline rows now render as archived instead of still showing actionable `.pending` chips.
- Contextual tips no longer remain visible on cancelled bake details.
- `StateBadge` danger / overdue tones now get a border so red chips stay legible on danger-tinted cards.
- `StepTimelineRow` now uses a centered rail/dot layout with left-aligned timing metadata, and archived rows reuse neutral tokens.
- `MetricChip` now supports neutral archived styling for done/skipped contexts.

## Files Modified

- `Levain/App/LevainApp.swift`
- `Levain/Features/Shared/RootTabView.swift`
- `Levain/Features/Bakes/BakeCreationView.swift`
- `Levain/Features/Bakes/BakeDetailView.swift`
- `Levain/Features/Bakes/BakeStepCardView.swift`
- `Levain/DesignSystem/Components/DesignPrimitives.swift`
- `Levain/DesignSystem/Components/StateBadge.swift`
- `Levain/Services/BakeReminderPlanner.swift`
