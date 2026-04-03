# Phase 20: Kefir Lineage & Journal - Context

**Gathered:** 2026-03-30
**Status:** Planning complete

<domain>
## Phase Boundary

Add the structured history and visible provenance needed to understand how milk kefir batches evolve over time: make derivation lineage readable, introduce typed kefir events, and add archive/journal surfaces that support operational decisions without replacing the action-first batch workflow. This phase does not add culture/grain tracking, kefir knowledge expansion, or a parallel bread journal.

</domain>

<decisions>
## Implementation Decisions

### Lineage model and provenance visibility
- `sourceBatchId` remains the lineage anchor introduced in Phase 19; Phase 20 turns that link into readable source/derived relationships instead of leaving provenance as a raw hidden field.
- Derived-batch creation stays batch-first and prefilled from an existing batch; provenance must be visible from both the derived batch and the source batch detail.
- A full genealogy graph or culture-linked lineage model is unnecessary here; parent/children visibility is enough for the first usable lineage surface.

### Journal data model
- Introduce a dedicated `KefirEvent` model for typed lifecycle history stored additively beside `KefirBatch`.
- Core event coverage must include batch creation, renew/manage-now, storage changes, reactivation, derivation, archive, and lightweight manual notes.
- Event capture should be automatic-first: normal batch actions create journal entries without turning everyday kefir management into mandatory journaling.

### Journal and archive surfaces
- The kefir vertical should expose journal/archive reading as a first-class internal area, not as leftover cards at the bottom of the batch list.
- Batch detail keeps one dominant operational action, but now adds concise provenance and recent-history context with a path into the full journal.
- Archived batches remain readable and derivable; archive should feel like a reusable library of prior batches, not a dead-end trash bin.

### Comparison and narrative context
- Comparison stays lightweight and qualitative: use `useLabel`, `differentiationNote`, event summaries, and lineage links to explain how batches differ.
- Avoid analytics dashboards, charts, or culture/grain measurements in this phase.
- The asymmetry from Addendum A6 remains fixed: kefir gets structured journal/history, bread keeps using the existing bake history only.

### Phase-order guardrail
- Phase 20 assumes Phase 19 has already landed usable create/manage/reminder flows and builds on those mutation points to record history.
- Culture/grain state, measurements, and related UI stay deferred to Phase 22 even if the event model leaves optional compatibility space for later.
- `Oggi` and notifications should not be redesigned here unless a small wiring fix is required to keep provenance or archive flows coherent.

### Claude's Discretion
- Exact event-row density and how much metadata belongs in journal rows versus detail drill-in.
- Whether archive and journal are separate surfaces or two sections inside one history screen, as long as both stay legible and action-adjacent.
- Naming and placement of helper services that record events or resolve provenance queries.

</decisions>

<specifics>
## Specific Ideas

- `docs/levain-prd-v2-multi-fermentations.md` sections 8.4.3, 9.4-9.6, 10.1-10.3, 11.2, and 16 plus `docs/levain-prd-v2-addendum.md` A6 are the source of truth for this phase.
- The PRD explicitly wants the journal to help compare batches and understand derivations without becoming an infinite timeline.
- The current repo already has `sourceBatchId`, seeded archived-derived examples, and batch create/manage entry points that should become the capture points for the first real event history.

</specifics>

<deferred>
## Deferred Ideas

- Culture/grain models, measurements, and growth tracking UI - Phase 22
- Kefir knowledge filters/content and contextual troubleshooting links - Phase 22
- Water kefir, recipe/consumption flows, or analytics-heavy comparison - out of scope for this milestone

</deferred>

---
*Phase: 20-kefir-lineage-journal*
*Context gathered: 2026-03-30*
