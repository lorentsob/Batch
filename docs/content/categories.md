# Categorie consentite

Questo file definisce il vocabolario controllato delle categorie per formule e contenuti knowledge.

## Formule

Categorie valide per `type: formula`:

- `bread` — Pane e grandi lievitati salati
- `pizza` — Pizza tonda, in teglia, al taglio
- `focaccia` — Focaccia e schiacciate
- `sweet` — Dolci lievitati (brioche, buns dolci, panettone)
- `custom` — Altro (usare solo se nessuna categoria esistente si applica)

## Knowledge

Categorie valide per `type: knowledge`:

- `starter` — Lievito madre, gestione, rinfreschi
- `fermentation` — Fermentazione, lievitazione, timing
- `bakerMath` — Baker's percentages, calcoli, idratazione
- `troubleshooting` — Problemi comuni e soluzioni

## Regole

- Non inventare categorie nuove senza aggiornare prima questo file
- Se serve una nuova categoria, aggiornala qui, poi nel formatter, poi negli enum Swift
- Usa sempre le categorie esattamente come scritte qui (minuscolo, niente varianti)
