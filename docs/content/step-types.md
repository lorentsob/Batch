# Step types consentiti

Questo file definisce il vocabolario controllato degli step types usabili nella sezione `## Steps` delle formule.

## Step types validi

Usa questi tipi nella sezione `## Steps` con il formato `- tipo | durata`:

- `autolyse` / `autolysis` — Autolisi (farina e acqua a riposo)
- `mix` — Impasto finale
- `bulk` — Bulk fermentation / puntata
- `fold` — Pieghe
- `preshape` — Preforma
- `bench-rest` — Bench rest (riposo tra preforma e formatura)
- `shape` — Formatura finale
- `proof` — Appretto / seconda lievitazione
- `cold-retard` — Maturazione in frigo
- `bake` — Cottura
- `cool` — Raffreddamento
- `custom` — Fase personalizzata

## Uso di `custom`

Usa `custom` solo quando:
- La fase non corrisponde a nessuno step type esistente
- Serve temporaneamente in attesa di definire un nuovo step type ufficiale

Se usi `custom`, **devi spiegare cosa rappresenta** nella sezione `## Notes` del file formula.

Esempi di uso corretto:
```markdown
## Steps
- custom | 720
- mix | 20
- bake | 25

## Notes
Lo step `custom | 720` rappresenta la maturazione del levain.
```

## Aggiungere nuovi step types

Se uno step ricorre spesso e merita un tipo dedicato:

1. Aggiungi il tipo in questo file
2. Aggiorna `STEP_TYPE_MAPPING` in `scripts/format_content.py`
3. Aggiungi il caso in `BakeStepType` enum in `Levain/Models/DomainEnums.swift`
4. Aggiungi il titolo italiano in `STEP_TITLES` nello script formatter
5. Solo dopo puoi usare il nuovo tipo nei file `.md`

## Mapping tecnico

I nomi markdown vengono mappati agli enum Swift:

| Markdown | Swift enum rawValue | Titolo italiano |
|----------|---------------------|-----------------|
| `autolyse`, `autolysis` | `autolysis` | Autolisi |
| `mix` | `mix` | Impasto |
| `bulk` | `bulk` | Bulk fermentation |
| `fold` | `fold` | Pieghe |
| `preshape` | `preshape` | Preforma |
| `bench-rest` | `benchRest` | Bench rest |
| `shape` | `shape` | Formatura |
| `proof` | `proof` | Appretto |
| `cold-retard` | `coldRetard` | Cold retard |
| `bake` | `bake` | Cottura |
| `cool` | `cool` | Raffreddamento |
| `custom` | `custom` | Fase personalizzata |
