# Phase 17: V2 Shell & Preparation Hubs - Context

**Gathered:** 2026-03-29  
**Status:** Planning complete

<domain>
## Phase Boundary

Introduce the v2 top-level shell with `Oggi`, `Preparazioni`, and `Knowledge`; move existing bread workflows behind a `Preparazioni > Pane e lievito madre` hub; keep current bread, starter, and formula UX working through reused views, components, and router logic; keep operational taps direct; and prepare the additive schema migration needed before kefir models land. Milk kefir can appear as a hub entry, but full batch management belongs to later phases.

</domain>

<decisions>
## Implementation Decisions

### Shell architecture
- Replace the current `Today / Impasti / Starter / knowledge sheet` shell with three top-level tabs: `Oggi`, `Preparazioni`, and `Knowledge`.
- `Knowledge` becomes a real tab, not a modal sheet layered on the root shell.
- `Preparazioni` owns domain entry points and replaces direct top-level access to Impasti and Starter.
- Existing operational taps from `Oggi` must keep navigating directly to the underlying bread/starter object instead of forcing the new hierarchy.

### Bread preservation and reuse
- `Pane e lievito madre` remains internally split into `Impasti`, `Starter`, and `Formule`.
- Existing views, routes, and services in `Features/Bakes`, `Features/Starter`, `AppRouter`, `NotificationService`, `Today`, and the current design system must be reused and extended, not duplicated.
- Phase 17 changes how bread features are reached, not how the internal bread workflow behaves.

### Preparations UX
- The Preparazioni root shows two hub cards: `Pane e lievito madre` and `Milk kefir`.
- Quick actions are always visible in the Preparazioni root and must stay lightweight while reusing existing button/card patterns.
- Both hub cards stay visible even when empty and expose an inline CTA that matches the empty domain state.
- The bread hub should feel native to the existing design system, using current tokens and shared components such as `SectionCard`, `EmptyStateView`, and `StateBadge`.

### Data migration guardrail
- The v1 → v2 schema migration is additive only.
- Existing models stay untouched; new kefir models will be added under a new schema version.
- Phase 17 prepares the migration scaffolding before Phase 19 introduces the new persisted types.

### Backward compatibility
- Existing bake and starter deep links must continue to work after the navigation migration and must bypass the Preparazioni hierarchy when invoked from operational contexts.
- Notification entry must still route safely to bread objects even though the top-level tabs change.

### Claude's Discretion
- Exact layout of hub cards and any quick-action strip.
- Whether the bread hub uses section cards, list rows, or grouped blocks, as long as the current visual language is preserved.

</decisions>

<specifics>
## Specific Ideas

- `docs/levain-prd-v2-multi-fermentations.md` sections 6, 8.2, 8.3, 20, 21, and 23 Phase A plus `docs/levain-prd-v2-addendum.md` A1, A4, A7, and A8 are the source of truth for this phase.
- Desired perception: the app feels broader, but bread still feels "in the same place".
- The milk kefir entry can begin as a lightweight hub placeholder if internal kefir flows are not implemented yet.

</specifics>

<deferred>
## Deferred Ideas

- Cross-domain Oggi dashboard structure, urgency ranking, and time-based tie-breakers — Phase 18
- Milk kefir data model, batch flows, and reminder logic — Phase 19
- Batch derivation, journal, and archive UX — Phase 20
- Culture/grain tracking and kefir knowledge expansion — Phase 21

</deferred>

---
*Phase: 17-shell-preparations-hubs*  
*Context gathered: 2026-03-29*
