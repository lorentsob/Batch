# Batch Case History - Product Design Material Structure

**Purpose:** prepare a portfolio-grade case history for Batch that shows product design thinking before final screens: research framing, synthesis, information architecture, flows, interaction logic, iteration, validation, and visual system.

**Product in one line:** Batch is an iPhone-only operational planner for real fermentation work. It is not a recipe archive; it helps answer "what do I need to do now?"

**Recommended story angle:** from ambiguous, real-world baking timing to a focused action-first tool.

---

## 1. Case Study Spine

### 01 - Cover

**Goal:** make the project immediately legible.

Materials to produce:
- Final title: `Batch - Operational planner for fermentation workflows`
- Product thumbnail with 3-5 final screens
- Role, timeframe, platform, scope, and status
- One-sentence outcome

Use this section to establish:
- Personal/internal MVP
- Native iPhone-only app
- Italian-first product
- Product design + implementation collaboration

### 02 - Context and Challenge

**Goal:** explain why the product exists before showing UI.

Materials to produce:
- Context card: sourdough and fermentation are time-sensitive, nonlinear, and often interrupted by real life.
- Problem statement: home bakers do not only need recipes; they need operational guidance while a bake is already in progress.
- Constraints matrix:
  - iPhone only
  - no backend
  - no account
  - no cloud sync
  - local notifications only
  - native iOS patterns
  - minimal setup
- Success criteria:
  - next action is obvious
  - timeline can adapt
  - starter maintenance stays fast
  - knowledge appears when useful

### 03 - Research Framing

**Goal:** show product design rigor even if the project is personal/internal.

Materials to produce:
- Research assumptions and risks
- Domain workflow audit: how fermentation actually behaves over time
- Proto-persona / target user profile
- Jobs-to-be-done
- Research questions
- Competitive and adjacent-product notes
- Evidence log from product docs, UAT, audits, and real usage corrections

Suggested framing:
- Treat the project as practice-led research: direct domain experience, workflow decomposition, internal UAT, and iterative product audits.
- Be explicit that the research is not broad market research; the strength is depth of operational workflow modeling.

### 04 - Synthesis and Opportunity

**Goal:** turn research into design direction.

Materials to produce:
- Pain point clusters
- Insight cards
- Opportunity statements
- "How might we" questions
- Prioritization matrix

Core insights to show:
- The main need is not "store a recipe"; it is "make the next action clear."
- Planned time and actual execution must stay separate.
- Late/overdue is a UI interpretation, not a persisted state.
- Starter work is important but secondary to active bake execution.
- Knowledge must be contextual, not an encyclopedia-first experience.

### 05 - Product Strategy and Scope

**Goal:** make product decisions visible.

Materials to produce:
- Product principles
- MVP scope map
- Out-of-scope list
- Trade-off cards
- Requirement grouping

Key principles:
- Action-first, not dashboard-first
- One primary action per card
- Progressive disclosure for advanced fields
- Derive state from data instead of storing redundant status
- Local-first and offline-capable
- Italian-first for MVP

### 06 - Information Architecture

**Goal:** show how the app is organized conceptually.

Materials to produce:
- App map
- Object model
- Navigation model
- Content model
- Knowledge taxonomy

Recommended IA story:
- Root tabs: Oggi, Impasti, Starter, Knowledge
- Primary operational center: Oggi
- Core object chain: RecipeFormula -> Bake -> BakeStep
- Starter is a supporting maintenance object
- Knowledge is bundled content connected to steps and starter states

### 07 - User Flows and State Logic

**Goal:** show the product's interaction complexity before final UI.

Materials to produce:
- Today state matrix
- Bake creation flow
- Active bake execution flow
- Timeline shift flow
- Starter refresh flow
- Notification deep-link fallback flow
- Step state model

Critical flows:
- First launch / all clear / future only / actionable Today states
- Create bake from system template or saved recipe
- Start, complete, skip, and shift a bake step
- Handle overnight/window-based steps
- Refresh starter in a fast three-field path
- Open from notification with stale payload fallbacks

### 08 - Design System and Interaction Principles

**Goal:** connect visual design choices to behavior.

Materials to produce:
- Semantic color system
- Typography and spacing rules
- Component anatomy
- State badge rules
- StepCard variants
- Accessibility notes

Design-system story:
- Green = action and plan
- Neutral = past or archived
- Red = problem or destructive action
- Light-only, native iOS feel, SF Pro, generous whitespace
- Components are designed around operational clarity, not decoration

