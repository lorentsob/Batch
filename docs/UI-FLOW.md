# Levain UI Flow & Navigation Documentation

**Version:** 1.0
**Platform:** iOS Native (iPhone only)

---

## Table of Contents

1. [App Architecture](#app-architecture)
2. [Tab 1: Oggi (Today)](#tab-1-oggi-today)
3. [Tab 2: Impasti (Bakes)](#tab-2-impasti-bakes)
4. [Tab 3: Starter](#tab-3-starter)
5. [Tab 4: Knowledge](#tab-4-knowledge)
6. [Modal Sheets](#modal-sheets)
7. [State Transitions](#state-transitions)
8. [Deep Linking](#deep-linking)

---

## App Architecture

### Entry Point
```
LevainApp.swift (@main)
  ├─ ModelContainer (SwiftData)
  ├─ AppEnvironment (NotificationService, KnowledgeLibrary)
  └─ AppRouter (Navigation coordination)
      └─ RootTabView (4 tabs)
```

### Navigation Pattern

**Root Structure:**
- `TabView` with 4 tabs
- Each tab has its own `NavigationStack`
- **Push navigation** for details (BakeDetail, StarterDetail, KnowledgeArticle)
- **Sheet presentation** for creation flows (NewBake, NewStarter, LogRefresh)
- **Sheet presentation** for step detail/execution

**Navigation Rules:**
- ✅ Push: Viewing existing data
- ✅ Sheet: Creating new data
- ✅ Sheet: Step execution (modal focus required)
- ❌ Never push for creation flows

---

## Tab 1: Oggi (Today)

### Root View: TodayView

**Navigation Bar:**
- **Title:** "Oggi" (Large title)
- **No trailing actions**

**Layout Structure:**
```
ScrollView
  VStack(spacing: 48pt) // xxl between sections

    Section 1: "Da fare"
      ├─ Urgent StepCards (overdue + running)
      └─ Urgent StarterReminderRows (overdue)

    Section 2: "In programma oggi"
      ├─ Scheduled StepCards (today)
      └─ Scheduled StarterReminderRows (due today)

    Section 3: "Domani"
      ├─ Tomorrow preview (max 2 items)
      └─ "+ N altri step" if more

    Empty State: "Tutto fatto per oggi"
      └─ CTA: "Nuovo impasto" → NewBakeSheet
```

### Section: Da Fare

**Content:** Urgent items requiring immediate attention.

**Items:**
1. **Overdue Steps** (status: pending, actualStart < now)
   - Component: `StepCard` with amber styling
   - CTA: "Avvia" (amber background)
   - Badge: "In ritardo"

2. **Running Steps** (status: running)
   - Component: `StepCard` with green styling
   - CTA: "Completa"
   - Badge: "In corso"
   - Shows pulsing indicator

3. **Overdue Starters** (dueState: overdue)
   - Component: `StarterReminderRow` (urgent variant)
   - Card background: errorLight
   - Icon: `exclamationmark.triangle.fill`
   - CTA: "Rinfresca" (error color)

**Behavior:**
- Section only visible if items exist
- Header shows count: "DA FARE (3)"
- Items sorted by urgency (overdue > running)

### Section: In Programma Oggi

**Content:** Items scheduled for today, not yet started.

**Items:**
1. **Today's Pending Steps**
   - Component: `StepCard` (standard)
   - Sorted by plannedStart time
   - CTA: "Avvia"

2. **Starters Due Today**
   - Component: `StarterReminderRow` (scheduled variant)
   - Card background: amber50
   - Icon: `clock.badge.exclamationmark`
   - CTA: "Rinfresca" (outlined, less prominent)

**Behavior:**
- Section visible if items exist
- Header shows count
- Preview: shows all items (no truncation)

### Section: Domani

**Content:** Preview of tomorrow's scheduled steps.

**Items:**
- Tomorrow's steps (max 2 shown)
- Component: `TomorrowPreviewRow` (compact variant)
- If more than 2: shows "+ N altri step"

**Behavior:**
- Collapsed preview (not full StepCards)
- Tap to navigate to Bakes tab?
- Low prominence styling

### Empty State

**Trigger:** No items in any section (all.isEmpty)

**Content:**
```
Icon:        checkmark.circle.fill (56pt, green500)
Title:       "Tutto fatto per oggi"
Description: "Nessuno step attivo. Crea un nuovo impasto o controlla il tuo lievito."
CTA:         PrimaryButton("Nuovo impasto") → NewBakeSheet
```

### User Actions

| Action | Result |
|--------|--------|
| Tap StepCard body | → StepDetailSheet (modal) |
| Tap "Avvia" | Step.start(), actualStart recorded, status → running |
| Tap "Completa" | Step.complete(), actualEnd recorded, status → done |
| Tap "Rinfresca" on starter | → LogRefreshSheet (modal) |
| Tap "Nuovo impasto" | → NewBakeSheet (modal) |

---

## Tab 2: Impasti (Bakes)

### Root View: BakesView

**Navigation Bar:**
- **Title:** "Impasti" (Large title)
- **Trailing:** `+` button → NewBakeSheet

**Layout Structure:**
```
ScrollView
  VStack(spacing: 48pt)

    Section 1: "In corso"
      └─ BakeCards (status: inProgress)

    Section 2: "Pianificati"
      └─ BakeCards (status: planned)

    Section 3: "Completati" (DisclosureGroup)
      └─ BakeCards (status: completed, opacity: 0.7)

    Empty State: "Nessun impasto"
      └─ CTA: "Nuovo impasto" → NewBakeSheet
```

### Section: In Corso

**Filter:** `bake.derivedStatus == .inProgress`

**Derived Status Logic:**
```swift
var derivedStatus: BakeStatus {
    if isCancelled { return .cancelled }

    let hasRunning = steps.contains { $0.status == .running }
    let hasStarted = steps.contains { $0.actualStart != nil }

    if hasRunning || hasStarted { return .inProgress }

    let allDoneOrSkipped = !steps.isEmpty &&
                           steps.allSatisfy { $0.status == .done || $0.status == .skipped }
    if allDoneOrSkipped { return .completed }

    return .planned
}
```

**Content:**
- BakeCard list
- Badge: "In corso" (green background)
- Shows next step preview: "Prossimo: [stepName]"
- Sorted by targetBakeDateTime (soonest first)

### Section: Pianificati

**Filter:** `bake.derivedStatus == .planned`

**Content:**
- BakeCard list
- Badge: "Pianificato" (amber background)
- No next step preview
- Sorted by targetBakeDateTime

### Section: Completati

**Filter:** `bake.derivedStatus == .completed`

**Content:**
- Collapsible `DisclosureGroup`
- BakeCard list with opacity: 0.7
- Badge: "Completato" (light green)
- Sorted by targetBakeDateTime (most recent first)

### Empty State

**Trigger:** No bakes exist (allBakes.isEmpty)

**Content:**
```
Icon:        fork.knife (48pt, textTertiary)
Title:       "Nessun impasto"
Description: "Crea il tuo primo impasto scegliendo una formula e impostando l'orario di cottura."
CTA:         PrimaryButton("Nuovo impasto") → NewBakeSheet
```

### Detail View: BakeDetailView

**Navigation:** Push from BakeCard tap

**Navigation Bar:**
- **Title:** bake.name (Inline, scrolls up)
- **No trailing actions**

**Layout Structure:**
```
ScrollView
  VStack(spacing: 32pt) // xl

    BakeHeaderCard
      ├─ Type + Name
      ├─ Status Badge
      ├─ Divider
      └─ Metrics Grid (2x2)
          ├─ Cottura: [datetime]
          ├─ Farina: [weight]g
          ├─ Idratazione: [percent]%
          └─ Porzioni: [count]

    Section: "Timeline"
      └─ StepRowCompact list
          └─ Vertical timeline with dots

    Actions (if not cancelled/completed)
      └─ DestructiveButton("Annulla impasto")
```

### BakeHeaderCard

**Component:** Custom card with metrics grid

**Structure:**
```
VStack(spacing: 8pt)
  HStack
    VStack(alignment: .leading)
      Text(type.title)      // Caption1 Semibold, textTertiary, UPPERCASE
      Text(name)            // Title2, textPrimary
    Spacer
    BakeStatusBadge

  Divider

  HStack(spacing: 16pt) // md
    MetricItem("Cottura", dateTime)
    MetricItem("Farina", "\(flour)g")
    MetricItem("Idratazione", "\(hydration)%")
    MetricItem("Porzioni", "\(servings)")
```

### Timeline Section

**Component:** `StepRowCompact` in VStack

**Layout:**
```
HStack(alignment: .top)

  VStack(width: 56pt, trailing)
    Text(time)        // Caption1 Semibold
    Text(date)        // Caption2 if != today

  VStack
    Circle(10pt, color: statusColor)
    Rectangle(width: 2pt, color: border)
      .frame(maxHeight: .infinity)

  VStack(alignment: .leading)
    Text(stepName)    // Subheadline Semibold
    Text(duration)    // Caption1
    StateBadge        // if running or overdue
```

**Dot Colors:**
- pending (future): neutral200
- pending (overdue): error
- running: green500
- done: green600
- skipped: neutral400

### User Actions

| Action | Result |
|--------|--------|
| Tap BakeCard | → BakeDetailView (push) |
| Tap "+" in nav bar | → NewBakeSheet (modal) |
| Tap StepRowCompact | → StepDetailSheet (modal) |
| Tap "Annulla impasto" | Confirm alert → set isCancelled = true |

---

## Tab 3: Starter

### Root View: StarterView

**Navigation Bar:**
- **Title:** "Starter" (Large title)
- **Trailing:** `+` button → NewStarterSheet

**Layout Structure:**
```
ScrollView
  VStack(spacing: 8pt) // sm between cards

    ForEach(starters)
      StarterCard

    Empty State: "Nessun lievito madre"
      └─ CTA: "Aggiungi lievito" → NewStarterSheet
```

### StarterCard States

**Due State Logic:**
```swift
var dueState: StarterDueState {
    guard let lastRefresh else { return .overdue }

    let dueDate = Calendar.current.date(
        byAdding: .day,
        value: refreshIntervalDays,
        to: lastRefresh
    )

    if Calendar.current.isDateInToday(dueDate) { return .dueToday }
    if dueDate < Date() { return .overdue }
    return .ok
}
```

**Visual Variants:**

| State | Background | Icon | Color | CTA Style |
|-------|------------|------|-------|-----------|
| `.ok` | surface | checkmark.circle.fill | green500 | Secondary |
| `.dueToday` | amber50 | clock.badge.exclamationmark | amber | Primary (amber) |
| `.overdue` | errorLight | exclamationmark.triangle.fill | error | Primary (error) |

### Empty State

**Trigger:** starters.isEmpty

**Content:**
```
Icon:        drop.fill (48pt, textTertiary)
Title:       "Nessun lievito madre"
Description: "Aggiungi il tuo primo lievito per tracciare i rinfreschi e ricevere promemoria."
CTA:         PrimaryButton("Aggiungi lievito") → NewStarterSheet
```

### Detail View: StarterDetailView

**Navigation:** Push from StarterCard tap (on card body, not button)

**Navigation Bar:**
- **Title:** starter.name (Inline)

**Layout Structure:**
```
ScrollView
  VStack(spacing: 32pt)

    StarterDetailHeader
      ├─ Current state badge
      ├─ Type, hydration, storage
      ├─ Last refresh date
      └─ Next due date

    Section: "Rinfreschi recenti"
      └─ RefreshHistoryRow list
          └─ Date, ratio, weights

    DisclosureGroup: "Impostazioni"
      └─ StarterSettingsForm
          └─ Editable properties

    PrimaryButton("Rinfresca ora")
      → LogRefreshSheet
```

### RefreshHistoryRow

**Structure:**
```
HStack
  VStack(alignment: .leading)
    Text(dateTime)        // Subheadline Semibold
    Text(ratioText)       // Footnote, e.g., "1:2:2"

  Spacer

  VStack(alignment: .trailing)
    Text("\(flour)g farina")     // Footnote
    Text("\(water)g acqua")      // Footnote
```

**Sorting:** Most recent first (by dateTime DESC)

### User Actions

| Action | Result |
|--------|--------|
| Tap StarterCard body | → StarterDetailView (push) |
| Tap "Rinfresca" on card | → LogRefreshSheet (modal) |
| Tap "Cronologia" | → StarterDetailView (push) |
| Tap "Rinfresca ora" in detail | → LogRefreshSheet (modal) |
| Tap "+" in nav bar | → NewStarterSheet (modal) |

---

## Tab 4: Knowledge

### Root View: KnowledgeView

**Navigation Bar:**
- **Title:** "Knowledge" (Large title)
- **Search bar:** `.searchable(text: $query)`

**Layout Structure:**
```
ScrollView
  VStack(spacing: 32pt)

    ScrollView(.horizontal)
      CategoryPill list
        ├─ "Tutti" (all)
        └─ ForEach(KnowledgeCategory.allCases)

    VStack(spacing: 8pt)
      ForEach(filteredItems)
        KnowledgeRow
```

### Category Filter

**Component:** Horizontal scrolling pill selector

**Pills:**
- "Tutti" (selectedCategory == nil)
- Each KnowledgeCategory enum case

**Styling:**
```
Selected:
  Background: green500
  Foreground: neutral0

Unselected:
  Background: surface
  Foreground: textSecondary
  Border: neutral200, 1pt

Corner Radius: full (9999pt)
Padding: 16pt horizontal, 8pt vertical
```

### KnowledgeRow

**Structure:**
```
VStack(alignment: .leading, spacing: 8pt)
  HStack
    Text(category.title)           // Overline, textTertiary
    Spacer
    Image("chevron.right")         // 11pt

  Text(title)                      // Headline, textPrimary
  Text(summary)                    // Footnote, textSecondary, lineLimit: 2
```

**Tap:** → KnowledgeArticleView (push)

### Detail View: KnowledgeArticleView

**Navigation:** Push from KnowledgeRow tap

**Navigation Bar:**
- **Title:** "" (empty, title in content)

**Layout Structure:**
```
ScrollView
  VStack(alignment: .leading, spacing: 32pt)

    VStack(alignment: .leading, spacing: 8pt)
      Text(category.title)    // Overline, textTertiary
      Text(title)             // Large Title, textPrimary

    Text(content)
      .font(.body)
      .lineSpacing(6)

    ScrollView(.horizontal)
      HStack
        ForEach(tags)
          Text("#\(tag)")      // Caption1, pill style
```

### User Actions

| Action | Result |
|--------|--------|
| Tap category pill | Filter articles by category |
| Type in search bar | Filter articles by query (title + content + tags) |
| Tap KnowledgeRow | → KnowledgeArticleView (push) |

---

## Modal Sheets

All sheets use:
- `presentationDetents([.large])`
- `presentationDragIndicator(.visible)`
- Standard header: Cancel / Title / Save(or Create)

### 1. NewBakeSheet

**Presentation:** From BakesView "+" or Today empty state

**Header:**
- Cancel button (left, textSecondary)
- "Nuovo impasto" (center, Headline)
- "Crea" button (right, green600 bold, disabled until valid)

**Required Fields:**
- Name (FormField)
- Type (SegmentedPicker: BakeType)
- Formula (Picker → formula list)
- Target DateTime (DatePicker with date + time)

**Optional Section (Collapsible):**
- Starter (Picker → starter list or "Nessuno")

**Advanced Section (Collapsed by default):**
- Inoculazione % (NumericField)
- Farina totale (NumericField)
- Acqua totale (NumericField)
- Porzioni (NumericField)
- Note (TextEditor)

**Validation:**
- Name: not empty
- Formula: selected
- TargetDateTime: in future (optional warning if past)

**On Save:**
1. Create Bake record
2. BakeScheduler generates steps from formula
3. Dismiss sheet
4. Navigate to BakeDetailView (via AppRouter)

### 2. NewStarterSheet

**Presentation:** From StarterView "+"

**Header:**
- Cancel / "Nuovo lievito" / "Aggiungi"

**Required Fields:**
- Name (FormField)
- Type (SegmentedPicker: StarterType)
- Idratazione (Slider: 50-200%)
- Rinfresco ogni (Stepper: 1-30 giorni)
- Conservazione (SegmentedPicker: StorageMode)

**Optional Fields:**
- Toggle: "Promemoria rinfresco" (default: true)

**Advanced Section (Collapsible):**
- Mix di farine (FormField, text)
- Peso contenitore (NumericField, grams)
- Note (TextEditor)

**On Save:**
1. Create Starter record
2. If remindersEnabled: schedule notification
3. Dismiss sheet
4. Navigate to StarterDetailView (optional)

### 3. LogRefreshSheet

**Presentation:** From StarterCard "Rinfresca" or StarterDetail "Rinfresca ora"

**Header:**
- Cancel / "Rinfresca [starter.name]" / "Salva rinfresco"

**Fields:**
- Data e ora (DatePicker, default: now)
- Ratio 3-field HStack:
  - Starter (g) : Farina (g) : Acqua (g)
  - Preview below: "Ratio: 1 : 2 : 2"
- Messa in frigo (DatePicker, optional, nullable)

**Advanced Section (Collapsible):**
- Temperatura ambiente (NumericField, °C, optional)
- Note (TextEditor)

**Validation:**
- All weights > 0
- DateTime not in future

**On Save:**
1. Create StarterRefresh record
2. Update starter.lastRefresh = dateTime
3. Reschedule notifications
4. Dismiss sheet

### 4. StepDetailSheet

**Presentation:** Tap StepCard or StepRowCompact

**Header:**
- Dismiss button (X or drag down)
- Step name (Headline)

**Sections:**

1. **StepDetailHeader** (info card)
   - Type, name, description
   - Metrics: Inizio, Durata, Fine prevista

2. **Esecuzione** (execution controls)
   - Varies by status:
     - `.pending`: "Avvia" + "Salta"
     - `.running`: actualStart time + "Completa" + "Salta"
     - `.done`/`.skipped`: Status icon + timestamp, no CTAs

3. **Sposta timeline** (if not terminal)
   - Preset buttons: +15min, +30min, +1h, Custom
   - Grid layout 2x2
   - Warning: "Tutti gli step futuri non completati verranno spostati."

4. **Dettagli avanzati** (DisclosureGroup, collapsed)
   - Temperature range
   - Volume target
   - Notes
   - Photo (future)

**Terminal Steps:** Last step in bake (usually .baking)
- Cannot shift timeline (no future steps)
- Section hidden

**Timeline Shift Behavior:**
1. User selects preset or custom minutes
2. All future non-terminal steps: `plannedStart += shiftMinutes`
3. `NotificationService` reschedules all affected notifications
4. UI updates immediately

---

## State Transitions

### Step Status Flow

```
[Created] → pending
    ↓
    ├─ User taps "Avvia" → running (actualStart = now)
    │   ↓
    │   ├─ User taps "Completa" → done (actualEnd = now)
    │   └─ User taps "Salta" → skipped (actualEnd = now)
    │
    └─ User taps "Salta" → skipped (actualEnd = now)

Terminal states: done, skipped
```

**No Auto-Completion:**
- Steps never auto-complete when time expires
- "Overdue" is a derived UI label (plannedStart < now && status == pending)
- User must manually tap "Avvia" or "Completa"

### Bake Status Flow

```
[Created] → planned
    ↓
    ├─ Any step.actualStart != nil → inProgress
    │   ↓
    │   ├─ All steps done/skipped → completed
    │   └─ User cancels → cancelled
    │
    └─ User cancels → cancelled

Derived: No persistent status field, computed from steps
```

### Starter Due State Flow

```
[Refreshed] → ok
    ↓ (time passes)
    ↓
    ├─ dueDate == today → dueToday
    │   ↓ (user logs refresh)
    │   └─ → ok
    │
    └─ dueDate < today → overdue
        ↓ (user logs refresh)
        └─ → ok

Computed from: lastRefresh + refreshIntervalDays
```

---

## Deep Linking

### AppRouter Responsibilities

Handles deep links from:
- Local notification taps
- (Future: URL schemes)

### Notification → Screen Mapping

**Step Reminder Notification:**
```
userInfo: ["bakeId": UUID, "stepId": UUID]
→ Navigate to: StepDetailSheet for that step
```

**Starter Due Notification:**
```
userInfo: ["starterId": UUID]
→ Navigate to: LogRefreshSheet for that starter
```

**Implementation:**
```swift
// In AppRouter
func handleNotificationTap(userInfo: [AnyHashable: Any]) {
    if let bakeId = userInfo["bakeId"] as? UUID,
       let stepId = userInfo["stepId"] as? UUID {
        // 1. Switch to Bakes tab
        // 2. Push BakeDetailView
        // 3. Present StepDetailSheet
    }

    if let starterId = userInfo["starterId"] as? UUID {
        // 1. Switch to Starter tab
        // 2. Present LogRefreshSheet
    }
}
```

---

## Screen Inventory

### Tab 1: Oggi
- ✅ TodayView (root)

### Tab 2: Impasti
- ✅ BakesView (root)
- ✅ BakeDetailView (push)

### Tab 3: Starter
- ✅ StarterView (root)
- ✅ StarterDetailView (push)

### Tab 4: Knowledge
- ✅ KnowledgeView (root)
- ✅ KnowledgeArticleView (push)

### Modals
- ✅ NewBakeSheet
- ✅ NewStarterSheet
- ✅ LogRefreshSheet
- ✅ StepDetailSheet

**Total Screens:** 10
- 4 root views
- 3 detail views (push)
- 4 modal sheets (creation + execution)

---

## Navigation Best Practices

### Do's ✅
- Use large titles for tab root views
- Use inline titles for pushed detail views
- Present sheets for all creation flows
- Use .large detent for sheets
- Show drag indicator on sheets
- Provide clear "Annulla" / "Salva" in sheet headers
- Respect safe area insets
- Use NavigationStack per tab (not deprecated NavigationView)

### Don'ts ❌
- Don't push for creation flows
- Don't use .sheet for detail views
- Don't nest NavigationStacks
- Don't use medium detents (iPhone UI too cramped)
- Don't auto-dismiss sheets on background tap
- Don't use custom navigation bars (use native)
- Don't implement custom tab bar

---

**Document Version:** 1.0
**Last Updated:** 2026-03-13
**Aligned with:** CLAUDE.md, UX-SPEC.md
