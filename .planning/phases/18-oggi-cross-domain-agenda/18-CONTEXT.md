# Phase 18: Oggi Cross-Domain Agenda - Context

**Gathered:** 2026-03-29
**Status:** Planning complete

<domain>
## Phase Boundary

Rebuild `Oggi` as the v2 daily operational dashboard: replace the current fixed-section `Today` board with a single cross-domain feed that keeps all active objects visible, communicates urgency on the card, and opens the underlying object directly. Phase 18 owns the agenda contract, presentation grammar, and router behavior. It does not ship persisted kefir batch CRUD, storage-aware reminders, lineage, journal, or culture tracking; those remain in later phases.

</domain>

<decisions>
## Implementation Decisions

### Agenda architecture
- Replace rigid `urgent / scheduled / tomorrow` buckets with one ordered operational feed plus supporting states for empty, future-only, and hero copy.
- Keep ranking and derived-state rules in `TodayAgendaBuilder` or an adjacent service layer, not inline in `TodayView`.
- Bread-step urgency and starter due-state must continue to come from existing models and services; Phase 18 must not invent a second state machine.
- Because Phase 19 owns persisted kefir models, Phase 18 introduces a kefir-ready agenda contract and router surface now, while real SwiftData-backed kefir items plug into that contract in the next phase.

### Ordering and urgency
- Urgency is an attribute of each card, not a structural section header.
- Ranking order follows the addendum: overdue or critical warning first, then items to manage today, then active items without immediate urgency, then future preview.
- Tie-breakers are time-based only with no bread/starter/kefir domain priority: overdue items sort by oldest missed time first, warning items by nearest due time first, and non-urgent active items by most recent relevant activity first.
- Future preview remains secondary and should never hide active objects that are still operationally relevant today.

### Card grammar
- All Oggi items share one operational card language: explicit domain cue (`Pane`, `Starter`, `Kefir`), timing context, derived state microcopy, and one dominant visible action.
- Bread cards may keep richer step context than starter or kefir cards, but they should sit inside the same overall frame and urgency grammar.
- Starter reminders should stop reading like a system exception and instead look like first-class operational objects within the same feed.
- Active non-urgent objects stay visible when present; do not collapse them into a separate summary widget that hides operational context.

### Routing contract
- Tapping an Oggi card must open the underlying bake, starter, or future kefir batch detail directly through `AppRouter`.
- Preparazioni remains for exploration and creation, not for operational traversal from Oggi.
- Inline primary actions may remain as fast operational shortcuts when they do not break the card-tap direct-detail rule.
- The router and deep-link surface become kefir-ready in this phase so Phase 19 can add batch detail without redefining Oggi semantics.

### Empty and future states
- Empty-state copy shifts to the multi-domain product language: `Nuova preparazione` and `Esplora knowledge`.
- Future-only state previews the next relevant object across domains without reintroducing rigid buckets or descriptive dashboard prose.
- Keep hero metrics minimal. The screen should explain what matters next, not summarize the whole database.

### Phase-order guardrail
- Phase 18 delivers the cross-domain agenda contract, ordered-feed UI, and direct-routing behavior.
- Phase 19 delivers the persisted kefir models, storage-aware severity/microcopy, reminder defaults, and real batch cards backed by SwiftData.
- No journal, archive comparison, culture tracking, or knowledge-filter work belongs here.

### Claude's Discretion
- Exact density balance between full cards and more compact non-urgent rows.
- Whether future preview appears as a standalone card or a compact secondary module.
- Minor hero wording and spacing, as long as the result stays action-first and visually consistent with the existing design system.

</decisions>

<specifics>
## Specific Ideas

- `docs/levain-prd-v2-multi-fermentations.md` sections 8.1 and 9.1-9.4 plus `docs/levain-prd-v2-addendum.md` A1, A2, and A9 are the source of truth for this phase.
- Oggi examples to preserve: bread step with explicit current phase, starter reminder with due-state language, and kefir batch card with storage/routine-aware urgency once Phase 19 plugs in real data.
- The view should keep the current action-first discipline: one obvious action, minimal summary chrome, and no passive dashboard metrics competing with the feed.

</specifics>

<deferred>
## Deferred Ideas

- Persisted kefir batch model, batch detail, storage-aware reminder defaults, and SwiftData-backed kefir agenda items — Phase 19
- Kefir lineage, structured event journal, and archive/journal UI — Phase 20
- Culture/grain tracking and kefir-aware Knowledge filters/tips — Phase 21

</deferred>

---
*Phase: 18-oggi-cross-domain-agenda*
*Context gathered: 2026-03-29*
