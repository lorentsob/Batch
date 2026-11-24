# Batch Final Showcase Plan

**Purpose:** source of truth for turning the current FigJam preparation board and the running iOS app into a polished portfolio case history.

**Status:** updated on 2026-06-03 after reviewing the FigJam board, launching the iOS simulator with the deterministic `operational` seed scenario, checking current source labels, using the provided current Kefico detail screenshot, and confirming the final positioning decisions.

---

## 1. Confirmed Showcase Direction

Batch should be presented as a native iPhone hub for keeping track of fermented products.

The current product covers:

- `Lievito madre` / sourdough starter management.
- `Impasti` and baked-product preparation workflows.
- `Kefir` batch tracking, renewal, chronology, archive, and comparison.
- `Guide` as supporting knowledge content.

The broader product frame is extensible: the same hub could later cover other fermented products such as kombucha, as long as each domain keeps its own operational model and does not become a generic recipe archive.

Core positioning:

> Batch helps you keep track of fermented products by surfacing what needs attention now.

Sharper product angle:

> Static recipes tell you what should happen. Batch tells you what needs attention now across real fermentation routines.

One-line description:

> Batch is an iPhone-only hub for fermented-product routines: lievito madre, baked products, and kefir organized around the next action.

---

## 2. Runtime Truth To Reflect

The current first-level information architecture and the showcase language are Italian:

```text
Oggi
Batch
Guide
```

Do not use `Home / Batch / Guides` in the final case. English may be used for explanatory portfolio copy, but IA labels, screen labels, diagrams, and annotations should use the shipped Italian names.

Current app shell:

- **Oggi:** action-first operational agenda. It answers what needs attention now across kefir, starter, impasti/bakes, and guide support.
- **Batch:** domain hub for `Impasti`, `Starter`, `Kefir`, and `Ricette`.
- **Guide:** bundled knowledge surface with categories, article rows, and bottom search.

Runtime references from simulator and provided screenshot:

- Oggi hero: `Cosa fare oggi`, agenda count, `Nuova preparazione`.
- Oggi actionable sections: domain-grouped cards such as `Kefir`, `Starter`, plus `Guide e consigli`.
- Batch hub: title `Batch`, subtitle `I tuoi batch attivi`, `Nuova preparazione`, tiles for `Impasti`, `Starter`, `Kefir`, `Ricette`.
- Guide: title `Guide`, subtitle `Tutto sulla fermentazione`, category pills, article rows, bottom search `Cerca guide e consigli`.
- Kefir detail example: `Kefico`, overdue state, metric tiles, `Azioni rapide`, primary action `Rinfresca`, secondary actions `Cronologia`, `Confronta`, `Nuovo batch`, `Archivia`, recent history.

---

## 3. Source Evidence

Use these as the evidence base for the showcase:

- Running iOS app in simulator: `Levain` scheme, `iPhone 15 Pro`, seeded `operational` scenario.
- User-provided current Kefico detail screenshot.
- FigJam board: `Batch - Case History Preparation`.
- Current source code labels and routes:
  - `Levain/Features/Shared/RootTabView.swift`
  - `Levain/Features/Today/TodayView.swift`
  - `Levain/Features/Fermentations/FermentationsView.swift`
  - `Levain/Features/Knowledge/KnowledgeView.swift`
  - `Levain/Features/Kefir/KefirBatchDetailView.swift`
- Planning phase evidence:
  - Phase 17: v2 shell and preparation hubs.
  - Phase 18: cross-domain Oggi agenda.
  - Phase 19: milk kefir batch core.
  - Phase 20: kefir lineage, journal, archive, comparison.
  - Phase 24: design-system parity approved as portfolio-ready.

FigJam board material to keep:

