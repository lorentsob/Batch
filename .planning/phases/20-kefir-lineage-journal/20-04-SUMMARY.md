# Phase 20-04 — Verification Closeout & Planning Sync

**Status:** Complete
**Date:** 2026-04-02

## What shipped

### Modified app files
- `Levain/Features/Kefir/KefirBatchComparisonView.swift` — moved the `KefirComparisonPrimaryCard` anchor onto the visible primary batch title text so the comparison surface exposes a concrete, testable accessibility node instead of relying on a card-container wrapper
- `Levain/Features/Preparations/PreparationsView.swift` — moved the `PreparationsView` anchor onto the always-visible header title so relaunch-driven kefir tests no longer depend on `List` container accessibility behavior

### Modified planning files
- `.planning/STATE.md` — Phase 20 now closes at `20-04`, progress totals are recomputed, and Phase 21 is the active ready-to-execute milestone
- `.planning/ROADMAP.md` — marks Phase 20 complete, inserts `Phase 21: Runtime Hardening & Planning Sync`, and shifts the culture/knowledge milestone to Phase 22
- `.planning/PROJECT.md` — removes the remaining archive/comparison-polish active item, records Phase 20 as fully shipped, and adds the new hardening milestone to the active backlog
- `.planning/REQUIREMENTS.md` — moves `CULTURE-01`, `KNOW-01`, and `KNOW-02` traceability from Phase 21 to Phase 22

## Key decisions

- Stable UI-test anchors now live on concrete visible nodes, not view containers whose accessibility exposure is inconsistent across SwiftUI relaunches
- A red regression suite counts as remaining phase work even when the underlying feature set looks shipped in code
- Phase numbering changed immediately in planning memory: runtime hardening is now Phase 21, while culture/grain tracking plus kefir knowledge expansion moves to Phase 22

## Verification

- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` — passed
- `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=26.4' test -only-testing:LevainUITests/KefirFlowUITests` — passed (`14/14`)

## Outcome

Phase 20 is fully closed. Kefir archive, journal, and comparison flows are both shipped and verified, and the project memory now points cleanly to the new runtime-hardening phase before any further product-scope expansion.
