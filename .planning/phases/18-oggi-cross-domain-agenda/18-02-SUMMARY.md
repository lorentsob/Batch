---
phase: 18-oggi-cross-domain-agenda
plan: 02
status: complete
---

## Summary

Recomposed the Oggi/Today UI to render a unified cross-domain operational feed instead of rigid section buckets. Added `TodayOperationalCardView` as the shared domain-cued grammar for all feed items.

### Changes

- **`Levain/Features/Today/TodayOperationalCardView.swift`** (new): Shared wrapper view that adds a domain cue strip (icon + label) above any Oggi feed card. Includes a `TodayAgendaItem.Domain` extension with `systemImage`, `displayName`, and `tintColor` properties (amber for bread, teal for starter, muted for kefir). Gives bread and starter cards the same structural grammar so the feed reads as one coherent multi-domain surface.
- **`Levain/Features/Today/TodayStepCardView.swift`**: Changed `section: TodayAgendaItem.Section` parameter to `urgency: TodayAgendaItem.Urgency`. `sectionLabel` → `urgencyLabel` now maps `.overdue → "In ritardo"`, `.warning → "Da fare"`, `.active → "Oggi"`, `.preview → "Domani"`.
- **`Levain/Features/Today/TodayStarterReminderRow.swift`**: Changed `isUrgent: Bool` parameter to `urgency: TodayAgendaItem.Urgency`. `isUrgent` is now derived from `urgency == .overdue || urgency == .warning`.
- **`Levain/Features/Today/TodayView.swift`**:
  - `.actionable` case now uses `ForEach(snapshot.agenda.feed)` wrapped in `TodayOperationalCardView` instead of the section-bucketed loop with headers.
  - `TodaySnapshot.make`: `todayCount` derived from `agenda.feed.filter { $0.urgency != .preview }.count`; hero subtitle derived from `agenda.feed` instead of `agenda.sections[...]`.
  - `TodayFuturePreviewCard`: updated copy to "Prossima attività" (multi-domain) and "Vai a Preparazioni" button label (v2 shell routing).
- **`LevainUITests/TodayFlowUITests.swift`**: Updated `testTodayFutureOnlyStateShowsPreviewCard` to match new "Prossima attività" copy and "Vai a Preparazioni" button. Updated `testTodaySeededLaunchShowsOperationalContent` to assert on domain cue "Pane" or action button presence instead of the removed section header "Da fare".

### Verification

- Build: SUCCEEDED
- LevainTests: 36/36 passed (all unit tests pass, no regressions)
