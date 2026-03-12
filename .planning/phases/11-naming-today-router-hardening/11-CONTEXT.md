# Phase 11: Naming, Today Semantics & Router Hardening - Context

**Gathered:** 2026-03-12
**Status:** Executed

<domain>
## Phase Boundary

Phase 11 closes three residual UAT gaps without changing the app architecture: product naming drift across docs and AI context, Today urgency semantics for starter and tomorrow work, and deep-link fallback behavior when notification payloads point to stale entities.

</domain>

<decisions>
## Implementation Decisions

### Naming
- User-facing and AI-facing product naming must be `Levain` everywhere in documents and generated target settings.
- Internal code symbols and legacy file names are left untouched unless they are already outdated or user-visible.
- Documentation should reflect the repository truth: the actual bundle identifier in source is `com.lorentso.levain`.

### Today semantics
- Today now distinguishes urgent action from same-day scheduling and tomorrow preview.
- Starter reminders split into two visual weights:
  overdue starter work is urgent; due-today starter work remains actionable but secondary.
- Work beyond tomorrow is explicitly removed from Today to keep the screen operational, not archival.

### Router hardening
- Notification entry must resolve against live SwiftData state before navigating.
- Missing bake or starter IDs fall back to a safe tab root plus toast.
- Stale step IDs, cancelled bakes, and completed bakes still open the surviving bake detail with an informational toast.

</decisions>

<deferred>
## Deferred Ideas

- Rewriting all deep-link entry points around a new payload object
- Broad rename of internal symbol names or bundle identifiers
- New Today sections beyond urgent / scheduled / tomorrow

</deferred>

---

*Phase: 11-naming-today-router-hardening*
*Context gathered: 2026-03-12*
