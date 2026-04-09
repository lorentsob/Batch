# BUG-001: App Freeze on Bake Cancellation

**Status**: OPEN
**Severity**: HIGH
**Platform**: iOS 26.3 (Simulator & Device)
**Components**: SwiftUI, SwiftData, UserNotifications
**Date Reported**: 2026-03-15

---

## Summary

The app freezes/hangs when a user cancels a bake via the "Annulla impasto" button in `BakeDetailView`. The freeze occurs after the user confirms the cancellation in the modal. The UI becomes completely unresponsive, showing a partially rendered state (typically the bakes list view).

**Important**: The data operation DOES complete successfully - when the app is restarted, the bake is correctly marked as cancelled (`isCancelled = true`). This indicates the freeze happens AFTER the database save but during the UI update cycle.

---

## Reproduction Steps

1. Navigate to a bake detail view (`BakeDetailView`)
2. Tap "Annulla impasto" button at bottom of screen
3. Confirm cancellation in the modal ("Annulla impasto" button in `DestructiveBakeSheet`)
4. **Freeze occurs** - UI becomes unresponsive
5. Screen shows partial render of bakes list (as seen in screenshot)
6. Force quit and restart app → bake is correctly cancelled

---

## Symptoms

### Visual
- Screen freezes mid-transition
- Partial render of `BakesView` visible
- Navigation elements (back button, tab bar) unresponsive
- No crash or error dialog

### Console Output
```
Failed to send CA Event for app launch measurements for ca_event_type: 0 event_name: com.apple.app_launch_measurement.FirstFramePresentationMetric
Failed to send CA Event for app launch measurements for ca_event_type: 1 event_name: com.apple.app_launch_measurement.ExtendedLaunchMetric
```

### Stack Trace Reference
```
#0    0x00000001016df2c0 in closure #1 in closure #1 in RootTabView.body.getter at Levain/Features/Shared/RootTabView.swift:23
```

This points to the banner display logic in `RootTabView`:
```swift
// Line 23 in RootTabView.swift
.accessibilityLabel(banner.message)
```

---

## Technical Analysis

### Root Cause Hypothesis

The freeze is caused by a **SwiftUI + SwiftData concurrency conflict** when:

1. A SwiftData `@Model` object (`Bake`) is mutated (`isCancelled = true`)
2. The mutation triggers a view update on `BakeDetailView`
3. Simultaneously, we programmatically navigate away (`router.bakesPath.removeLast()`)
4. The notification sync task accesses the same `Bake` object from a different context
5. SwiftUI attempts to reconcile multiple conflicting state changes at once

### SwiftData Threading Issues

SwiftData models are **NOT thread-safe**. Key constraints:

- `@Model` objects must be accessed from the same `ModelContext` they were fetched from
- `ModelContext` is bound to a specific actor (typically `@MainActor`)
- Accessing a model from a different Task/thread causes undefined behavior
- Even `Task { @MainActor in }` can cause issues if the Task executes while the view is mid-update

### The Animation Conflict

The freeze specifically occurs when:
- Modal dismissal animation is running
- Bake state changes (`isCancelled = true`)
- View navigation occurs (`bakesPath.removeLast()`)
- Banner animation triggers

SwiftUI cannot handle this cascade of simultaneous state changes, especially when they involve:
1. Structural view changes (navigation)
2. Data model mutations (SwiftData save)
3. Published property updates (`@Published banner`)
4. Multiple animations (modal dismiss, navigation transition, banner slide-in)

---

## Attempted Solutions

### Attempt 1: Deferred State Change with Task.sleep
```swift
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(350))
    bake.isCancelled = true
    persistAndSync()
    environment.showBanner(...)
}
```
**Result**: Still freezes. The view tries to update while Task is sleeping.

---

### Attempt 2: DispatchQueue.main.async
```swift
DispatchQueue.main.async {
    bakeToCancel.isCancelled = true
    try? context.save()
    Task {
        await env.notificationService.syncNotifications(for: bakeToCancel)
        ...
    }
}
```
**Result**: Still freezes. Accessing `bake` from async closure causes thread issues.

---

### Attempt 3: Task.detached
```swift
Task.detached { @MainActor in
    await environment.notificationService.syncNotifications(for: bakeToCancel)
    ...
}
```
**Result**: Worse - immediate crash. `Task.detached` runs on background thread, trying to access SwiftData object from wrong context.

---

### Attempt 4: Navigate Before Cancel
```swift
destructivePrompt = nil
bake.isCancelled = true
try? modelContext.save()
router.bakesPath.removeLast()  // Pop BEFORE notification sync
Task {
    await env.notificationService.resyncAll(using: context)
    ...
}
```
**Result**: Still freezes. Navigation triggers view update on cancelled bake, conflict ensues.

---

