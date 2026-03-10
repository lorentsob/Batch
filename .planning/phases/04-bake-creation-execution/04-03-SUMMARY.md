# 04-03-SUMMARY

**Execution context:** 04-bake-creation-execution - Plan 03

### Modifications Made
- Standardized the presentation of the running step timer inside `BakeDetailView`. It calculates the remaining time and handles negative differences as "In ritardo" without mutating the internal state data.
- Refactored `ShiftTimelineView` into a dedicated file (`Levain/Features/Bakes/ShiftTimelineView.swift`).
- Ensured automated tests verify the logic inside `BakeSchedulerTests`, guaranteeing that timeline shifting only impacts future, incomplete steps.
- Ensured `actualStart` and `actualEnd` are distinct attributes mapped and not overridden by simple timing ticks.

### Verification Checks Passed
- [x] Compilation validates layout integrity.
- [x] Automated tests (`BakeSchedulerTests`) run and pass successfully in the iOS Simulator.

### Next Steps
- Phase 4 is now completed.
- Move towards Phase 5 (Today Notifications) per the core Roadmap.
