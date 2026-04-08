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
- ✓ The v2 shell shipped with `Oggi`, `Preparazioni`, and `Knowledge`, plus always-visible quick actions and a reusable bread hub under Preparazioni — phase 17
- ✓ The v2 additive schema boundary landed before kefir persistence, so later milk-kefir models can extend SwiftData without improvising migration work — phase 17
- ✓ Oggi now uses a single ranked operational feed with shared domain-cued cards, multi-domain empty/future copy, and direct bake/starter routing, while keeping the kefir contract ready for the next phase — phase 18
- ✓ The kefir data-layer foundation now ships with persisted `KefirBatch`, dedicated storage enums, and additive V3 migration coverage — phase 19-01
- ✓ The kefir vertical now ships a live `Preparazioni` card plus real hub/list/detail surfaces that expose storage-aware batch status before editing flows land — phase 19-02
- ✓ The kefir vertical now supports first-batch creation, persisted manage flows, derive-from-batch, and archive from the operational detail path without any culture prerequisite — phase 19-03
- ✓ The kefir core now ships storage-aware local reminders, real `Oggi` participation, and direct notification/tap routing into batch detail — phase 19-04
- ✓ Phase 20-01 now ships additive `KefirEvent` persistence, automatic event capture from core kefir mutations, and readable source/derived lineage context on the kefir list/detail surfaces — phase 20-01
- ✓ Phase 20-02 now ships a real kefir journal/archive reading surface, reusable event-row grammar, recent-history previews on detail, and deterministic seeded journal coverage — phase 20-02
- ✓ Phase 20 is now fully closed: archive browsing, lineage comparison, seeded history scenarios, and stable UI anchors for journal/archive/comparison regression coverage all ship and verify green — phases 20-03 and 20-04
- ✓ Phase 21 is now fully closed: `Today` uses revision-cached operational snapshots, Knowledge/navigation ownership is centralized under the root shell, kefir lineage presentation is shared, persistence bootstrap failures are explicit, fake starter reminder routes are blocked, and the planning/codebase docs match the shipped app — phases 21-01 through 21-03
- ✓ Phase 23 is now fully closed: canonical glossary routing, read-only surface linking, missing-guide editorial coverage, alias-aware search, and cross-surface verification all ship together as one coherent Knowledge system — phases 23-01 through 23-03

### Active

- [ ] Optional culture/grain tracking plus cross-domain knowledge filters and contextual kefir guidance (Phase 22)

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
- Knowledge remains local bundled content, but glossary terms may keep English as the canonical user-facing label when the Italian alternative would be less natural or less consistent with the product

## Constraints

- **Platform**: iPhone only, iOS 26 minimum — keeps the UX and testing surface narrow
- **Architecture**: SwiftUI + SwiftData + UserNotifications + local JSON — preserve the current Apple-native, offline-first stack
- **Reuse**: New UI must reuse existing design-system tokens, shared components, route handling, and analogous service logic wherever possible — consistency and delivery speed matter more than novelty
- **Domain Modeling**: Bread and kefir share shell/infrastructure but keep domain-specific models and services — no universal fermentation state machine
- **Validation**: Manual device UAT residuals from v1 stay archived as historical risk; v2 planning assumes the current codebase is stable enough to extend

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| The v2 shell uses `Oggi`, `Preparazioni`, and `Knowledge` as the only top-level tabs | Scales the product beyond bread without adding arbitrary new tabs | ✓ Good |
| Pane e lievito madre stays internally split into `Impasti`, `Starter`, and `Formule` inside Preparazioni | Preserves the current UX strengths and enables direct reuse of existing flows | ✓ Good |
| Milk kefir is modeled batch-first; culture is secondary and journal is supportive | Matches the real workflow and avoids a culture-centric product | ✓ Good |
| Storage mode is a primary kefir variable affecting state, copy, and reminders | Fridge/freezer are normal usage modes, not edge cases | ✓ Good |
| Oggi keeps a uniform operational card grammar with explicit domain cues | Home must stay action-first even after becoming cross-domain | ✓ Good |
| New v2 UI reuses the current `Theme`, design-system components, router conventions, and service patterns | Keeps the product visually coherent and avoids parallel logic | ✓ Good |
| Oggi is a daily operational dashboard of all active objects, not a fixed-section to-do board | Real use needs visibility of everything alive, with urgency shown on the card instead of rigid buckets | ✓ Good |
| Oggi cards deep-link directly to the underlying bake, starter, or kefir batch | Operational taps must bypass exploratory hierarchy to avoid bread-first regressions | ✓ Good |
| Preparazioni quick actions are always visible and hub cards never disappear when empty | The root must support immediate creation while keeping both domains present and legible | ✓ Good |
| The v1 → v2 schema migration is additive and prepared before kefir models land | Shell changes and future model additions must not risk existing local data | ✓ Good |
| Structured journal remains kefir-only; bread keeps using the current bake history | The product intentionally accepts domain asymmetry instead of forcing a fake unified journal model | ✓ Good |
| Kefir lineage and journal should be automatic-first and typed, not manual diary-first | Keeps history supportive of the operational workflow and aligns with PRD section 16 | ✓ Good |
| Runtime hardening and planning sync land before culture/grain expansion | Phase 20 closeout exposed performance, state-ownership, and stale-memory risks that should be fixed before adding new scope | ✓ Landed in Phase 21 |
| One glossary concept must map to one canonical guide entry with aliases handling Italian/English wording drift | Prevents recipe terminology from bouncing between languages or spawning duplicate guide articles for the same concept | ✓ Approved for Phase 23 planning |
| Read-only recipe and guide text should use one shared glossary-link renderer with capped density and self-link suppression | Keeps inline learning helpful without turning formulas/articles into noisy hyperlink fields | ✓ Landed in Phase 23-02 |
| Knowledge search should reuse the canonical glossary vocabulary and rank exact alias hits ahead of loose content matches | Prevents manual guide lookup from drifting away from the article destinations opened by inline glossary links | ✓ Landed in Phase 23-03 |
| Product and AI context naming must use `Levain` consistently | Prevents drift in planning, copy, and code review | ✓ Good |
| Window-based bake steps use `flexibleWindowStart` / `flexibleWindowEnd` for urgency instead of `plannedEnd` | Window-based bread flows remain a stable operational baseline to preserve | ✓ Good |
| Persistent bootstrap must never auto-delete the on-disk store as an error recovery path | Silent local data loss is worse than temporary in-memory fallback | ✓ Good |
| System knowledge and system formulas stay bundled JSON, while demo seed remains launch-option-only | Bundled content must stay deterministic and separate from user data | ✓ Good |

---
*Last updated: 2026-04-08 after completing Phase 23-03 editorial coverage, alias-aware Knowledge search, and final glossary verification*