### Attempt 5: Fresh Fetch with Delays (Current)
```swift
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(100))

    // Fresh fetch to avoid stale reference
    let descriptor = FetchDescriptor<Bake>(predicate: #Predicate { $0.id == bakeID })
    guard let bakeToCancel = try? context.fetch(descriptor).first else { return }

    bakeToCancel.isCancelled = true
    try? context.save()

    try? await Task.sleep(for: .milliseconds(100))

    routerRef.bakesPath.removeLast()
    await env.notificationService.resyncAll(using: context)
    env.showBanner(...)
}
```
**Result**: Still freezes. Even with fresh fetch and delays, SwiftUI cannot reconcile the state changes.

---

## Detailed Logging Analysis

When comprehensive logging was added, the sequence showed:

```
🔵 [BakeDetail] confirm() called for prompt: cancel
🔵 [BakeDetail] Setting destructivePrompt to nil
🔵 [BakeDetail] Cancelling bake on main thread
✅ [BakeDetail] Context saved successfully
🔵 [BakeDetail] Starting notification sync task
🟢 [NotificationService] syncNotifications for bake: C9B5D04E-...
🟠 [BakeReminderPlanner] Getting derived status...
🟠 [BakeReminderPlanner] Bake status: cancelled
✅ [NotificationScheduler] All plans processed
✅ [NotificationService] Sync completed
✅ [BakeDetail] Banner shown
```

**All operations complete successfully** - no errors, no exceptions. The freeze happens **after** all work is done, during SwiftUI's view update/layout phase.

---

## Why Data Saves Successfully

The save completes because:
1. SwiftData operations are synchronous and complete before any async work
2. `try? context.save()` commits to the persistent store immediately
3. The freeze occurs in SwiftUI's rendering pipeline, not in data layer

This is a **UI rendering deadlock**, not a data corruption issue.

---

## Possible Remaining Solutions

### Option 1: Remove Modal Animation Entirely
```swift
// In DestructiveBakePrompt overlay
.transition(.identity)  // No animation
```
Remove ALL animations from the cancel flow to eliminate timing conflicts.

### Option 2: Use Environment Dismiss
Instead of programmatic navigation, present `BakeDetailView` as a sheet and dismiss it:
```swift
@Environment(\.dismiss) var dismiss

// On cancel:
bake.isCancelled = true
try? modelContext.save()
dismiss()  // Let system handle navigation
```

### Option 3: Separate Cancellation Screen
Navigate to a dedicated "CancellingBakeView" that handles the operation:
```swift
router.bakesPath.append(.cancelling(bakeID))
// CancellingBakeView performs cancel, then auto-navigates back
```

### Option 4: Disable Animation on Router
```swift
var bakesPath: NavigationPath {
    get { _bakesPath }
    set {
        withAnimation(.none) {  // Disable animation
            _bakesPath = newValue
        }
    }
}
```

### Option 5: Background Context
Use a background `ModelContext` for the save:
```swift
let backgroundContext = ModelContext(modelContainer)
Task.detached {
    await backgroundContext.perform {
        let bake = backgroundContext.model(for: bake.objectID)
        bake.isCancelled = true
        try? backgroundContext.save()
    }
}
```

---

## Files Involved

- `Levain/Features/Bakes/BakeDetailView.swift` - Main view with cancel logic
- `Levain/Services/NotificationService.swift` - Notification sync
- `Levain/Services/BakeReminderPlanner.swift` - Accesses `bake.derivedStatus` and `bake.sortedSteps`
- `Levain/App/AppEnvironment.swift` - Banner state management
- `Levain/Features/Shared/RootTabView.swift` - Banner display (line 23 in stack trace)
- `Levain/Models/Bake.swift` - SwiftData model with computed properties

---

## Related Issues

- SwiftData concurrency limitations: https://developer.apple.com/documentation/swiftdata/modelcontext
- SwiftUI animation conflicts: Known issue with NavigationStack + sheet combinations
- Banner display timing: Accessing Published properties during view updates

---

## Workaround for Users

**Current Status**: Bug prevents in-app cancellation without freeze.

**User Workaround**:
1. Force quit app
2. Relaunch
3. Bake will be correctly cancelled (data saved)
4. Use "Elimina impasto" button to delete (no freeze on delete)

---

## Next Steps

1. Test Option 2 (Environment dismiss) - most SwiftUI-native approach
2. If that fails, try Option 3 (dedicated cancellation screen)
3. Consider filing FB with Apple if issue persists (potential SwiftUI/SwiftData bug)
4. Review similar open source apps for patterns

---

## Technical Debt

This bug reveals deeper architectural concerns:

1. **Too much work in view layer**: Business logic (cancel, save, sync) should be in view models
2. **Router coupling**: Direct manipulation of `router.bakesPath` creates implicit dependencies
3. **Notification sync timing**: Should be decoupled from UI operations
4. **SwiftData live queries**: `@Query` in views creates implicit observation that's hard to control

**Recommendation**: Consider migrating to MVVM with explicit state machines for complex operations like bake cancellation.