- Product framing: operational planner/hub, not recipe manager/social/AI.
- Research framing: practice-led research, workflow decomposition, narrow-sample honesty.
- Domain workflow: planned vs actual timing, interruptions, starter maintenance, kefir renewal/history, knowledge at moment of action.
- Synthesis: next action priority, planned/actual separation, derived status, contextual knowledge.
- Strategy: action-first, one primary action per card, progressive disclosure, local-first.
- State logic: no auto-completion, overdue as derived UI, live entity validation for deep links.
- Design system: semantic green/neutral/red, light-only native iOS, operational card anatomy.
- Iteration/UAT: Oggi too static, knowledge discoverability, flat bakes list, notification trust, design-system regressions, data durability.

FigJam board material to treat as stale or before-state only:

- `Oggi / Impasti / Starter / Knowledge` as root IA.
- `Knowledge` as the current tab/surface name.
- Sourdough-only framing.
- Kefir as a placeholder or only a renewal detail.
- Any final-case structure that reads like a generic recipe-manager showcase.

---

## 4. Product Scope And Constraints

Platform and implementation:

- Native iPhone app.
- SwiftUI UI.
- SwiftData persistence.
- Local notifications.
- Bundled knowledge content.
- Local-first, no backend.
- No authentication.
- No cloud sync.
- Italian-first MVP.
- Personal/internal product, suitable for a practice-led case study.

What Batch is:

- A focused hub for tracking fermented products.
- A way to manage time-sensitive routines across lievito madre, impasti/baked products, and kefir.
- A local app that prioritizes what needs attention now.
- A product architecture that can extend to other fermented products such as kombucha.

What Batch is not:

- Not a generic recipe manager.
- Not a social/community product.
- Not an AI assistant.
- Not a backend/cloud product.
- Not an automatic fermentation controller.
- Not a broad market-validation project.
- Not a generic fermentation abstraction that erases domain-specific behavior.

---

## 5. Final Case Study Spine

### 01 - Hero

Goal: make the product legible in the first viewport as a hub for fermented products.

Show:

- App name: `Batch`.
- Positioning line: hub for tracking fermented-product routines.
- 3 to 5 hero screens: Oggi actionable agenda, Batch hub, Kefico detail, Guide browse, optional new preparation menu.
- Domain coverage signal: lievito madre, impasti/baked products, kefir.
- Extensibility signal: could expand to other fermented products such as kombucha.
- Metadata: iPhone app, SwiftUI, SwiftData, local notifications, Italian-first, local-first, personal/internal MVP.

Recommended copy:

> Batch keeps fermented-product routines visible and actionable, from lievito madre and impasti to kefir batches.

### 02 - Context

Goal: explain why the product exists before UI.

Show:

- Fermented products are time-sensitive, stateful, and often interrupted by real life.
- Recipes describe a plan, but execution needs live prioritization.
- Lievito madre, impasti, baked products, and kefir have different rhythms, but all create operational attention debt.
- The product chooses local reliability and low setup over accounts, sync, and community features.

### 03 - Research Framing

Goal: be honest and rigorous.

Frame the research as practice-led:

- Domain experience.
- Workflow decomposition.
- Product audits.
- UAT/regression passes.
- Deterministic seeded runtime scenarios.

Avoid broad-market claims. The strength of the case is workflow depth, not survey breadth.

### 04 - Synthesis

Goal: turn observations into product decisions.

Insight cards:

- The core question is: what needs attention now?
- Planned time and actual execution must stay separate.
- Overdue is a derived UI interpretation, not a persisted status.
- Fermented-product domains differ, but the agenda model can unify attention.
- Knowledge helps when it supports action, not when it becomes the main product center.
- Operational trust depends on routing, persistence, and notification fallbacks.

### 05 - Product Strategy

Goal: show hard scope choices.

Principles:

- Action-first, not dashboard-first.
- One dominant action per operational card.
- Progressive disclosure for advanced fields and secondary actions.
- Derive state from persisted facts instead of storing redundant computed state.
- Keep domain models specific instead of forcing a generic fermentation abstraction.
- Local-first and offline-capable.
- Italian-first MVP.
- Extensible hub architecture: new fermented products can be added when they have clear operational rules.

