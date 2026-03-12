---
phase: 12-userflow-ux-conformance
plan: 01
subsystem: ui
tags: [today, bake-creation, userflow, docs]
requires: []
provides:
  - explicit Today state model
  - v2-aligned bake creation semantics
  - repository flow source of truth
affects: [testing, notification-routing, uat]
tech-stack:
  added: []
  patterns: [explicit agenda snapshot states, create-then-edit bake flow]
key-files:
  created: []
  modified: [docs/levain-user-flows.md, Levain/Services/TodayAgendaBuilder.swift, Levain/Features/Today/TodayView.swift, Levain/Features/Bakes/BakeCreationView.swift, Levain/Services/BakeScheduler.swift]
key-decisions:
  - "Today state derives from explicit modes, not from total item count"
  - "Bake name stays optional and defaults through the scheduler"
patterns-established:
  - "Flow markdown mirrors the external HTML and lives in-repo"
duration: N/A
completed: 2026-03-12
---

# Phase 12 Plan 01 Summary

**Today now exposes explicit operational modes and bake creation reflects the v2 template-first, create-then-edit flow.**

## Accomplishments

- Rewrote `docs/levain-user-flows.md` as the in-repo source of truth for the six operational flows.
- Refactored Today into explicit empty/actionable modes with future preview support.
- Made bake creation template-safe for first-time users and preserved recipe-name fallback behavior.

## Decisions Made

- Today state should be computed structurally, not inferred from one aggregate count.
- System templates must remain visible even when no saved recipes exist.

## Next Phase Readiness

Plan 02 could now tighten active execution and starter refresh behavior against the same flow contract.
