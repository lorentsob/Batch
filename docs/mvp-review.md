# Levain MVP Review — March 2026

Analysis of the current app state (codebase + screenshots) against the UX spec and PRD.

---

## 1. Home Tab — Empty / Idle State

The Home tab in its first-launch state is static decoration until you create a bake or starter. Even after onboarding, the `firstLaunch` / `allClear` / `futureOnly` states are sparse.

**Suggestions:**

- Show a quick-status summary even when idle — e.g. "Hai X ricette salvate", "Il tuo starter Ciccio è stato rinfrescato 3 giorni fa" — so the screen feels alive.
- Surface contextual knowledge tips on the Home tab. `TipGroupView` is wired into `BakeDetailView` and `StarterDetailView` but never appears on Today. For empty/allClear states, a "Consiglio del giorno" from `knowledge.json` would make the screen useful.
- Show a compact starter health card on Home (name + due state badge + days since refresh) so you don't have to navigate to the Starter tab just to check.

---

## 2. Missing Knowledge Tab

The UX spec defines a **4-tab structure** (Oggi, Impasti, Starter, Knowledge). The current app only shows 3 tabs (Home, Impasti, Starter). Knowledge is accessed via a sheet from the onboarding pill card.

**Problems:**

- Users who already created a bake/starter lose the pill card and have **no discoverable path** to Knowledge (unless they tap a contextual tip in a detail view).
- The UX spec's category filter + search experience is harder to use as a modal sheet vs. a persistent tab.

---

## 3. Bakes Tab — Flat List, No Grouping

The UX spec (§5.1) specifies grouping bakes into **"In corso" / "Pianificati" / "Completati"** sections with a collapsible completed section. The current `BakesView` renders a flat `ForEach(bakes)` with no status grouping. This becomes hard to scan with multiple bakes.

---

## 4. Bake Card Design Mismatch

The UX spec (§3.6) defines `BakeCard` with a **type icon circle**, chevron, and "Prossimo: [step name]" inline preview. The current implementation uses a generic `SectionCard` with `MetricChip` grid. The spec design is more scannable and information-dense.

---

## 5. Date/Time Locale

The "Nuovo bake" screen shows the target date as "Mar 13, 2026 02:45" — English locale (`Mar`). Since the app is Italian-first, the `DatePicker` should respect Italian locale or force `.locale(Locale(identifier: "it_IT"))`.

---

## 6. No Step Preview Before Bake Confirmation

`BakeCreationView.save()` immediately generates steps and navigates to the bake detail. The UX spec (§8.1) and CLAUDE.md mention the user should be able to **edit the resulting schedule before confirming**. There's no step preview before committing.

---

## 7. Starter Card — Missing Inline CTA

The UX spec (§3.5) defines `StarterCard` with a "Rinfresca" PrimaryButton and a "Cronologia" SecondaryButton directly on the card. The current `StarterCardView` only navigates to detail — the quick "Rinfresca" action isn't inline on the list.

---

## 8. Formula Editor — Toolbar Ambiguity

The "Nuova ricetta" screen shows **both** "Edit" and "Chiudi" buttons in the top bar. This is confusing for a creation flow — "Edit" implies the form isn't already editable, and having two dismissal-like buttons is unusual. The spec says: `Annulla | Titolo | Salva`.

---

## 9. No Toast/Banner Feedback

The `ToastBannerView` infrastructure exists in `RootTabView`, and `AppEnvironment.showBanner()` is wired, but it isn't called after key user actions (bake created, starter saved, refresh logged). Surface confirmation — "Bake creato!", "Rinfresco salvato" — would close the feedback loop.

---

## 10. Missing Swipe Actions

No `swipeActions` on bake or starter list items for quick delete/cancel. The only way to cancel a bake is from the detail view's bottom button. For a task-focused tool, swipe-to-cancel or swipe-to-delete is expected.

---

## 11. No Completed Bakes Distinction

Completed bakes remain in the flat list forever with no archival or grouping. The spec's collapsible "Completati" section would help. Consider a count badge and ability to hide old bakes.

---

## 12. Notification Permission Timing

`requestAuthorizationIfNeeded` is called during bootstrap. Best practice: ask **after the user creates their first bake or starter** (when the value is clear), not at launch.

---

## 13. Minor Polish

- **No pull-to-refresh** on any `ScrollView`
- **No haptic feedback** on step Start/Complete actions
- **Tab bar icons** — spec says `sun.max.fill` for Today (code uses `house.fill`); spec says `book.closed.fill` for Knowledge (absent from tab bar)

---

## Priority Matrix

| Priority   | Item                                  | Impact                       |
| ---------- | ------------------------------------- | ---------------------------- |
| **High**   | Home tab richer empty/idle state      | Core screen feels dead       |
| **High**   | Bakes grouped by status               | Usability at scale           |
| **High**   | Knowledge tab accessible from tab bar | Discoverability              |
| **Medium** | Starter quick-refresh CTA on card     | Fewer taps for common action |
| **Medium** | Italian locale for DatePicker         | Consistency                  |
| **Medium** | Toast banners after actions           | User feedback                |
| **Medium** | Step preview before bake confirm      | Confidence in creation       |
| **Low**    | Formula editor toolbar fix            | Polish                       |
| **Low**    | Swipe actions on lists                | Convenience                  |
| **Low**    | Haptics                               | Delight                      |
