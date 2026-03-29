# Levain

## What This Is

Levain is a native iPhone-only planner operativo and lightweight journal for domestic fermentations. It keeps the next action obvious, preserves continuity for living preparations over time, and keeps practical knowledge close to the workflow without turning into a noisy recipe database. The v2 milestone extends the current bread/starter product to include milk kefir inside a shared, scalable shell.

## Core Value

The app must make the next fermentation action obvious without adding setup, infrastructure, or workflow friction.

## Requirements

### Validated

- ✓ Bread workflow foundations shipped: reusable formulas, bake creation, step execution, timeline shifting, and action-first Today flows — phases 2-5
- ✓ Starter management shipped: starter CRUD, refresh logging, due-state reminders, and fast Today refresh flow — phases 6, 10, 13
- ✓ Knowledge shipped as bundled local content with lightweight browsing and contextual surfacing — phase 7
- ✓ Notification routing and urgency semantics were hardened around safe fallbacks and real operational flows — phases 11-13
- ✓ The current light-only design system, empty-state approach, and bread detail interaction model are stable enough to reuse — phases 10, 14, 16
- ✓ Local-first persistence, explicit schema versioning, bundled system formulas, and manual backup/restore foundations exist for future extensions — phase 15

### Active

- [ ] Shared top-level shell with `Oggi`, `Preparazioni`, and `Knowledge`, plus always-visible quick actions in `Preparazioni`
- [ ] Preparations hub with a bread sub-hub that preserves current `Impasti`, `Starter`, and `Formule` flows through reused views and components
- [ ] Milk kefir vertical centered on batch management, storage-aware routine handling, and local reminders
- [ ] Cross-domain `Oggi` aggregation for bread, starter, and kefir tasks with all active objects visible, urgency communicated on the card, and direct object navigation
- [ ] Lightweight kefir lineage/journal that supports operational decisions instead of replacing them
- [ ] Optional culture/grain tracking plus cross-domain knowledge filters and contextual kefir guidance

### Out of Scope

- Water kefir, advanced secondary fermentations, or kefir recipe features — explicitly excluded from the v2 PRD
- Generic all-fermentations abstraction layer — would blur mental models and overcomplicate the current Apple-native architecture
- Backend, auth, sync, or multi-device support — the product stays offline-first and personal
- AI-generated advice, social/community features, or analytics-heavy dashboards — not aligned with the operational core
- iPad support — iPhone-only remains the validation target

## Context

- Archived v1 planning baseline lives in `.planning/milestones/v1-roadmap.md`, `.planning/milestones/v1-requirements.md`, and `.planning/milestones/v1-state.md`
- Source of truth for v2 scope and UX is `docs/levain-prd-v2-multi-fermentations.md` plus `docs/levain-prd-v2-addendum.md`
- The current codebase already has reusable bread/starter flows and stable foundations in `Levain/Features/Bakes`, `Levain/Features/Starter`, `Levain/Features/Today`, `Levain/App`, and `Levain/DesignSystem`
- The v2 work must extend `RootTabView`, `AppRouter`, `TodayAgendaBuilder`, `NotificationService`, `KnowledgeLoader`, and related feature areas instead of creating parallel shell logic
- User-facing copy remains Italian-first while code identifiers stay English

## Constraints

- **Platform**: iPhone only, iOS 26 minimum — keeps the UX and testing surface narrow
- **Architecture**: SwiftUI + SwiftData + UserNotifications + local JSON — preserve the current Apple-native, offline-first stack
- **Reuse**: New UI must reuse existing design-system tokens, shared components, route handling, and analogous service logic wherever possible — consistency and delivery speed matter more than novelty
- **Domain Modeling**: Bread and kefir share shell/infrastructure but keep domain-specific models and services — no universal fermentation state machine
- **Validation**: Manual device UAT residuals from v1 stay archived as historical risk; v2 planning assumes the current codebase is stable enough to extend

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| The v2 shell uses `Oggi`, `Preparazioni`, and `Knowledge` as the only top-level tabs | Scales the product beyond bread without adding arbitrary new tabs | — Pending |
| Pane e lievito madre stays internally split into `Impasti`, `Starter`, and `Formule` inside Preparazioni | Preserves the current UX strengths and enables direct reuse of existing flows | — Pending |
| Milk kefir is modeled batch-first; culture is secondary and journal is supportive | Matches the real workflow and avoids a culture-centric product | — Pending |
| Storage mode is a primary kefir variable affecting state, copy, and reminders | Fridge/freezer are normal usage modes, not edge cases | — Pending |
| Oggi keeps a uniform operational card grammar with explicit domain cues | Home must stay action-first even after becoming cross-domain | — Pending |
| New v2 UI reuses the current `Theme`, design-system components, router conventions, and service patterns | Keeps the product visually coherent and avoids parallel logic | — Pending |
| Oggi is a daily operational dashboard of all active objects, not a fixed-section to-do board | Real use needs visibility of everything alive, with urgency shown on the card instead of rigid buckets | — Pending |
| Oggi cards deep-link directly to the underlying bake, starter, or kefir batch | Operational taps must bypass exploratory hierarchy to avoid bread-first regressions | — Pending |
| Preparazioni quick actions are always visible and hub cards never disappear when empty | The root must support immediate creation while keeping both domains present and legible | — Pending |
| The v1 → v2 schema migration is additive and prepared before kefir models land | Shell changes and future model additions must not risk existing local data | — Pending |
| Structured journal remains kefir-only; bread keeps using the current bake history | The product intentionally accepts domain asymmetry instead of forcing a fake unified journal model | — Pending |
| Product and AI context naming must use `Levain` consistently | Prevents drift in planning, copy, and code review | ✓ Good |
| Window-based bake steps use `flexibleWindowStart` / `flexibleWindowEnd` for urgency instead of `plannedEnd` | Window-based bread flows remain a stable operational baseline to preserve | ✓ Good |
| Persistent bootstrap must never auto-delete the on-disk store as an error recovery path | Silent local data loss is worse than temporary in-memory fallback | ✓ Good |
| System knowledge and system formulas stay bundled JSON, while demo seed remains launch-option-only | Bundled content must stay deterministic and separate from user data | ✓ Good |

---
*Last updated: 2026-03-29 after archiving the v1 planning baseline and opening the v2 milestone*
