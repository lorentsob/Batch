# Phase 21: Runtime Hardening & Planning Sync - Context

**Gathered:** 2026-04-02
**Status:** Planning complete

<domain>
## Phase Boundary

Harden the shipped v2 shell before any new product scope lands: reduce obvious SwiftUI runtime cost in `Oggi`, fix knowledge state/navigation ownership, stop repeated kefir lineage recomputation, surface persistence failures explicitly, and reconcile stale planning/codebase memory. This phase does not add culture/grain tracking, new kefir content, or final milestone UAT.

</domain>

<decisions>
## Implementation Decisions

### Operational runtime hardening
- `Oggi` should narrow root-level invalidation and stop rebuilding expensive snapshots inside the render path when unchanged data can be reduced once per update.
- Bread helpers such as ordered-step and derived-status lookups should stop repeatedly sorting or rescanning the same relationships during view recomputation.
- The operational dashboard keeps its current card grammar and routing; this is performance hardening, not a product redesign.

### Knowledge ownership and lineage indexing
- `RootTabView` remains the sole owner of knowledge navigation; `KnowledgeView` should not create a second `NavigationStack`.
- Knowledge-facing UI should observe `KnowledgeLibrary` directly so load state and refreshes come from the actual publisher instead of indirect environment drift.
- Kefir detail, journal, archive, and comparison flows should share one lineage/index helper rather than rebuilding full-batch source/derived maps per screen.
- The kefir detail quick-actions card also needs layout and interaction hardening: secondary buttons must remain aligned, tappable, and visually consistent with the current design system.
- The `Preparazioni` hub icons should stop relying on mismatched SF Symbols where they hurt clarity; bread should use the existing `bake.svg` asset and kefir should use a simple drop icon that matches the design language instead of `drop.triangle.fill`.

### Persistence and planning safety
- Persistent bootstrap or save failures must become explicit and reviewable; silent degraded fallback is unacceptable for a local-first app.
- Reminder routing must never fabricate random object identifiers when a target batch or starter is missing.
- `.planning/codebase/*.md` and the active planning docs must be updated as part of this phase so the project memory matches the shipped three-tab shell and real feature map.

### Phase-order guardrail
- Culture/grain tracking, kefir knowledge expansion, and final v2 UAT now belong to Phase 22.
- Phase 21 only hardens the existing runtime and documentation surface so later product work lands on a cleaner base.

### Claude's Discretion
- Exact helper/type placement for Today snapshot reduction and kefir lineage indexing, as long as the resulting ownership is shared, testable, and local-first.
- Whether persistence failure surfacing is user-visible UI, structured logging, or both, as long as the app no longer degrades silently.
- Which codebase docs beyond `ARCHITECTURE.md` need updates once implementation reveals the real stale set.

</decisions>

<specifics>
## Specific Ideas

- Source audit findings point to `Levain/Features/Today/TodayView.swift`, `Levain/Models/Bake.swift`, `Levain/Features/Shared/RootTabView.swift`, `Levain/Features/Knowledge/KnowledgeView.swift`, `Levain/App/AppEnvironment.swift`, `Levain/Services/KnowledgeLoader.swift`, `Levain/Features/Kefir/KefirBatchDetailView.swift`, `Levain/Features/Kefir/KefirJournalView.swift`, `Levain/Persistence/ModelContainerFactory.swift`, and `Levain/Services/NotificationService.swift` as the first hardening targets.
- UI polish discovered during Phase 20 closeout adds `Levain/Features/Preparations/PreparationsView.swift`, `Levain/Features/Preparations/PreparationHubCardView.swift`, and the existing icon assets under `Levain/icons/` / `Levain/Assets.xcassets/` to the Phase 21 target surface.
- `LevainUITests/TodayFlowUITests.swift`, `LevainUITests/KnowledgeFlowUITests.swift`, `LevainUITests/KefirFlowUITests.swift`, `LevainUITests/NotificationRouteUITests.swift`, `LevainTests/TodayAgendaBuilderTests.swift`, and `LevainTests/KnowledgeLibraryTests.swift` already exist and should become the first regression harnesses for this phase.
- Phase 20 closeout showed that stale planning memory can be a real blocker; keeping `.planning` aligned with code is now an explicit execution requirement rather than background hygiene.

</specifics>

<deferred>
## Deferred Ideas

- Optional culture/grain tracking surfaces and measurement history - Phase 22
- Kefir knowledge filters/content and contextual troubleshooting tips - Phase 22
- Final cross-domain v2 UAT and release-readiness closure - Phase 22

</deferred>

---
*Phase: 21-runtime-hardening-planning-sync*
*Context gathered: 2026-04-02*
