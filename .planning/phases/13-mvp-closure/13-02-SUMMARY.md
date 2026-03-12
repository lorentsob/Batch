---
phase: 13-mvp-closure
plan: 02
status: complete
completed: 2026-03-12
---

## Summary

### Task 1: Audit e polish esecuzione bake

`BakeDetailView.swift`:
- Aggiunto `stepStartedTrigger` / `stepCompletedTrigger` con `.sensoryFeedback(.impact(flexibility: .soft))` e `.sensoryFeedback(.success)`.
- Toast "Bake completato! Buona lievitazione 🎉" quando l'ultimo step viene completato e il bake raggiunge status `.completed`.
- `handlePrimary` aggiornato per triggerare haptics e banner al momento giusto.

`BakeStepDetailView.swift`:
- `navigationTitle` cambiato da stringa fissa "Fase" → `step.displayName` per chiarezza contestuale.
- Haptics aggiunti su `start()` e `complete()`.
- Pulsante "Salta questa fase" ora usa `DangerActionButtonStyle()` invece di sola `foregroundStyle` — visivamente più coerente con gli altri pulsanti destructive.

### Task 2: Notifiche robuste in tutti gli scenari

Dall'audit del codice, il sistema notifiche è già robusto:
- `AppRouter.navigateFromNotificationPayload(bakeId:stepId:modelContext:)` gestisce bake mancante (tab safe + banner), bake cancellato (apre dettaglio + banner), bake completato (apre dettaglio + banner), step mancante (apre bake + banner).
- `AppRouter.navigateFromNotificationPayload(starterId:modelContext:)` gestisce starter mancante (tab safe + banner).
- `RootTabView` gestisce `pendingURL` per cold launch e warm launch via `.task(id:)`.
- `syncNotifications` viene chiamato dopo: creazione bake, shift timeline, modifica starter, completamento step.

Nessuna modifica necessaria al sistema notifiche — già conforme ai requisiti.

### Task 3: Starter flow veloce

`RefreshLogView.swift`:
- Aggiunto `init(starter:)` che pre-popola `flourWeight`, `waterWeight`, `starterWeightUsed`, `ratioText` dal **last refresh** dello starter. Se nessun refresh è registrato, usa i default (80g farina, 80g acqua, 20g starter, "1:4:4").
- Toast "Rinfresco salvato per {nome}" mostrato dopo il salvataggio tramite `environment.showBanner`.

`StarterDetailView.swift`:
- `navigationTitle` cambiato da "Starter" → `starter.name` per chiarezza quando si hanno più starter.

**Tap count verified**: Today → "Rinfresca" (1 tap) → form già compilato → "Salva" (1 tap) = 2 tap totali. ✓

## Files Modified
- `Levain/Features/Bakes/BakeDetailView.swift`
- `Levain/Features/Bakes/BakeStepDetailView.swift`
- `Levain/Features/Starter/RefreshLogView.swift`
- `Levain/Features/Starter/StarterDetailView.swift`
