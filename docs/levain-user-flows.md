# Core Operational Flows v2

**Updated:** 2026-03-12  
**Repository source of truth:** this markdown mirrors the archived v2 flow export kept outside the repo, so the app, planning artifacts, and verification all reference the same operational model.

## Index

1. Today Screen
2. Crea Nuovo Bake
3. Esecuzione Bake Attivo
4. Step Overnight / Window-Based
5. Refresh Starter
6. Notifica → Deep Link

## Flow 1 — Today Screen

**Goal:** Today must always answer "cosa devo fare adesso?" without flattening every future item into the same urgency level.

### Decision Tree

1. If no persisted data exists, show the first-launch empty state with three CTAs:
   `Nuovo bake`, `Aggiungi starter`, `Esplora consigli`.
2. If persisted data exists but there is no active bake or starter work for today, show:
   `Tutto libero per oggi` with CTA `Nuovo bake`.
3. If bakes or starters exist but nothing is actionable today, show:
   an informational empty state with preview of the next future action and CTA `Vai a Impasti`.
4. If there is activity today, Today is built in this order:
   - `Da fare` for bake steps that are `running` or `overdue`, plus overdue starters
   - `In programma oggi` for bake steps pending today and starter `dueToday` that are not overdue
   - `Domani` for the next actionable preview only, capped to two items
   - nothing beyond tomorrow

### Priority Rules

- Bake steps always outrank starter work when both are urgent.
- Overdue starter work belongs in `Da fare`.
- Starter work that is due today but not overdue belongs in `In programma oggi`.
- Bakes scheduled beyond tomorrow never appear in Today.

### Today State Matrix

| State | Condition | Today shows |
| --- | --- | --- |
| Primo lancio | No persisted data | Onboarding empty state with 3 CTAs |
| Tutto libero | Persisted data exists, but no task today and no active bake or starter | Operational empty state with `Nuovo bake` |
| Solo futuro | Bakes or starters exist, but no step is relevant today | Informational empty state with future preview and link to Impasti |
| Pianificato | Pending steps today, no overdue work, starter may be `dueToday` | `In programma oggi` with bake cards and compact starter row |
| Urgente | Running or overdue step, and/or overdue starter | `Da fare` with visible primary action |

### Delta vs v1

- The old binary check `Any bakes or starters?` is replaced by four explicit Today modes.
- Starter rows no longer use one visual weight for every state.
- Tomorrow preview is capped and everything beyond tomorrow is intentionally hidden.

## Flow 2 — Crea Nuovo Bake

**Goal:** The user should be able to create a usable bake even with zero saved recipes, and land immediately in the generated bake detail.

### Flow

1. User taps `Nuovo bake`.
2. The app offers saved recipes plus system templates.
   - If no saved recipes exist, system templates are still available.
   - System templates include: `Pane di campagna`, `Pizza napoletana`, `Focaccia classica`.
3. The user selects a recipe.
4. `Nome bake` is optional.
   - Default name: recipe name.
5. The user sets `Target utilizzo`.
6. The user optionally links a starter.
7. On confirmation, `BakeScheduler` generates the timeline backward from target usage time.
8. The app navigates directly to `Bake Detail`.

### Decisions

- There is no preview step between creation and edit.
- `create-then-edit` is the official behavior.
- Template recipes are always available, so the user never lands on an empty picker.
- Bakes beyond tomorrow remain out of Today until they become operationally relevant.

### Delta vs v1

- `target bake date/time` becomes `target usage time`.
- Future bakes do not pollute Today just because they already exist in persistence.

## Flow 3 — Esecuzione Bake Attivo

**Goal:** The app should clearly prescribe the next correct step, while still allowing explicit override when reality diverges from plan.

### Flow

1. User enters `Bake Detail` from Today or the bake list.
2. The app highlights the current step in sequence and exposes the primary action for that step only.
3. For a pending current step:
   - primary action is `Avvia`.
4. For a running step:
   - primary action is `Completa`
   - secondary action can shift the remaining timeline
