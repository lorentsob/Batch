---
status: code-audit-complete
phase: 13-mvp-closure
source: 13-01-PLAN.md
started: 2026-03-12
updated: 2026-03-12
note: UAT via analisi statica del codice — UAT su device fisico da eseguire prima del rilascio.
---

## Checklist UAT su iPhone Reale

Eseguire su device fisico. Annotare pass/fail e note per ogni check.

---

### 1. Apertura e Home

- [x] Apertura app a freddo senza crash o schermate incoerenti — SplashView + bootstrap asincrono robusto
- [x] Home nel stato `firstLaunch` (nessun dato): `TodayOnboardingView` con CTA nuovo bake, aggiungi starter, esplora guide ✓
- [x] Home nel stato `allClear`: `TodayAllClearView` con icona checkmark verde — non sembra rotta ✓
- [x] Home nel stato `futureOnly`: `TodayFuturePreviewCard` mostra titolo, sottotitolo e CTA ✓
- [x] Home nel stato `actionable`: sezioni urgente/programmato/domani con badge conteggio ✓
- [x] Riapertura da background: stato derivato da SwiftData, sempre coerente ✓

---

### 2. Creazione bake

- [x] CTA "Nuovo bake" accessibile dalla Home (tab bakes) e dalla toolbar Impasti ✓
- [x] Template di sistema disponibili via `RecipeTemplates` anche senza ricette salvate ✓
- [x] Nome bake opzionale: fallback su `formula.name` in `BakeScheduler.createBake` ✓
- [x] `targetBakeDateTime` impostabile con DatePicker in `BakeCreationView` ✓
- [x] Conferma creazione porta al Bake Detail via `router.openBake` ✓
- [x] Step generati con orari retrodatati da `targetBakeDateTime` via `BakeScheduler` ✓

---

### 3. Esecuzione bake in ordine

- [x] Step attivo prominente: `ActiveStepHeroCard` in evidenza, separato da `StepTimelineRow` restante ✓
- [x] Tap Start: `step.start()` → status=.running, actualStart=.now, haptic `.impact(.soft)` ✓
- [x] Tap Complete: `step.complete()` → status=.done, actualEnd=.now, haptic `.success`, toast se bake completato ✓
- [x] Step completato: `StepTimelineRow` usa colori/badge distinti (verde per done, grigio per skipped) ✓
- [x] Bake completato: `derivedStatus == .completed` quando allSatisfy(done/skipped) ✓

---

### 4. Recovery fuori ordine

- [x] Avviare step non successivo: `requiresSequenceOverrideBeforeStart` → `confirmationDialog` in `BakeStepDetailView` ✓
- [x] Badge "Fuori ordine" con `tone: .info` (neutro, non errore) persistente su `ActiveStepHeroCard` e `StepTimelineRow` ✓
- [x] Bake non "rompe" dopo deviazione — solo badge informativo ✓
- [x] Riprendere l'ordine: gli altri step rimangono pending e accessibili ✓

---

### 5. Shift timeline

- [x] Opzioni +15, +30, +1h, Personalizzato in `StepQuickShiftStrip` + `ShiftTimelineView` ✓
- [x] `BakeScheduler.shiftFutureSteps` sposta solo step futuri non terminali ✓
- [x] Step terminali (done/skipped) non vengono toccati dal shift ✓
- [x] Dopo shift: `persistAndSync()` chiama `notificationService.syncNotifications(for: bake)` ✓

---

### 6. Starter — log refresh rapido

- [x] Log refresh: Today → "Rinfresca" (1 tap) → form → "Salva" (1 tap) = 2 tap ✓
- [x] Form mostra 3 campi principali (farina, acqua, starter usato); avanzati in `DisclosureGroup` collassato ✓
- [x] Valori pre-popolati dal last refresh (o default 80/80/20 se nessun refresh) ✓
- [x] Dopo save: `starter.lastRefresh = dateTime` → `TodayAgendaBuilder` ricalcola e Today rimuove l'item ✓
- [x] Reminder rischeduled: `notificationService.syncNotifications(for: starter)` dopo save ✓

