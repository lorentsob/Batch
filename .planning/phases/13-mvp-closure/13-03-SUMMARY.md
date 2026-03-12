---
phase: 13-mvp-closure
plan: 03
status: complete
completed: 2026-03-12
---

## Summary

### Task 1: Audit naming e copy

**Risultato audit**: Naming già coerente. Nessun termine doppio trovato.
- "Ricetta" / "Ricette" usato ovunque nei navigationTitle e nelle UI strings (FormulaListView, FormulaDetailView, FormulaEditorView, FormulaStepEditorView).
- "Impasti" è il label della tab, "Bake" è usato nel contesto tecnico — distinzione chiara e voluta.
- "Starter" usato consistentemente (non "lievito madre" né "levain" come sinonimi mescolati).
- SeedDataLoader.swift: "La formula classica" → contesto baking generico, non ambiguità terminologica.

**Copy migliorato**:
- `BakesView` header: "Tieni d'occhio i bake in corso e quelli in programma." → "I tuoi bake in corso e in programma." (più diretto)
- `BakesView` header badges: ora nascosti quando il conteggio è 0 (no "0 bake / 0 ricette" confusionario).
- `StarterView` header: "Tieni d'occhio rinfreschi..." → "Rinfreschi, ritmo e stato del tuo lievito madre." (più descrittivo)
- `StarterView` header badge: nascosto quando starters.isEmpty.

### Task 2: Empty states completi

Tutti gli empty state verificati e migliorati:

| Schermata | Before | After |
|-----------|--------|-------|
| Today/firstLaunch | `TodayOnboardingView` con CTA | Invariato — già eccellente |
| Today/allClear | `EmptyStateView` generica | `TodayAllClearView` con icona checkmark (fatto in 13-01) |
| Impasti/nessun bake | "Nessun bake · Scegli una ricetta..." | "Nessun bake ancora · Scegli una ricetta, imposta l'orario..." + CTA "Crea il tuo primo bake" |
| Starter/nessuno starter | "Nessuno starter ancora · Aggiungi..." | Copy espanso: "Aggiungi il tuo lievito madre per tracciare..." + CTA "Aggiungi il tuo starter" |
| Ricette/nessuna ricetta | "Nessuna ricetta · Crea una ricetta per..." | Invariato — già corretto |
| Guide/nessun risultato | "Nessun risultato · Prova a cambiare..." + CTA "Ricarica" | CTA cambiata in "Mostra tutte le guide" che azzera query e filtro — più utile |

### Task 3: Micro-UX e audit finale di layout

**Completato in 13-01 e 13-02:**
- Haptic `.impact(.soft)` su avvio step (TodayView, BakeDetailView, BakeStepDetailView)
- Haptic `.success` su completamento step (stesse view)
- Toast "Bake completato!" su completamento bake
- Toast "Rinfresco salvato" dopo log refresh starter

**Layout audit:**
- Badge condizionali negli header (BakesView, StarterView) — no "0" badge che sembrano broken.
- `DangerActionButtonStyle` applicato al pulsante "Salta questa fase" — coerente con altri pulsanti destructive.
- `navigationTitle(step.displayName)` in BakeStepDetailView — contestuale e leggibile.
- `navigationTitle(starter.name)` in StarterDetailView — specifico con più starter.

**Build:** Nessun warning nuovo atteso. Tutte le modifiche sono additive o correttive, nessuna breaking change ai modelli.

## Files Modified
- `Levain/Features/Bakes/BakesView.swift`
- `Levain/Features/Starter/StarterView.swift`
- `Levain/Features/Knowledge/KnowledgeView.swift`
