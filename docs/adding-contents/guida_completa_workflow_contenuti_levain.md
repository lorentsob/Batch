# Guida completa al workflow contenuti di Levain

## Obiettivo

Questa guida spiega come aggiungere, aggiornare e integrare nuovi contenuti nel progetto **Levain** usando la struttura basata su file Markdown in `/docs/content`.

L’idea centrale è semplice:

- i file `.md` sono la **sorgente editoriale**
- un **formatter** valida e converte i contenuti
- l’app legge solo i **JSON tecnici finali**

Quindi:

`Markdown -> validazione -> conversione -> JSON bundled -> loader app`

L’app **non deve leggere direttamente i file Markdown** a runtime.

---

## Architettura generale

### Sorgente editoriale

Tutti i contenuti scritti a mano vivono in:

```text
docs/content/
```

Questa cartella contiene:

```text
docs/content/
  knowledge/
  formulas/
  categories.md
  step-types.md
```

### Output tecnico

Il formatter converte i Markdown in JSON compatibili con l’app:

```text
Levain/Resources/knowledge.json
Levain/Resources/system_formulas.json
```

### Consumo lato app

L’app legge i JSON finali con loader dedicati, per esempio:

```text
Levain/Services/KnowledgeLoader.swift
Levain/Services/SystemFormulaLoader.swift
```

Questi contenuti bundled sono **system content**.
Non devono essere trattati come dati utente e non devono essere salvati in SwiftData come sorgente principale.

---

## Regola fondamentale

### `/docs/content` è lo spazio editoriale

Qui scrivi e mantieni i contenuti in forma leggibile.

### `Resources/*.json` è il formato tecnico finale

Qui finiscono i contenuti già validati e normalizzati.

### Il formatter è il ponte

Il formatter è responsabile di:

1. leggere i `.md`
2. validare la struttura
3. trasformare il contenuto
4. produrre JSON pulito
5. segnalare errori o ambiguità

---

## Struttura delle cartelle

## `/docs/content/knowledge`

Contiene contenuti informativi, educativi o editoriali.

Esempi:

- spiegazioni su lievito madre
- articoli su fermentazione
- guide su frigo, pieghe, temperatura
- approfondimenti su farine, idratazione, timing

Ogni file rappresenta un contenuto singolo.

Esempio:

```text
docs/content/knowledge/starter-basics.md
docs/content/knowledge/cold-proofing.md
```

## `/docs/content/formulas`

Contiene ricette e formule strutturate.

Esempi:

- pizza
- focaccia
- pan brioche
- bagel
- potato buns

Ogni file è una formula singola.

Esempio:

```text
docs/content/formulas/pizza-in-giornata.md
docs/content/formulas/focaccia-tiktok.md
```

## `/docs/content/categories.md`

Definisce il vocabolario controllato delle categorie.

Serve a evitare categorie duplicate, incoerenti o scritte in modi diversi.

Esempi validi:

- bread
- pizza
- focaccia
- sweet
- starter
- fermentation

Se una categoria non esiste qui, non dovrebbe essere usata nei file contenuto.

## `/docs/content/step-types.md`

Definisce i tipi di step consentiti nei `## Steps` delle formule.

Esempi di step type:

- mix
- autolyse
- bulk
- fold
- shape
- proof
- cold-retard
- bake
- cool
- custom

Se serve uno step type nuovo, prima si aggiorna questo vocabolario, poi si usa nel Markdown.

---

## Convenzioni generali per tutti i file

## 1. Un file = un contenuto

Ogni file deve rappresentare un contenuto unico e coerente.

Non mettere più ricette nello stesso file.
Non mischiare una guida teorica e una formula nello stesso documento.

## 2. Sempre frontmatter YAML

Ogni file deve iniziare con un blocco YAML tra `---` e `---`.

Questo frontmatter contiene i metadati che il formatter usa per validare e convertire il contenuto.

## 3. `id` stabile e pulito

L’`id` deve essere:

- minuscolo
- con trattini
- senza spazi
- senza caratteri speciali
- stabile nel tempo

Esempi corretti:

```yaml
id: pizza-in-giornata
id: bagel-levain
id: pan-brioche-lievito-madre
```

## 4. Nessun dato inventato

Se una ricetta non fornisce un valore preciso, non bisogna fingere di saperlo.

In quel caso:

- si usa un valore conservativo solo se dichiarato esplicitamente
- oppure si lascia `status: draft`
- oppure si annota il limite nella sezione `Notes`

## 5. Naming coerente

Il nome file dovrebbe riflettere il contenuto.

Esempio:

```text
pizza-in-giornata.md
focaccia-tiktok.md
bagel-levain.md
```