Explicit non-scope:

- Backend.
- Cloud sync.
- Accounts/auth.
- Social sharing/community.
- AI suggestions.
- Automatic step completion.
- Analytics-heavy kefir comparison.
- Culture/grain measurement tracking for this milestone.
- Kombucha implementation is not in the current shipped scope.

### 06 - Information Architecture

Goal: show the current app structure and the iteration from the old model.

Current first-level IA:

```text
Oggi
  Agenda
  Actionable domain cards
  Empty / all-clear / future-only states
  New preparation entry
  Guide support card

Batch
  Impasti
    Bakes
    Recipes/Formulas
    Bake detail
    Step detail
    Timeline shift
  Starter
    Starter list/detail
    Refresh flow
  Kefir
    Batch list/detail
    Renew/manage
    Cronologia
    Archivio
    Confronto lineage
  Ricette
    Formula list/detail

Guide
  Browse
  Categories
  Search
  Articles
  Contextual article sheet
```

Iteration note:

- Before: separate root areas for Oggi, Impasti, Starter, Knowledge.
- After: `Oggi / Batch / Guide`, with Batch acting as the fermented-product hub and Oggi acting as the operational agenda.

### 07 - Core Flows

Goal: prove interaction depth without making the showcase feel like a full manual.

Final flow set:

- Oggi agenda: identify due/overdue/next work across domains.
- New preparation: choose impasto, starter, or kefir.
- Bake creation: saved recipe/system recipe to generated timeline.
- Bake execution: start, complete, skip, inspect detail, shift future non-terminal steps.
- Starter refresh: due/overdue, fast refresh, history.
- Kefir renewal: overdue/detail state, refresh, manage, archive.
- Kefir lineage/history: chronology, derive new batch, compare related batches.
- Guide lookup: browse/search, article, contextual support.
- Notification/deep link: validate live entity, route to the right detail, show fallback banner when needed.

### 08 - State Logic

Goal: show rigor behind the simple UI.

Artifacts to produce:

- Oggi priority model: overdue/critical first, today items, active items, future preview.
- Step lifecycle: pending, running, done, skipped.
- Bake derived status: cancelled, completed, in progress, planned.
- Starter due/overdue derivation from last refresh and interval.
- Kefir derived state from last managed date, storage mode, planned reactivation, archive state.
- Kefir event history: typed lifecycle events beside `KefirBatch`.
- Notification sync rules for bake timeline shifts and domain management changes.
- Deep-link fallback matrix for missing entities, terminal objects, and notification-disabled states.

Key rules:

- Steps never auto-complete.
- Overdue is UI meaning, not a persisted status.
- Actual start/end stay separate from planned schedule.
- Timeline shifts affect future non-terminal steps.
- Kefir chronology is automatic-first, not mandatory journaling.
- Archived kefir batches stay readable and derivable.

### 09 - Design System

Goal: connect visual language to behavior.

Semantic system:

- Green = action, plan, active route, current work.
- Neutral = past, archived, secondary, disabled.
- Red = overdue, problem, destructive, high-risk feedback.
- Tinted cards highlight operational focus without turning the UI into a dashboard.

Native visual language:

- Light-only.
- iPhone-only.
- SF Pro.
- Large, readable hierarchy.
- Continuous rounded cards.
- Generous spacing.
- Floating bottom tab bar.
- One primary action visible in the card or action area.

Component anatomy to show:

- Oggi hero card.
- Operational agenda card.
- Batch domain hub tile.
- State badge.
- Kefir detail metric tiles.
- Quick action group.
- Guide row and bottom search.

### 10 - Iteration And UAT

Goal: show design maturity through changes, not just final polish.

Strong before/after themes:

