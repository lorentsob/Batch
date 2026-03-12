---
phase: 12-userflow-ux-conformance
plan: 03
subsystem: testing
tags: [notifications, deep-links, window-based, verification]
requires:
  - phase: 12-01
    provides: updated flow semantics
  - phase: 12-02
    provides: tightened operational execution behavior
provides:
  - window-aware reminder behavior
  - resilient notification fallback routing
  - phase verification and UAT scaffolding
affects: [manual-uat, release-confidence]
tech-stack:
  added: []
  patterns: [cold-launch route simulation, accessibility probes for transient banners]
key-files:
  created: [.planning/phases/12-userflow-ux-conformance/12-VERIFICATION.md, .planning/phases/12-userflow-ux-conformance/12-UAT.md]
  modified: [Levain/Services/BakeReminderPlanner.swift, Levain/App/AppRouter.swift, Levain/Features/Shared/RootTabView.swift, LevainUITests/NotificationRouteUITests.swift, LevainUITests/LifecycleUITests.swift]
key-decisions:
  - "Window-based urgency is tied to flexible windows, not rigid planned end times"
  - "Notification fallbacks must always be observable and non-blocking"
patterns-established:
  - "Transient UI feedback should expose an accessibility probe when XCTest needs deterministic assertions"
duration: N/A
completed: 2026-03-12
---

# Phase 12 Plan 03 Summary

**Window-based fermentation now follows real flexible windows, and notification entry behaves safely across warm launch, cold launch, stale payloads, and denied permissions.**

## Accomplishments

- Added open-window and close-window reminder behavior for flexible fermentation steps.
- Hardened notification routing with explicit fallback behavior and deterministic UI-test observability.
- Produced verification and UAT artifacts to hold the phase open until human sign-off.

## Decisions Made

- A banner is acceptable fallback UX, but it must be deterministic under automation and non-blocking in production.
- Phase 12 is not considered closed until the six manual UAT passes are performed on-device.

## Next Phase Readiness

Automated work is ready; remaining work is human UAT execution against the checklist in `12-UAT.md`.
