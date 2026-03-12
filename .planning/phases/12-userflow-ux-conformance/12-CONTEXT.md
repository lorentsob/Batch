# Phase 12: Userflow & UX Conformance - Context

**Gathered:** 2026-03-12
**Status:** Executed, awaiting manual UAT

<domain>
## Phase Boundary

Phase 12 aligns the app, repository docs, and verification artifacts to the six operational flows defined in the updated userflow v2. Scope is intentionally limited to flow conformance and UX trust: Today state semantics, bake creation and execution behavior, window-based step handling, starter refresh speed, and notification fallback behavior.

</domain>

<decisions>
## Implementation Decisions

### Source of truth
- `/Users/lorentso/Downloads/levain-user-flows-v2.html` is the external reference for this phase.
- `docs/levain-user-flows.md` is the repository-maintained source of truth and must mirror the HTML v2 semantics.
- Phase 12 planning artifacts live only under `.planning/phases/12-userflow-ux-conformance/`.

### Today semantics
- Today exposes explicit states: `firstLaunch`, `allClear`, `futureOnly`, and actionable agenda.
- Starter urgency is split between overdue and due-today instead of one generic reminder style.
- Future work beyond tomorrow is intentionally hidden from Today.

### Bake creation and execution
- Bake name is optional; recipe name fallback remains owned by `BakeScheduler.generateBake`.
- `create-then-edit` remains the official bake-creation behavior.
- Bake execution is sequential by default; out-of-order start requires confirmation and persists `Fuori ordine`.

### Window-based and notification behavior
- `proof` and `coldRetard` derive urgency from `flexibleWindowStart` / `flexibleWindowEnd`.
- Notification routing validates live entities before navigation and uses non-blocking feedback on fallback paths.
- A denied-notifications state must surface feedback without blocking Home or the rest of the app.

</decisions>

<specifics>
## Specific Ideas

- Today should feel prescriptive but not noisy.
- Template recipes must remain available even for a first-time user.
- Window-based fermentation needs a gradual urgency curve instead of a hard late threshold.
- Starter refresh should stay a "2 tap / under 30 seconds" operation.

</specifics>

<deferred>
## Deferred Ideas

- Reworking the entire notification payload model around a new typed routing object
- Additional automation for on-device UAT execution
- UX changes outside the six flow boundaries, even if discovered during this pass

</deferred>

---

*Phase: 12-userflow-ux-conformance*  
*Context gathered: 2026-03-12*
