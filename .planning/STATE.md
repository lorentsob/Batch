# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-14)

**Core value:** The app must make the next baking action obvious without adding setup, infrastructure, or workflow friction.
**Current focus:** MVP chiuso con successo. Regressioni design-system v2.0 risolte e verificate via UAT.

## Current Position

Phase: 14 of 14 (Design System Regression Closure)
Plan: 1 of 1 executed in current phase
Status: ✅ Project Complete — MVP closure and Design System regressions verified
Last activity: 2026-03-14 — Phase 14-01 verificate via UAT (light mode, cancellation flow, timeline)

Progress: [██████████████] 100% (14 of 14 phases complete)

## Performance Metrics

**Velocity:**

- Total plans planned: 40
- Total plans completed: 40
- Average duration: N/A
- Total execution time: N/A

**By Phase:**

| Phase | Plans Completed | Status      |
| ----- | --------------- | ----------- |
| 1     | 3/3             | Complete    |
| 2     | 3/3             | Complete    |
| 3     | 3/3             | Complete    |
| 4     | 3/3             | Complete    |
| 5     | 3/3             | Complete    |
| 6     | 3/3             | Complete    |
| 7     | 3/3             | Complete    |
| 8     | 3/3             | Complete    |
| 9     | 3/3             | Complete    |
| 10    | 3/3             | Complete    |
| 11    | 3/3             | Complete    |
| 12    | 3/3             | Complete    |
| 13    | 3/3             | Complete    |
| 14    | 1/1             | Complete    |

**Recent Trend:**

- Last 5 plans: 12-03 complete, 13-01 complete, 13-02 complete, 13-03 complete, 14-01 complete
- Trend: Phase 14 verificate via UAT; MVP completato al 100% con allineamento design system.

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.  
Recent decisions affecting current work:

- Phase 5 planning: Today should be the operational home screen with explicit priority buckets
- Phase 5 planning: bake reminders derived from persisted bake data and resynced from all bake mutation points
- Phase 5 planning: notification taps, pending URLs, and Today actions converge on one routing model for bake and starter contexts
- Phase 6 planning: starter profile management should be extracted into dedicated list, detail, and editor surfaces instead of remaining inside one monolithic Starter file
- Phase 6 planning: refresh logging must stay fast and data-driven, with due-state derived only from `lastRefresh` and `refreshIntervalDays`
- Phase 6 planning: starter notifications should be preference-aware, but Today visibility for due starter work must remain driven by operational relevance, not by notification enablement
- Phase 7 planning: bundled knowledge must stay JSON-based and offline-first instead of becoming a second persistence system
- Phase 7 planning: the Knowledge tab should remain lightweight, with browsing and reading separated cleanly between root and article detail
- Phase 7 planning: contextual tips in bake and starter flows should stay supportive and secondary, while opening the shared article route
- Phase 8 planning: UI confidence work needs deterministic launch modes so tests are not coupled to automatic seeding, notification prompts, or stale simulator persistence
- Phase 8 planning: first launch should default to useful empty states, while sample data remains an explicit internal-testing path instead of automatic bootstrap behavior
- Phase 8 planning: release readiness must verify relaunch and notification-entry behavior through the existing shared router model, not by adding parallel lifecycle flows
- Phase 9 planning: v1 sign-off must produce a written audit packet with requirement status, evidence, and explicit residual risks instead of relying on local memory
- Phase 9 planning: CI should reuse the existing XcodeGen and `xcodebuild` toolchain on clean macOS runners so hosted validation matches local verification
- Phase 9 planning: CD should stay manual-triggered and secret-backed for MVP, producing controlled release candidates without coupling every push to signing or distribution
- Phase 10 planning: Home should cluster operational work by bake and exclude cancelled bakes entirely instead of surfacing every pending step as a flat list
- Phase 10 planning: Primary navigation should foreground Home, Impasti, and Starter; Ricette and Knowledge move to a secondary access pattern
- Phase 10 planning: user-facing "Formula" terminology becomes "Ricetta", with presets directly reusable for bake creation
- Phase 10 planning: recipe and starter authoring need structured flour multi-select, explicit labels, and yeast-aware recipe configuration
- Phase 10 planning: Phase 10 also owns the unresolved App Icon recognition issue because the asset pipeline is configured but still not resolving correctly in practice
- Phase 11 planning: `Levain` is the only valid product name in markdown and AI context; stale `Lievito` product references must be removed
- Phase 11 planning: Today must split urgent work from scheduled-today work and cap tomorrow preview while hiding anything later
- Phase 11 planning: notification navigation must resolve live entities and degrade to safe tab/detail fallbacks with transient toast feedback
- Phase 12 planning: `docs/levain-user-flows.md` is the repository source of truth for the six operational flows defined in the external HTML v2
- Phase 12 planning: Today must expose explicit empty-state modes (`firstLaunch`, `allClear`, `futureOnly`, `actionable`) instead of inferring everything from `totalCount == 0`
- Phase 12 planning: bake execution is sequential by default, but out-of-order recovery stays available behind explicit confirmation and persistent `Fuori ordine` feedback
- Phase 12 planning: window-based steps derive urgency and overdue state from `flexibleWindowStart` / `flexibleWindowEnd`, not from rigid `plannedEnd`
- Phase 13 planning: manual UAT su device reale è il prerequisito assoluto per chiusura MVP
- Phase 13 planning: Home deve distinguere quattro stati operativi distinti (`firstLaunch`, `allClear`, `futureOnly`, `actionable`) con densità informativa adeguata
- Phase 13 planning: notifiche devono reggere tutti gli scenari compreso fallback su entità mancante o terminale senza crash
- Phase 13 planning: starter refresh deve restare ≤ 2 tap / < 30 secondi
- Phase 13 planning: Phase 13 non aggiunge macro-feature — chiude attriti residui di copy, empty state, micro-UX e fiducia
- Phase 14 planning: il design system v2.0 è light-only a livello app, non solo a livello token
- Phase 14 planning: cancel/delete bake deve usare una conferma bottom-aligned coerente con il design system
- Phase 14 planning: un bake annullato deve apparire terminale e archiviato, mentre il rosso resta per i problemi attivi

### Blockers/Concerns

- Nessun bloccante residuo per il lancio MVP

## Session Continuity

Last session: 2026-03-14
Stopped at: MVP closure complete. Phase 14-01 verified. Design System aligned.
Resume file: .planning/ROADMAP.md
