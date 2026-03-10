# Concerns

**Analysis Date:** 2026-03-10

## Current Risks

- SwiftData schema churn can create avoidable migration pain if model fields keep changing during the MVP bootstrap.
- Notification delivery is straightforward, but notification tap routing still needs real lifecycle verification on simulator or device.
- Formula step templates are persisted through lightweight encoded data inside a primary model; this is intentionally simple, but it should stay stable once shipped.

## Product Risks

- The app can become a bloated recipe manager if formula editing and notes expand without discipline.
- Starter management should remain secondary; if it dominates the navigation, the product drifts away from the planner-first promise.

## Technical Risks

- Aggressive over-abstraction would work against the PRD and increase AI-assisted maintenance cost.
- iOS 26-only targeting is fine for this project, but it means testing assumptions should be verified against the installed Xcode runtime early.

## Mitigations

- Keep model names and relationships conservative during the first iteration.
- Build around local notifications and persisted state, not fragile background timers.
- Use sample seed data and tests to catch regressions in scheduling logic quickly.

---
*Concerns analysis: 2026-03-10*
*Update when risks are resolved or new ones appear*