### 09 - Iteration and UAT

**Goal:** show design maturity through changes, not just final polish.

Materials to produce:
- Phase timeline
- UAT findings
- Before/after examples
- Decision log
- Regression and trust-repair notes
- Final sign-off checklist

Strong iteration themes:
- Home/Today realignment around "what do I do now?"
- Userflow v2 conformance
- Notification routing hardening
- Design-system regression closure
- Memory durability and system content separation

### 10 - Final Screens and Storyboard

**Goal:** present final screens after the reasoning is already clear.

Materials to produce:
- Screen storyboard
- Final screen set
- Annotated flows
- Interaction notes
- Edge-case states

Screen groups:
- Oggi states
- Impasti list and bake detail
- Bake step detail
- New bake flow
- Starter list, detail, and refresh
- Knowledge browse and article
- Notification entry and fallback feedback

### 11 - Validation and Outcome

**Goal:** make the project measurable.

Materials to produce:
- Requirements coverage matrix
- Build/test/UAT evidence
- Residual risk log
- What changed after testing
- Lessons learned
- Next steps

Outcome framing:
- The MVP became a reliable operational planner with local persistence, local notifications, system templates, bundled knowledge, and explicit state logic.
- Remaining evidence to show honestly: physical-device UAT and real-notification verification when relevant.

---

## 2. Product Designer Deliverables Checklist

### Research

- [ ] Research plan
- [ ] Assumptions map
- [ ] Proto-persona
- [ ] Jobs-to-be-done
- [ ] Domain workflow map
- [ ] Competitive / adjacent audit
- [ ] Research question list
- [ ] Evidence log

### Synthesis

- [ ] Pain point clusters
- [ ] Insight cards
- [ ] Opportunity areas
- [ ] How-might-we questions
- [ ] Prioritization matrix
- [ ] Problem statement

### Structure

- [ ] IA map
- [ ] Object model
- [ ] Navigation model
- [ ] Content taxonomy
- [ ] State model
- [ ] Requirements map

### Flows

- [ ] Today state matrix
- [ ] Bake creation flow
- [ ] Active bake execution flow
- [ ] Timeline shift flow
- [ ] Starter refresh flow
- [ ] Notification entry flow
- [ ] Window-based step flow

### Design

- [ ] Design principles
- [ ] Low-fidelity wireflow
- [ ] Component anatomy
- [ ] Design-system tokens
- [ ] Final screen storyboard
- [ ] Annotated screen set

### Validation

- [ ] UAT plan
- [ ] UAT findings
- [ ] Before/after iteration evidence
- [ ] Traceability matrix
- [ ] Residual risk log
- [ ] Final learnings

---

## 3. Local Sources To Mine

Primary source files:
- `docs/levain-prd-complete-v2.md`
- `docs/UX-SPEC.md`
- `docs/levain-user-flows.md`
- `docs/UI-FLOW.md`
- `docs/DESIGN-SYSTEM.md`
- `.planning/milestones/v1-roadmap.md`
- `.planning/milestones/v1-requirements.md`
- `.planning/milestones/v1-state.md`
- `docs/v1-audit.md`
- `docs/mvp-review.md`
- `.planning/phases/24-figma-design-system-parity/DISCOVERY.md`
- `.planning/phases/24-figma-design-system-parity/24-CONTEXT.md`

Useful app references:
- `Levain/Features/Today/TodayView.swift`
- `Levain/Features/Bakes/BakeCreationView.swift`
- `Levain/Features/Bakes/BakeDetailView.swift`
- `Levain/Features/Bakes/BakeStepDetailView.swift`
- `Levain/Features/Starter/StarterView.swift`
- `Levain/Features/Knowledge/KnowledgeView.swift`
- `Levain/Services/TodayAgendaBuilder.swift`
- `Levain/Services/BakeScheduler.swift`
- `Levain/Services/NotificationService.swift`
- `Levain/DesignSystem/Theme.swift`

---

## 4. Suggested Case Study Page Order

1. Hero: final product promise
2. Context: why fermentation needs an operational tool
3. Challenge: recipes are static, fermentation is live
4. Research approach: workflow-led research and UAT
5. Target user and JTBD
6. Pain points and insights
7. Product strategy and scope boundaries
8. IA and object model
9. Core flows and state logic
10. Design principles and system
11. Iterations from UAT
12. Final screen walkthrough
13. Validation and outcome
14. Reflection and next steps