- First-level IA evolved from four separate tabs into `Oggi / Batch / Guide`.
- Oggi became a cross-domain operational agenda, not a passive dashboard.
- Batch became the hub for fermented-product domains: impasti, starter, kefir, ricette.
- Kefir moved from placeholder/core renewal into batch detail, chronology, archive, and comparison.
- Guide became persistent support content with search and categories.
- Notification routing validates live SwiftData entities and falls back visibly.
- Design-system parity/hardening tied color to behavior.
- Persistence and data durability became part of product trust.

Use 3 to 5 before/after examples, not every phase.

### 11 - Final Screens

Goal: present the product after the reasoning is clear.

Use a guided storyboard, not a gallery dump:

1. Oggi actionable agenda.
2. New preparation menu.
3. Batch domain hub.
4. Kefir detail: overdue state and quick actions.
5. Kefir chronology or recent history.
6. Kefir comparison or archive reuse.
7. Starter detail and refresh.
8. Impasti list or bake detail.
9. Step detail and timeline shift.
10. Guide browse/search.
11. Guide article or contextual guide sheet.
12. Oggi all-clear or first-launch state.
13. Notification fallback/banner state if useful.

Hero screen recommendation:

- Use Oggi actionable agenda, Batch hub, Kefico detail, Guide browse, and new preparation menu.
- The hero should sell Batch as the fermented-products hub, not as a kefir-only or sourdough-only app.

### 12 - Validation And Outcome

Goal: close with evidence and honest limits.

Use:

- Build/run evidence from simulator.
- Unit/UI test summaries from planning phases.
- Completed UAT and regression evidence.
- Requirements coverage where useful.
- Residual risks.
- Lessons learned.

Outcome framing:

> Batch reached a reliable local-first hub model for fermented-product routines, with deterministic data, derived state, local notifications, bundled guides, and a visual system tied to operational meaning.

---

## 6. Captured Runtime Assets

Already captured from the real app with seeded operational data:

- `docs/case-history/assets/runtime-01-oggi-actionable.jpg`
- `docs/case-history/assets/runtime-02-batch-hub.jpg`
- `docs/case-history/assets/runtime-03-guide-browse.jpg`
- `docs/case-history/assets/runtime-04-new-preparation-menu.jpg`
- `docs/case-history/assets/runtime-05-kefir-detail.jpg`

Fresh simulator reference checked during this pass:

- Oggi actionable state on `iPhone 15 Pro` simulator with `operational` seed.

Provided external reference:

- Current Kefico detail screenshot showing overdue detail, quick actions, recent history, and bottom nav.

For final portfolio assets, recapture or export high-resolution screens and place them in polished device frames. Do not imply speculative redesign; use shipped app parity.

---

## 7. Final Asset Checklist

### Must-Have Screen Captures

- [x] Oggi actionable state
- [x] Batch domain hub
- [x] Guide browse
- [x] New preparation menu
- [x] Kefir detail
- [ ] Kefir recent history / chronology
- [ ] Kefir comparison
- [ ] Kefir archive / derive-from-archive
- [ ] Starter detail
- [ ] Starter refresh sheet
- [ ] Impasti list
- [ ] Bake detail with step timeline
- [ ] Step detail sheet
- [ ] Shift timeline sheet
- [ ] Bake creation flow
- [ ] Guide article
- [ ] Oggi all-clear state
- [ ] Empty first-launch Oggi state
- [ ] Notification deep-link/fallback banner

### Diagrams

- [ ] Product positioning map: recipe archive vs fermented-products hub.
- [ ] Updated IA map: `Oggi / Batch / Guide`.
- [ ] Object model: `RecipeFormula`, `Bake`, `BakeStep`, `Starter`, `StarterRefresh`, `KefirBatch`, `KefirEvent`, `KnowledgeItem`.
- [ ] Oggi agenda priority model.
- [ ] Bake step execution state diagram.
- [ ] Timeline shift flow.
- [ ] Kefir batch lifecycle and event flow.
- [ ] Extensibility note: how another fermented product such as kombucha could enter the hub.
- [ ] Notification deep-link and fallback flow.

### Written Blocks