5. Future steps remain readable but are not primary-action steps by default.
6. Starting a future step requires confirmation:
   - if confirmed, the step starts anyway
   - the step receives a persistent `Fuori ordine` badge
   - intermediate steps remain pending
7. Quick shift is available only for operational steps that are `running` or `overdue`.

### Decisions

- Sequenziale per default, override esplicito.
- `Late` remains a derived UI label only.
- Skipping remains available as a secondary action.
- Rescheduling affects incomplete future steps only and resyncs notifications.

### Delta vs v1

- The UX moved from "out of order allowed" to "explicitly discouraged but supported".
- `Fuori ordine` is persistent feedback, not a transient alert.

## Flow 4 — Step Overnight / Window-Based

**Goal:** Long fermentation windows must behave like real baking windows, not like hard deadlines.

### Scope

- Applies to window-based steps such as `proof` and `coldRetard`.

### Flow

1. User starts a window-based step.
2. The app stores:
   - `flexibleWindowStart`
   - `flexibleWindowEnd`
3. Before `flexibleWindowStart`:
   - Today shows a compact scheduled row
   - the step is not urgent
   - no overdue label appears
4. When `flexibleWindowStart` is reached:
   - a local notification can announce opening of the window
   - the step moves into `Da fare`
   - `Completa` becomes the obvious action
5. While the window is open:
   - the user can still wait
   - the step stays actionable but not late
6. Only after `flexibleWindowEnd`:
   - the UI can show `in ritardo`
   - a soft reminder can announce the closing window

### Decisions

- Overdue for window-based steps is derived from `flexibleWindowEnd`, not `plannedEnd`.
- Urgency escalates gradually:
  compact scheduled row → visible action → overdue + soft reminder.
- The app never blocks completion after the window closes.

### Delta vs v1

- Window-close reminders now exist.
- There is an explicit intermediate state between silent scheduling and overdue urgency.

## Flow 5 — Refresh Starter

**Goal:** Refresh logging must remain the fastest flow in the app.

### Flow

1. User enters refresh from Today or the Starter tab.
2. The default form exposes only three primary fields:
   - Farina
   - Acqua
   - Starter usato
3. Advanced fields stay collapsed by default:
   - temperatura
   - ratio
   - tempo frigo
   - note
4. On save:
   - `lastRefresh` updates
   - next due date recalculates
   - reminders reschedule
5. The Today starter row disappears immediately after save.

### Decisions

- Speed is the primary success criterion.
- The Today entry point must match urgency state:
  urgent starter rows look urgent, scheduled rows stay compact.
- No stale visual residue should remain in Today after saving the refresh.

## Flow 6 — Notifica → Deep Link

**Goal:** Notification entry must be reliable on warm launch and cold launch, and must degrade safely when payload data is stale.

### Payload Contract

- Bake notifications must carry `bakeId` and `stepId`.
- Starter notifications must carry `starterId`.
- The router must validate those IDs against live SwiftData state before navigating.

### Flow

1. A notification fires.
2. If the app is closed, the app cold-launches, initializes SwiftData, and only then resolves the route.
3. If the payload is valid:
   - step reminder opens the bake detail in the bake context
   - window-opening reminder opens the bake detail with the relevant step actionable
   - starter reminder opens Starter for refresh
4. If the payload is stale:
   - missing `bakeId` → open `Impasti` + non-blocking toast
   - missing `stepId` with valid bake → open `Bake Detail` + informational feedback
   - missing `starterId` → open `Starter` + non-blocking toast
   - cancelled or completed bake → open `Bake Detail` + informational banner
5. If notifications are denied at system level:
   - app still opens normally
   - Home stays usable
   - a non-blocking banner suggests enabling notifications

### Decisions

- Fallback feedback is always lightweight and auto-dismissed.
- No invalid payload may leave the user on a silent empty screen.
- Cold launch routing and warm launch routing must share the same entity-validation model.

### Delta vs v1

- v2 explicitly covers missing bake, missing step, missing starter, terminal bakes, cold launch, and notifications denied.
- Silent failure is no longer an acceptable route outcome.