---

## Come scrivere un contenuto `knowledge`

Un file `knowledge` serve per contenuti informativi.

### Frontmatter consigliato

```yaml
---
id: cold-proofing-basics
type: knowledge
title: Cold Proofing Basics
category: fermentation
tags:
  - frigo
  - lievitazione
  - fermentazione-summary: Come usare il frigo nella lievitazione, quando serve e quali effetti ha.
status: ready
---
```

### Corpo del file

Il corpo può essere libero, ma dovrebbe essere ben strutturato con titoli, paragrafi brevi e sezioni leggibili.

Esempio:

```md
## Cos’è
...

## Quando usarlo
...

## Vantaggi
...

## Errori comuni
...
```

### Cosa farà il formatter

Da questi file il formatter estrarrà:

- metadati
- summary
- body
- tag
- category

per generare `knowledge.json`.

---

## Come scrivere una `formula`

Un file `formula` serve per ricette strutturate.

Qui la struttura deve essere più rigorosa.

## Frontmatter minimo richiesto

```yaml
---
id: pizza-in-giornata
type: formula
title: Pizza in giornata
category: pizza
hydration: 60
salt_percent: 2
inoculation_percent: 50
servings: 3
flour_mix: 100% farina 00 per pizza
total_flour_weight: 600
total_water_weight: 360
status: draft
bake_type: pizza-tonda
---
```

## Sezioni consigliate del body

Una formula dovrebbe avere idealmente queste sezioni:

- `## Flour mix`
- `## Ingredients`
- `## Starter prep`
- `## Dough mix`
- `## Bulk`
- `## Shape`
- `## Proof`
- `## Bake`
- `## Cooling`
- `## Timeline`
- `## Notes`
- `## Steps`

Non tutte sono obbligatorie allo stesso modo, ma `## Steps` sì.

---

## `## Steps`: la parte più importante per il formatter

La sezione `## Steps` serve a dare una timeline strutturata e leggibile dalla macchina.

Formato richiesto:

```md
## Steps
- mix | 30
- bulk | 480
- shape | 120
- bake | 12
```

### Regole

- una riga per step
- formato sempre `- tipo | durata`
- `tipo` deve esistere in `step-types.md`
- `durata` deve essere numerica e in minuti
- niente testo libero nella stessa riga

### Esempi validi

```md
## Steps
- autolyse | 30
- mix | 20
- bulk | 180
- shape | 30
- proof | 120
- bake | 25
- cool | 20
```

### Esempi non validi

```md
## Steps
- impasto iniziale
- lievita un po'
- poi inforna
```

oppure:

```md
## Steps
- mix circa mezz'ora
```

oppure:

```md
## Steps
- stage-1 | 40
```

se `stage-1` non esiste nel vocabolario controllato.

---

## Quando usare `custom`

Se una ricetta ha una fase reale che non ha ancora uno step type dedicato, puoi usare temporaneamente `custom`.

Esempio:

```md
## Steps
- custom | 720
- mix | 20
- bulk | 180
- bake | 25
```

Però in `## Notes` va spiegato chiaramente cosa rappresenta:

```md
## Notes
- `custom | 720` rappresenta la maturazione del levain.
```

### Quando non basta più `custom`

Se una fase compare spesso, conviene aggiornare il vocabolario con uno step type nuovo.

Esempi sensati:

- levain
- boil
- rest
- bench-rest

Ma prima vanno aggiornati:

1. `docs/content/step-types.md`
2. eventuali enum o mapping del formatter
3. eventuali mapping lato app

Solo dopo si usa lo step nuovo nei file formula.

---

## Come scegliere category e step type

## Category

Va scelta solo tra quelle già definite in `categories.md`.

Se una ricetta è una pizza, usa `pizza`.
Se è una focaccia, usa `focaccia`.
Se è un dolce lievitato tipo brioche, usa `sweet` solo se quello è il bucket che avete deciso nel vocabolario.

Non usare varianti libere tipo:

- focacce
- pizzae
- sweet-bread
- dolci

se non esistono nel file categorie.

## Step type

Stessa regola.

Usa solo tipi dichiarati in `step-types.md`.

Se una fase non esiste:

- o la mappi temporaneamente su uno step esistente sensato
- o usi `custom`
- o estendi il vocabolario

Non inventare nomi sul momento.

---

## Strategia per i numeri nelle formule

## Caso 1: dati completi

Se hai una ricetta ben definita, puoi calcolare valori tecnici reali.

Esempio tipico:

- levain con composizione esplicita
- quantità di farina e acqua ben tracciate
- starter noto al 100% di idratazione

In questo caso puoi calcolare davvero:

- `total_flour_weight`
- `total_water_weight`
- `hydration`
- `salt_percent`
- `inoculation_percent`

## Caso 2: dati incompleti o ambigui

Se la ricetta include:

- latte
n- uova
- burro
- patate
- lievito madre senza scomposizione analitica

allora spesso non hai una baker’s percentage pulita.

In quel caso la strategia migliore è:

1. usare valori conservativi e dichiarati
2. scrivere chiaramente il criterio in `## Notes`
3. lasciare `status: draft` se il contenuto è ancora da consolidare

### Esempio di nota onesta

```md
## Notes
Le percentuali nel frontmatter sono state mantenute conservative e leggibili per il formatter.
Sono calcolate sulla farina principale dell’impasto e non sulla scomposizione tecnica completa di latte, uova o quota interna del lievito madre.
```

Questo evita che il sistema sembri più preciso di quanto sia davvero.

---

## Procedura completa per aggiungere un nuovo contenuto

## Caso A: aggiunta di un contenuto `knowledge`

### 1. Crea il file

Metti il file in:

```text
docs/content/knowledge/
```

### 2. Scrivi frontmatter e body

Assicurati che ci siano almeno:

- `id`
- `type: knowledge`
- `title`
- `category`
- `tags`
- `summary`
- `status`

### 3. Controlla category e tag

La category deve essere valida.
I tag devono essere coerenti e utili, non casuali.

### 4. Passa il file al formatter

Il formatter dovrà:

- leggere il frontmatter
- validare i campi
- leggere il body
- generare una entry JSON pulita

### 5. Controlla il validation report

Se ci sono errori:

- category non valida
- frontmatter incompleto
- summary mancante
- file vuoto

li correggi nel `.md`, non a valle.

### 6. Rigenera `knowledge.json`

Il JSON finale va aggiornato in:

```text
Levain/Resources/knowledge.json
```

### 7. Testa lato app

Verifica che il contenuto:

- venga caricato dal loader
- compaia nelle viste corrette
- abbia metadati leggibili

---

## Caso B: aggiunta di una nuova `formula`

### 1. Crea il file

Mettilo in:

```text
docs/content/formulas/
```

### 2. Compila il frontmatter

Controlla almeno:

- `id`
- `type: formula`
- `title`
- `category`
- `hydration`
- `salt_percent`
- `inoculation_percent`
- `servings`
- `status`

Se esistono nel vostro schema:

- `flour_mix`
- `total_flour_weight`
- `total_water_weight`
- `bake_type`

### 3. Scrivi il body in sezioni leggibili

Non serve rigidità assoluta letteraria, ma serve chiarezza strutturale.

### 4. Inserisci `## Steps`

Questa sezione è obbligatoria.
Senza `## Steps`, la formula non dovrebbe essere considerata valida per il formatter.

### 5. Valida step e category

Ogni step deve usare un tipo già supportato.
Ogni durata deve essere numerica.

### 6. Passa il file al formatter

Il formatter dovrà:

- fare parse del frontmatter
- estrarre le sezioni del body
- leggere `## Steps`
- trasformare gli step in array JSON
- validare i vocabolari

### 7. Controlla il validation report

Errori tipici:

- `## Steps` mancante
- `duration` non numerica
- step type sconosciuto
- category non valida
- `id` duplicato

### 8. Rigenera `system_formulas.json`

Il file finale va aggiornato in:

```text
Levain/Resources/system_formulas.json
```

### 9. Testa lato app

Controlla:

- lista formule
- dettaglio formula
- eventuale generazione bake
- eventuale scheduler o timeline UI

---

## Cosa dovrebbe fare il formatter

Il formatter dovrebbe essere il componente più severo della pipeline.

Non deve fare il poeta.
Non deve improvvisare.
Deve validare, trasformare e bloccare i contenuti sbagliati.

## Input

Uno o più file Markdown in `/docs/content`.

## Operazioni

1. legge il file
2. separa frontmatter e body
3. identifica il `type`
4. valida i campi richiesti
5. valida `category`
6. se `type: formula`, valida anche `## Steps`
7. converte il contenuto in JSON
8. produce output tecnico
9. genera validation report

## Output

- `knowledge.json`
- `system_formulas.json`
- report errori e warning

## Esempi di errori bloccanti

- frontmatter non valido
- file senza `id`
- `type` sconosciuto
- category non supportata
- formula senza `## Steps`
- step con tipo non valido
- durata non numerica

## Esempi di warning

- note mancanti
- titolo poco descrittivo
- valori conservativi non spiegati
- uso di `custom` senza spiegazione in `Notes`

---

## Esempio di conversione formula

