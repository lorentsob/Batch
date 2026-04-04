---
created: 2026-04-04T00:00
title: Formula edit button + unified formula list with restore-to-default
area: ui
files:
  - Levain/Features/Bakes/FormulaListView.swift
  - Levain/Features/Bakes/FormulaDetailView.swift
  - Levain/Features/Bakes/FormulaEditorView.swift
  - Levain/Models/RecipeFormula.swift
  - Levain/Resources/system_formulas.json
---

## Problem

1. **Nessun tasto modifica sulle ricette esistenti.** Il `FormulaDetailView` mostra i dettagli di una ricetta ma non espone alcun bottone per modificarla. L'utente non può cambiare procedimenti, ingredienti o testi di una formula già creata — né delle proprie né di quelle di default.

2. **La lista ricette mostra solo le ricette utente.** Il `FormulaListView` (o schermata Bakes) mostra solo le formule create dall'utente. Le ricette di sistema (caricate da `system_formulas.json`) non sono accessibili dalla lista, rendendo impossibile consultarle o personalizzarle.

## Solution

### 1. Tasto Modifica in FormulaDetailView
- Aggiungere un bottone "Modifica" (matita) in alto a destra nel `toolbar` del `FormulaDetailView`.
- Il tap apre `FormulaEditorView` (già esistente) in modalità edit pre-popolata con i dati della formula corrente.
- Funziona sia per ricette utente che per ricette di default.

### 2. Lista unificata nel FormulaListView
- Mostrare TUTTE le formule presenti nell'app: quelle utente + quelle di sistema.
- Aggiungere un tag/badge visivo "Mia ricetta" per le formule create dall'utente (campo booleano `isUserCreated` o simile su `RecipeFormula`), così si mantiene la distinzione visiva senza trattarle diversamente.
- Le ricette di sistema caricate da `system_formulas.json` devono essere persistite in SwiftData al primo avvio (via `SeedDataLoader`) se non già fatto, per poter essere modificate.

### 3. Ripristino al default per le ricette di sistema
- Per le formule di sistema modificate dall'utente, esporre un'opzione "Ripristina al default" (es. bottone nel menu contestuale o nella toolbar del detail/edit view).
- Il ripristino ricarica i valori originali da `system_formulas.json` e sovrascrive i campi modificati.
- Potrebbe richiedere un campo `isModified: Bool` o un meccanismo di confronto con il JSON originale tramite `originalId`.

### Considerazioni tecniche
- Verificare se `RecipeFormula` ha già un campo per distinguere ricette utente da quelle di sistema; se no, aggiungere `isSystemFormula: Bool` (default `false`) e `isModifiedFromDefault: Bool`.
- Assicurarsi che `SeedDataLoader` persista le system formulas in SwiftData in modo da renderle modificabili (attualmente potrebbero essere solo in-memory o non persistite).
- `FormulaEditorView` dovrà supportare sia la creazione (nuova formula) che l'editing (formula esistente passata come parametro).

## TBD
- Decidere se il ripristino è una funzione distruttiva con conferma alert, o silente.
- Verificare la migrazione SwiftData se si aggiungono nuovi campi al model `RecipeFormula`.