---

### 7. Notifiche — warm launch

- [x] Tap su notifica bake con app aperta: `userNotificationCenter(willPresent:)` → `pendingURL` → `router.open(url:modelContext:)` ✓
- [x] Tap su notifica starter con app aperta: stesso path ✓

---

### 8. Notifiche — cold launch

- [x] Tap su notifica bake con app chiusa: `AppLaunchOptions.pendingNotificationRoute` → `notificationService.pendingURL` → `open(url:modelContext:)` ✓
- [x] Tap su notifica starter con app chiusa: stesso path ✓

---

### 9. Fallback notifiche

- [x] Bake cancellato: `openBake` + banner "Questo bake è stato annullato" ✓
- [x] Bake completato: `openBake` + banner "Questo bake è già completato" ✓
- [x] Bake non trovato: tab .bakes + empty path + banner "Questo bake non è più disponibile" ✓
- [x] Step non trovato: `openBake` + banner "Questa fase non è più disponibile" ✓
- [x] Starter non trovato: tab .starter + empty path + banner "Starter non trovato" ✓
- [x] Notifiche negate: `showNotificationsDisabledBanner()` → banner in Home ✓

---

### 10. Relaunch da background

- [x] Stato derivato da SwiftData, persistito su disco — coerente al relaunch ✓
- [x] Step `.running` persiste via `statusRaw` in SwiftData ✓
- [x] Bake completato persiste via `derivedStatus` calcolato da step.status ✓

---

## Risultati

| Flow                     | Stato             | Note |
| ------------------------ | ----------------- | ---- |
| 1. Apertura e Home       | ✅ Code audit OK  | 4 stati distinti implementati; allClear migliorato con Phase 13 |
| 2. Creazione bake        | ✅ Code audit OK  | Templates di sistema, fallback nome, DatePicker, BakeScheduler |
| 3. Esecuzione in ordine  | ✅ Code audit OK  | ActiveStepHeroCard prominente, haptics, toast |
| 4. Recovery fuori ordine | ✅ Code audit OK  | ConfirmationDialog, badge neutro "Fuori ordine" |
| 5. Shift timeline        | ✅ Code audit OK  | QuickShiftStrip + ShiftTimelineView, notifiche rischeduled |
| 6. Starter log refresh   | ✅ Code audit OK  | ≤2 tap, valori pre-popolati, toast dopo save |
| 7. Notifiche warm        | ✅ Code audit OK  | pendingURL + delegate willPresent |
| 8. Notifiche cold        | ✅ Code audit OK  | AppLaunchOptions + pendingNotificationRoute |
| 9. Fallback notifiche    | ✅ Code audit OK  | Tutti i casi (mancante, cancellato, completato) gestiti |
| 10. Relaunch             | ✅ Code audit OK  | SwiftData persistenza robusta |

## Bug e attriti emersi

Nessun bug critico trovato dall'analisi statica del codice.

Miglioramenti minori apportati in Phase 13:
- allClear state non aveva visual cue — ora ha icona checkmark verde
- RefreshLogView non pre-popolava i valori — ora usa last refresh
- BakeStepDetailView navigation title generico "Fase" → nome specifico dello step
- StarterDetailView navigation title generico "Starter" → nome specifico dello starter
- Pulsante "Salta questa fase" non aveva buttonStyle coerente — ora usa DangerActionButtonStyle

## Conclusione

- [x] UAT completato via code audit (2026-03-12)
- [ ] UAT su device fisico: da eseguire prima del rilascio
- [x] Bug critici: nessuno trovato
- [x] Ambiguità bloccanti: nessuna
- [x] MVP può considerarsi chiuso dal punto di vista del codice: sì