### Input Markdown

```md
---
id: pizza-in-giornata
type: formula
title: Pizza in giornata
category: pizza
hydration: 60
salt_percent: 2
inoculation_percent: 50
servings: 3
status: draft
---

## Steps
- mix | 30
- bulk | 480
- shape | 120
- bake | 12
```

### Output JSON

```json
{
  "id": "pizza-in-giornata",
  "type": "formula",
  "title": "Pizza in giornata",
  "category": "pizza",
  "hydration": 60,
  "salt_percent": 2,
  "inoculation_percent": 50,
  "servings": 3,
  "steps": [
    { "type": "mix", "duration": 30 },
    { "type": "bulk", "duration": 480 },
    { "type": "shape", "duration": 120 },
    { "type": "bake", "duration": 12 }
  ]
}
```

---

## Come gestire modifiche di schema

Se il progetto evolve e serve una nuova informazione, non conviene improvvisare direttamente dentro i contenuti.

La strada ordinata è:

1. aggiornare la guida o il documento di strategia
2. aggiornare il formatter
3. aggiornare i vocabolari se necessario
4. aggiornare il loader app
5. solo dopo iniziare a usare il nuovo campo nei `.md`

### Esempi

#### Aggiunta di un nuovo step type

1. aggiorni `docs/content/step-types.md`
2. aggiorni parser e validazione
3. aggiorni eventuale mapping UI
4. scrivi formule che usano il nuovo step

#### Aggiunta di una nuova categoria

1. aggiorni `docs/content/categories.md`
2. validi che abbia senso come bucket
3. aggiorni eventuali filtri lato app
4. poi usi la categoria nei file

---

## Errori da evitare

## 1. Far leggere all’app i Markdown

No.
I Markdown devono restare sorgente editoriale.
L’app legge JSON già convertiti.

## 2. Modificare a mano i JSON finali come fonte primaria

No.
I JSON finali sono output generati.
La modifica va fatta a monte nel `.md`.

## 3. Inventare category o step type

No.
Prima si aggiornano i vocabolari.

## 4. Usare `custom` ovunque per pigrizia

Si può usare, ma con criterio.
Se un pattern ricorre spesso, conviene introdurre uno step type vero.

## 5. Mischiare due timeline incompatibili nello stesso `## Steps`

Se una ricetta ha una variante principale e una variante alternativa, negli step va rappresentato solo il percorso principale.
La variante secondaria resta nel body o nelle note.

## 6. Fingere precisione matematica dove non c’è

Se mancano dati, scrivilo.
Meglio una formula onesta che una finta precisa.

---

## Checklist operativa per aggiungere un contenuto

## Knowledge

- file in `docs/content/knowledge/`
- frontmatter completo
- category valida
- tags utili
- summary presente
- body leggibile
- formatter eseguito
- validation report pulito
- `knowledge.json` aggiornato
- test app eseguito

## Formula

- file in `docs/content/formulas/`
- frontmatter completo
- category valida
- percentuali dichiarate o motivate
- `## Steps` presente
- step type validi
- durate numeriche
- note chiare se ci sono compromessi
- formatter eseguito
- validation report pulito
- `system_formulas.json` aggiornato
- test app eseguito

---

## Workflow consigliato per il team

### Quando aggiungi un nuovo contenuto

1. scrivi il `.md` in `/docs/content`
2. controlli category e step types
3. fai girare il formatter
4. leggi il validation report
5. correggi i file con problemi
6. rigeneri i JSON bundled
7. testi in app
8. fai commit sia del Markdown sia dell’output generato, se il progetto lo prevede

### Quando cambi lo schema

1. aggiorni il documento strategico
2. aggiorni formatter e vocabolari
3. fai una migrazione dei contenuti se serve
4. poi continui a scrivere contenuti nuovi

---

## Schema mentale finale

Usa questo modello, che è quello più pulito:

```text
/docs/content = sorgente umana
formatter = validazione + trasformazione
/Resources/*.json = output tecnico
app = consumo finale
```

Se questo confine rimane chiaro, il sistema resta ordinato.
Se inizi a mischiare sorgente editoriale, parser improvvisati e JSON toccati a mano, nel giro di poco diventa una palude.

---

## Conclusione operativa

Se devi aggiungere contenuti nuovi, la procedura corretta è sempre questa:

1. scrivi il file Markdown in `/docs/content`
2. usa il formato corretto per `knowledge` o `formula`
3. rispetta categories e step types ufficiali
4. fai validare tutto dal formatter
5. genera i JSON finali
6. fai caricare all’app solo quei JSON

Questo è il workflow da considerare standard per il progetto Levain.

