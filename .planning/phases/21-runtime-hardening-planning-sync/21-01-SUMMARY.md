# Phase 21-01 — Oggi Operational Snapshot Hardening

**Status:** Complete
**Date:** 2026-04-03

## What shipped

### Modified app files
- `Levain/Features/Today/TodayView.swift` — introduced a revision-keyed cached `TodaySnapshot` so `body` renders from a prebuilt operational view model instead of rebuilding broad cross-domain state on every recompute
- `Levain/Models/Bake.swift` — added `Bake.OperationalSnapshot` plus `makeOperationalSnapshot()` to compute ordered steps, derived bake status, and active step once per update path
- `Levain/Services/TodayAgendaBuilder.swift` — introduced `TodayAgendaBakeInput` so the agenda builder consumes precomputed bake operational data rather than repeatedly sorting relationships itself

### Modified test files
- `LevainTests/TodayAgendaBuilderTests.swift` — expanded regression coverage for urgency ordering, empty states, tomorrow previews, and kefir participation under the hardened agenda path
- `LevainUITests/TodayFlowUITests.swift` — kept the shipped Today flows green across empty, seeded, future-only, and kefir-routing scenarios

## Key decisions

- `Oggi` invalidation now hangs off a revision hash instead of letting SwiftUI body recomputation rebuild the whole operational snapshot opportunistically
- The hardening stays behavior-preserving: no Today copy, ranking rules, or routing contract changed in this wave
- No separate Instruments artifact was stored for this pass; verification relies on eliminating repeated recomputation and keeping targeted Today regressions green

## Verification

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-sim -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-todaytests -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainTests/TodayAgendaBuilderTests` — passed (`14/14`)
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived-phase21-todayui -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' CODE_SIGNING_ALLOWED=NO test -only-testing:LevainUITests/TodayFlowUITests` — passed (`7/7`)

## Outcome

`Oggi` keeps the same user-visible behavior, but the broad bake-step sorting and agenda reduction work now happens once per meaningful model update instead of repeatedly inside render paths.
