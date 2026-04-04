---
created: 2026-04-04T10:00
title: Selettore fonte lievito con ricalcolo automatico quantità e tempi
area: ui
files:
  - Levain/Features/Bakes/BakeCreationView.swift
  - Levain/Features/Bakes/FormulaDetailView.swift
  - Levain/Features/Bakes/FormulaEditorView.swift
  - Levain/Models/DomainEnums.swift
  - Levain/Models/RecipeFormula.swift
  - Levain/Services/BakeScheduler.swift
---

## Problem

Attualmente il selettore starter in BakeCreationView permette di scegliere solo tra i propri starter (lievito madre). Se la ricetta usa lievito commerciale (dryYeast / freshYeast) la sezione starter è nascosta, ma non esiste modo di:

1. Scegliere tra "uno dei miei starter" oppure "lievito commerciale" (birra fresco / birra secco / instant) direttamente nel selector dello starter
2. Quando si sceglie un lievito commerciale, far ricalcolare automaticamente:
   - La farina totale (recuperando la quota farina contenuta nello starter)
   - L'acqua totale (recuperando la quota acqua contenuta nello starter)
   - Il grammi di lievito commerciale in base al profilo tempi scelto (lenta / media / rapida)
   - I plannedDurationMinutes dei BakeStep (fermentazione bulk, appretto) in base al profilo tempi

## Logica di conversione (da documento allegato)

### 1. Scomposizione dello starter
```
// Starter a idratazione variabile (es. 100% = metà farina metà acqua)
starterFlour = starterWeight / (1 + hydration/100)
starterWater = starterWeight - starterFlour

// Nuovi valori ricetta senza starter
newTotalFlour = formula.totalFlourWeight + starterFlour
newTotalWater = formula.totalWaterWeight + starterWater
starterWeight  = 0
```

### 2. Quantità lievito in base al profilo tempi (per 500g farina; scalare proporzionalmente)
| Profilo         | Lievito instant/secco | Lievito fresco |
|----------------|----------------------|----------------|
| Lenta 16-20h   | ~1.5 g               | ~4.5–5 g       |
| Media 8-12h    | ~3 g                 | ~9 g           |
| Rapida 2-4h    | ~5–7 g               | ~15–21 g       |

### 3. Conversioni tra tipi di lievito
- Fresco × 0.40 = secco attivo
- Fresco × 0.33 = instant/secco per pane
- Instant × 3.0 = fresco
- Secco attivo × 2.5 = fresco

### 4. Durate BakeStep per profilo tempi
| Step              | Rapida      | Media       | Lenta         |
|-------------------|-------------|-------------|---------------|
| Bulk fermentation | 60–120 min  | 240–480 min | 960–1200 min  |
| Appretto/Proofing | 45–90 min   | 60–120 min  | 480–720 min   |

## Solution

### UX flow
Nel BakeCreationView, la sezione "Starter" diventa **"Fonte lievito"** con due tab/segmenti:
- **Mio starter** → picker tra i propri Starter SwiftData (comportamento attuale)
- **Lievito commerciale** → picker a tre opzioni: Fresco / Secco / Instant

Quando si sceglie **Lievito commerciale**:
1. Appare un ulteriore picker **Profilo tempi**: Rapida / Media / Lenta
2. L'app mostra un riepilogo calcolato in tempo reale:
   - Nuova farina totale
   - Nuova acqua totale
   - Grammi di lievito consigliati
   - Range tempi lievitazione previsto
3. Al tap "Crea cottura" i BakeStep generati usano le durate ricalcolate

### Modello dati (nessuna migrazione SwiftData necessaria)
- `YeastType` esistente già copre `.dryYeast`, `.freshYeast`, `.sourdough`
- Aggiungere caso `.instantYeast` a `YeastType` (o riusare `dryYeast` mappandolo come "instant" — da valutare)
- Aggiungere `YeastProfile` enum (`.fast`, `.medium`, `.slow`) in DomainEnums.swift — non persistito, solo UI/calcolo
- La logica di ricalcolo va in `BakeScheduler` o in un nuovo `YeastConversionService`

### Servizio di conversione (YeastConversionService o BakeScheduler esteso)
```swift
struct YeastConversionResult {
    let newTotalFlour: Double
    let newTotalWater: Double
    let yeastGrams: Double
    let bulkDurationMinutes: Int
    let proofDurationMinutes: Int
}

func convertFromSourdough(
    formula: RecipeFormula,
    starterWeight: Double,
    starterHydration: Double,   // 0–200
    yeastType: YeastType,       // .dryYeast / .freshYeast / .instantYeast
    profile: YeastProfile       // .fast / .medium / .slow
) -> YeastConversionResult
```

### File da creare / modificare
- `DomainEnums.swift` — aggiungere `YeastProfile` enum + eventuale `.instantYeast`
- `Services/YeastConversionService.swift` — logica pura di conversione (testabile senza UI)
- `BakeCreationView.swift` — sostituire sezione starter con selector "Fonte lievito" + profilo tempi + riepilogo preview
- `BakeScheduler.swift` — accettare `YeastConversionResult` per generare step con durate corrette
- `FormulaDetailView.swift` — mostrare badge "Lievito commerciale" con profilo consigliato

### Vincoli
- La conversione avviene SOLO al momento della creazione cottura — non modifica la RecipeFormula sorgente
- Se si sceglie lievito commerciale, la sezione starter non viene mostrata (già implementato)
- Impasti ricchi (brioche, cinnamon rolls) richiedono un warning: "Con impasti ricchi i tempi potrebbero allungarsi"
- L'instant yeast viene trattato come equivalente al secco per pane (1:1 domestico, come da documento)
