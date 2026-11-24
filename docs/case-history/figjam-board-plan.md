# Batch Case History FigJam Board Plan

**Board name:** `Batch - Case History Preparation`

**Goal:** create a working FigJam board that organizes all preparatory product-design material before final screen layout work.

**Board logic:** left to right:
1. frame the project
2. collect research inputs
3. synthesize insights
4. define product structure
5. map flows and states
6. plan final case-study assets

---

## Section 00 - Board Guide

Purpose:
- Orient the case history work.
- Explain what material is still missing.

Content:
- Case study spine
- Source-of-truth list
- Color legend for stickies

Suggested stickies:
- Blue: source/evidence
- Yellow: open question
- Green: validated decision
- Pink: design risk
- Violet: material to create

---

## Section 01 - Product Framing

Purpose:
- Define project, role, constraints, and case-study angle.

Cards:
- Product one-liner
- Role and responsibilities
- Platform and constraints
- Product promise
- Scope / non-scope

Initial content:
- "Operational planner for fermentation workflows"
- "Question: what do I need to do now?"
- "iPhone only, local-first, no backend, no auth, local notifications"
- "Not a recipe manager, not a social app, not an AI assistant"

Outputs:
- Cover copy
- Project summary block
- Constraint matrix

---

## Section 02 - Research Framing

Purpose:
- Make the research approach explicit and honest.

Cards:
- Research approach
- Assumptions
- Target user / proto-persona
- Jobs to be done
- Research questions
- Evidence sources

Outputs:
- Research slide/page copy
- Proto-persona card
- JTBD card
- Research scope note

---

## Section 03 - Domain Workflow Map

Purpose:
- Show that the product comes from the real structure of fermentation.

Materials:
- High-level fermentation journey
- Planned vs actual timing
- Interruptions and adaptations
- Starter maintenance loop
- Knowledge moments

Outputs:
- Journey map
- Service / operational blueprint
- Key pain points along the timeline

---

## Section 04 - Synthesis

Purpose:
- Transform observations into design direction.

Columns:
- Pain points
- Insights
- Opportunities
- How might we
- Product principles

Starter content:
- Static recipes fail during live execution.
- The next action needs visual priority.
- Timing changes must not destroy the original plan.
- Starter is a supporting workflow, not the product center.
- Contextual knowledge is more useful than encyclopedic browsing.

Outputs:
- Insight cards
- Opportunity matrix
- Product principles

---

## Section 05 - Product Strategy And Scope

Purpose:
- Show product decision-making.

Cards:
- MVP scope
- Out of scope
- Trade-offs
- Prioritization
- Requirements map

Outputs:
- Scope map
- Prioritization matrix
- Product decision log

---

## Section 06 - Information Architecture

Purpose:
- Prepare the IA artifact for the case history.

Maps:
- Root navigation
- Object model
- Content model
- Knowledge taxonomy

Canonical structure:
- Oggi
- Impasti
- Starter
- Knowledge

Object chain:
- RecipeFormula -> Bake -> BakeStep
- Starter -> StarterRefresh
- KnowledgeItem -> relatedStepTypes / relatedStarterStates

Outputs:
- IA diagram
- Object model diagram
- Content taxonomy

---

## Section 07 - Core User Flows

Purpose:
- Prepare diagram-ready flows.

Flow lanes:
- Today states
- Create new bake
- Execute active bake
- Shift timeline
- Refresh starter
- Notification to deep link

Outputs:
- Flow diagrams
- Edge-case notes
- Screen storyboard requirements

---

## Section 08 - State Models And Edge Cases

Purpose:
- Show product rigor through state logic.

Models:
- Bake derived status
- Step status
- Today state matrix
- Window-based step urgency
- Notification fallback routes

Important rules:
- Steps never auto-complete.
- Overdue is derived UI, not persisted status.
- Timeline shifts affect future non-terminal steps.
- Notification payloads must validate live entities.

Outputs:
- State model diagram
- Edge-case matrix
- Interaction rules card

---

## Section 09 - Design System Story

Purpose:
- Connect visual design to product behavior.

Cards:
- Semantic color rules
- Typography and spacing
- Component anatomy
- StepCard states
- Accessibility notes

Canonical semantic system:
- Green = action and plan
- Neutral = past / archived
- Red = problem / destructive

Outputs:
- Design-system explanation
- Component breakdowns
- Screen annotation labels

---

## Section 10 - Iteration And UAT

Purpose:
- Show how the product improved through testing and review.

Columns:
- Finding
- Design change
- Reason
- Evidence
- Portfolio artifact needed

Initial topics:
- Today realignment
- Userflow v2 conformance
- Notification routing hardening
- Design-system regression closure
- Memory durability and content separation

Outputs:
- Before/after story list
- UAT evidence plan
- Decision log

---

## Section 11 - Final Screen Storyboard

Purpose:
- Decide which final screens prove the case.

Screen groups:
- Oggi: first launch, all clear, future only, actionable
- Impasti: planned, active, completed
- Bake detail and step detail
- New bake flow
- Starter refresh flow
- Knowledge contextual article
- Notification fallback / banner

Outputs:
- Screenshot capture checklist
- Screen annotation plan
- Case-study page order

---

## Section 12 - Production Backlog

Purpose:
- Convert the FigJam into a checklist.

Backlog groups:
- Research artifacts
- IA and flows
- Visual/design artifacts
- Screen captures
- Written case history
- Portfolio publishing

Outputs:
- Final production checklist
- Owner/status columns
- Missing evidence list

