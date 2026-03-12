---
phase: 12-userflow-ux-conformance
plan: 02
subsystem: ui
tags: [execution, starter, sequencing, ux]
requires:
  - phase: 12-01
    provides: explicit operational semantics for Today and bake creation
provides:
  - sequential-default bake execution
  - persistent out-of-order feedback
  - fast starter refresh path
affects: [window-flows, notification-routing, uat]
tech-stack:
  added: []
  patterns: [confirmation-gated override, compact advanced form disclosure]
key-files:
  created: []
  modified: [Levain/Models/BakeStep.swift, Levain/Features/Bakes/BakeStepDetailView.swift, Levain/Features/Bakes/BakeStepCardView.swift, Levain/Features/Starter/RefreshLogView.swift]
key-decisions:
  - "Out-of-order execution remains supported but never becomes the default affordance"
  - "Starter refresh optimizes for speed before detail"
patterns-established:
  - "Operational actions stay primary only for current running/overdue work"
duration: N/A
completed: 2026-03-12
---

# Phase 12 Plan 02 Summary

**Bake execution now prescribes the next correct step while starter refresh compresses into the fastest operational path in the app.**

## Accomplishments

- Added explicit confirmation and persistent `Fuori ordine` signaling for out-of-sequence starts.
- Scoped quick-shift actions to real operational states.
- Collapsed starter refresh into a three-field fast path with immediate Today cleanup after save.

## Decisions Made

- Flexibility stays available, but the default UX should teach correct sequencing.
- Fast-path data entry takes precedence over always-visible advanced starter fields.

## Next Phase Readiness

Plan 03 could layer window-based timing semantics and resilient notification entry on top of the tightened operational flows.
