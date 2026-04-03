# Phase 19: Milk Kefir Batch Core - Context

**Gathered:** 2026-03-29
**Status:** Planning complete

<domain>
## Phase Boundary

Ship the first usable milk kefir vertical around persistent batch management: add the core `KefirBatch` model, storage-aware derived state, real kefir hub/list/detail screens, direct-first creation without a culture prerequisite, and local reminder defaults that respect room temperature, fridge, and freezer behavior. This phase owns the operational batch workflow. It does not ship structured journal/event history, rich lineage UI, or culture/grain tracking surfaces; those remain in Phases 20 and 21.

</domain>

<decisions>
## Implementation Decisions

### Data model scope
- Phase 19 centers on a persisted `KefirBatch` model as the operational unit of truth.
- `sourceBatchId` lands in the core model now so the app can support a derive-new-batch flow before Phase 20 builds richer provenance and journal UI.
- `KefirCulture` and `KefirEvent` stay deferred as first-class persisted features until later phases unless a tiny compatibility stub becomes unavoidable; the batch flow must not depend on them for basic use.
- The kefir model must extend the existing Apple-native persistence stack without creating a generic fermentation abstraction that tries to unify bread and kefir behavior.

### Derived state and storage semantics
- Batch urgency and microcopy are derived from `lastManagedAt`, expected routine, storage mode, archive/paused state, and optional planned reactivation for freezer flows.
- Storage mode is a primary kefir axis, so kefir gets dedicated domain enums instead of stretching the existing starter `StorageMode` enum beyond its meaning.
- `room_temperature` is fast-cycle and urgent, `fridge` is slower and calmer, and `freezer` is paused by default with no automatic urgency unless the user schedules reactivation.
- Derived operational state should stay in model/service code, not be persisted as a second brittle truth separate from the timestamps and routine fields that generate it.

### Creation and management flows
- The user can create the first batch directly from Preparazioni quick action or the kefir hub empty state with no culture creation prerequisite.
- Creation supports both a completely new batch and a derived batch prefilled from an existing one; the latter records origin but does not require full lineage UI yet.
- Batch detail exposes one dominant action based on current state plus quick actions for renew, derive, change storage/state, and archive.
- Renew/manage flows should update the batch in place and feel operationally lightweight, not like form-heavy journaling.

### UI structure
- `KefirHubView` stops being a placeholder and becomes the entry point to the batch list plus first-batch CTA.
- The first core kefir surfaces are: hub/list, batch card, batch detail, and the create/manage flows needed to keep a batch alive.
- Batch lists should visually separate active work, warning states, paused storage states, and archived items without turning the hub into a data dashboard.
- All kefir UI must reuse the current `Theme`, `SectionCard`, `EmptyStateView`, badges, buttons, and router patterns so the vertical feels native to Levain instead of bolted on.

### Notifications and Oggi integration
- Kefir reminder defaults follow the addendum: room temperature 24h with a warning window, fridge 7 days with a softer warning window, freezer with no automatic reminder unless reactivation is scheduled.
- Notification routing for kefir uses the same deep-link pattern as bread and starter so taps from notifications and Oggi open the real batch detail directly.
- Phase 18's Oggi contract is the integration target: Phase 19 plugs real `KefirBatch` items into that feed instead of inventing a second kefir-specific home surface.
- Reminder planning and Oggi urgency must agree on the same timing semantics so cards and notifications do not drift.

### Phase-order guardrail
- Phase 19 ships batch persistence, core list/detail/editor flows, and storage-aware reminder behavior.
- Phase 20 owns structured event history, visible derivation/provenance surfaces, and archive/journal reading experiences.
- Phase 22 owns culture/grain tracking surfaces and kefir-specific Knowledge expansion.

### Claude's Discretion
- Exact batch-card density and how much secondary context fits on the card versus detail.
- Whether manage actions use sheets, confirmation dialogs, or inline sections, as long as one dominant action stays obvious.
- Naming of small helper services or files around kefir derived state and reminder planning.

</decisions>

<specifics>
## Specific Ideas

- `docs/levain-prd-v2-multi-fermentations.md` sections 8.4, 9.4-9.6, 10-14, and 18-20 plus `docs/levain-prd-v2-addendum.md` A3 and A5 are the source of truth for this phase.
- The first-open kefir empty state should keep the approved copy direction: `Nessun batch attivo` with a direct `Nuovo batch` CTA.
- Batch examples to preserve in implementation language: main room-temperature batch, fridge backup batch, freezer long-pause batch, and a derived test batch with a different use note.

</specifics>

<deferred>
## Deferred Ideas

- Structured kefir event log, visible genealogy/provenance UI, and richer archive/journal comparison flows — Phase 20
- Optional culture/grain tracking plus measurement history and growth surfaces — Phase 22
- Kefir knowledge categories, filters, and contextual troubleshooting tips — Phase 22

</deferred>

---
*Phase: 19-milk-kefir-batch-core*
*Context gathered: 2026-03-29*