- [ ] One-line product promise.
- [ ] Problem statement.
- [ ] Role/scope/timeframe.
- [ ] Constraints matrix.
- [ ] Research approach note.
- [ ] Insight cards.
- [ ] Product principles.
- [ ] IA evolution note.
- [ ] State logic explanation.
- [ ] Extensibility note.
- [ ] Design-system rationale.
- [ ] Iteration before/after notes.
- [ ] Validation and residual risks.
- [ ] Reflection.

### Visual Production

- [ ] Device-frame compositions.
- [ ] Annotated screen callouts.
- [ ] Final 3 to 5 hero screens.
- [ ] Flow diagram visual style.
- [ ] Case-study thumbnail.
- [ ] Social preview crop.
- [ ] Portfolio page cover image.

---

## 8. Recommended Portfolio Page Order

1. Hero: Batch as the fermented-products hub.
2. The problem: fermented products need live attention, not static recipe screens.
3. Constraints: local-first, native iPhone, no backend.
4. Research approach: practice-led workflow modeling.
5. Key insight: the next action matters more than the recipe archive.
6. Product strategy: action-first, derived state, progressive disclosure, extensible domain hub.
7. IA evolution: from separate tabs to `Oggi / Batch / Guide`.
8. Core flows: create, execute, shift, renew, compare, learn.
9. State logic: why simple UI required careful modeling.
10. Design system: semantic color and operational cards.
11. Iterations: what changed through audits/UAT.
12. Final screens: guided storyboard.
13. Validation: build, tests, UAT evidence.
14. Reflection: what the project taught and what could extend next.

---

## 9. FigJam Board Refinement Plan

The board is readable and should be treated as a preparation canvas, not the published case itself.

Update the board in this order:

1. **Board Guide**
   - Mark this document as the current source of truth.
   - Add source statuses: runtime verified, board-derived, stale/before-state, needs capture.

2. **Product Framing**
   - Replace sourdough-only framing with fermented-products hub.
   - Keep `not a recipe manager` as the sharp positioning line.
   - Add the current coverage: lievito madre, impasti/baked products, kefir.
   - Add extensibility note: future domains like kombucha are plausible if modeled around attention and state.

3. **Research Framing**
   - Keep practice-led research and narrow-sample honesty.
   - Add simulator/runtime capture evidence and planning phase evidence.

4. **Domain Workflow Map**
   - Split into starter maintenance, impasti/baked-product preparation, kefir renewal/history.
   - Add one shared lane: Oggi agenda prioritization.

5. **Synthesis**
   - Add cross-domain insight: different fermented products share the same operational attention need.

6. **Product Strategy And Scope**
   - Add `Oggi / Batch / Guide` as the major product-shell decision.
   - Preserve local-first constraints.
   - Mark kombucha as future extension, not current shipped scope.

7. **Information Architecture**
   - Update final IA to `Oggi / Batch / Guide`.
   - Keep old `Oggi / Impasti / Starter / Knowledge` only as before-state/iteration evidence.

8. **Core User Flows**
   - Add new preparation selector.
   - Add kefir chronology, archive, and comparison flows.
   - Keep bake execution and timeline shift flows.

9. **State Models**
   - Add kefir event history and archive/read/derive behavior.
   - Add cross-domain Oggi agenda ordering.

10. **Design System Story**
    - Use runtime screenshots to annotate color semantics and card anatomy.
    - Add the Kefico detail as proof of red/green/neutral semantics in one screen.

11. **Final Screen Storyboard**
    - Replace planned screen groups with the current storyboard in section 5.11.

12. **Production Backlog**
    - Turn missing captures and diagrams into owner/status checklist.

---

## 10. Confirmed Decisions

- Final IA labels are Italian: `Oggi / Batch / Guide`.
- UAT is completed.
- The hero and overall showcase focus on Batch as a hub for tracking fermented products.
- Current product coverage: sourdough/lievito madre, baked products/impasti, kefir.
- Future extensibility: domains like kombucha can be added later, but are not current shipped scope.
