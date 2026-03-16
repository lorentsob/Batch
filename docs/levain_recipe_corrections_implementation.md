# Implementazione correzioni ricette Levain

## Obiettivo

Rendere **affidabili, coerenti e complete** le ricette passate all'app, così che ogni formula contenga:

- metadati consistenti
- numeri affidabili
- step utilizzabili dalla timeline
- descrizioni e note utili dentro i singoli step
- procedimenti completi sia nel file fonte sia nei dati finali passati all'app

Questo documento serve per guidare la correzione dei file sorgente markdown e la rigenerazione del file `system_formulas.json`.

---

## Stato attuale

I file sorgente sono buoni come base editoriale: hanno frontmatter, ingredienti, procedimento, steps e note.

I procedimenti **sono già presenti nei file fonte** in forma testuale. Il problema è che **non vengono trasferiti in modo completo nei dati finali dell'app**.

Nel file `system_formulas.json` infatti:

- `notes` è vuoto in tutte le formule
- `details` è vuoto in tutti gli step
- `notes` degli step è vuoto in tutti gli step
- i titoli step sono generici in diversi casi
- alcune informazioni importanti restano solo nel markdown sorgente e non arrivano alla formula finale

Quindi il contenuto c'è, ma al momento viene perso quasi del tutto durante il mapping.

---

## Problemi da correggere

## 1. Tipo ricetta incoerente tra file sorgente e app

### Problema
Nei markdown ci sono campi misti come `bake_type` e `category`, mentre nel JSON finale passa un campo `type` con valori non sempre coerenti.

Esempi attuali:

- Bagel -> `type: pane`
- Focaccia Tiktok -> `type: focaccia`
- Pan Brioche -> `type: dolci`
- Pizza in giornata -> `type: pizza`
- Potato Buns -> `type: dolci`

Questo crea incoerenza tra classificazione editoriale e classificazione tecnica.

### Correzione richiesta
Definire un solo campo canonico di dominio per il tipo formula.

Valori consigliati:

```yaml
bake_type: bagel
bake_type: focaccia
bake_type: pan-brioche
bake_type: pizza
bake_type: buns
```

Poi mappare questo campo in modo coerente nel JSON finale, evitando valori generici tipo `dolci` o `pane` quando la formula è più specifica.

### Azione
Riprendere tutti i file fonte e verificare che ciascuno abbia un `bake_type` esplicito e normalizzato.

---

## 2. Convenzione matematica incoerente tra le formule

### Problema
I file non usano tutti la stessa logica per:

- `total_flour_weight`
- `total_water_weight`
- `inoculation_percent`

Il caso più chiaro è Bagel, che usa un calcolo tecnico completo includendo la quota di farina e acqua del lievito. Le altre ricette invece usano numeri più semplificati, di solito riferiti solo all'impasto principale.

Quindi oggi le formule non sono confrontabili tra loro in modo affidabile.

### Correzione richiesta
Scegliere una convenzione unica per tutte le ricette.

### Direzione consigliata
Per semplicità e coerenza di prodotto:

- `total_flour_weight` = farina principale dichiarata nella ricetta
- `total_water_weight` = acqua o liquidi principali conteggiati secondo regola coerente
- `inoculation_percent` = definizione unica da applicare sempre

### Nota importante
Se si vuole usare una convenzione tecnica completa, va rifatta **tutta** la libreria. Se si vuole usare una convenzione più semplice e leggibile, va semplificato anche Bagel. Il problema non è quale convenzione scegli, ma mischiarle.

### Azione
Ricalcolare tutti i file fonte usando una regola unica e poi rigenerare `system_formulas.json`.

---

## 3. `inoculation_percent` errato o ambiguo

### Problema
La percentuale di inoculo non segue la stessa definizione in tutti i file.

Caso critico:

- **Pizza in giornata** nel JSON finale ha `inoculationPercent: 50`

Questo valore non torna con i numeri dichiarati nella ricetta e va corretto.

### Correzione richiesta
Definire una formula unica per il calcolo dell'inoculo e applicarla a tutte le ricette.

Esempio possibile:

```text
inoculation_percent = peso lievito madre / farina principale * 100
```

oppure:

```text
inoculation_percent = farina prefermentata / farina totale * 100
```

Una volta scelta la regola, aggiornare tutti i markdown e poi rigenerare il JSON.

### Azione specifica
Correggere sicuramente:

- `pizza-in-giornata.md`
- record corrispondente in `system_formulas.json`

---

## 4. Informazioni di procedimento presenti nei markdown ma perse nel JSON finale

### Problema
I file markdown contengono molto più dettaglio di quanto arrivi all'app.

Nel JSON finale:

- gli step hanno `details: ""`
- gli step hanno `notes: ""`
- la formula ha `notes: ""`

Quindi il sistema passa quasi solo durata e tipo step, ma non passa:

- cosa fare nello step
- cosa osservare
- temperatura o condizione ideale
- eventuali alternative
- dettagli utili per la riuscita

### Correzione richiesta
Il formatter deve leggere e integrare i procedimenti del file fonte dentro la formula finale.

### Regola da implementare
Per ogni step del markdown, bisogna popolare almeno:

- `name`
- `typeRaw`
- `durationMinutes`
- `details`
- `notes`

E per la formula:

- `notes`

### Mappatura consigliata
- `## Procedure` o `## Procedimento` -> materiale da distribuire in `details` e `notes` degli step
- `## Notes` -> `formula.notes`
- eventuali avvertenze operative -> `step.notes`

### Azione
Riprendere tutti i file fonte e trasferire i contenuti di procedimento negli step corrispondenti, evitando di lasciare step vuoti.

---

## 5. Step troppo generici o incompleti

### Problema
Diversi step nel JSON finale sono troppo poveri.

Esempi:

- `Fase personalizzata`
- `Impasto`
- `Bulk fermentation`
- `Formatura`
- `Appretto`

Questi nomi possono anche andare, ma senza `details` non spiegano nulla.

Inoltre alcuni passaggi importanti sono descritti nel markdown ma non diventano step espliciti o note di step.

### Correzione richiesta
Ogni step deve contenere almeno una descrizione operativa minima.

### Esempio
Invece di:

```json
{
  "name": "Impasto",
  "typeRaw": "mix",
  "durationMinutes": 30,
  "details": "",
  "notes": ""
}
```

servono step del tipo:

```json
{
  "name": "Impasto",
  "typeRaw": "mix",
  "durationMinutes": 30,
  "details": "Mescola farina, acqua e lievito madre fino a ottenere un impasto grezzo. Lascia riposare e incorpora il sale secondo il procedimento.",
  "notes": "L'impasto sarà molto morbido ma deve iniziare a prendere struttura."
}
```

### Azione
Integrare ogni step con testo utile preso dal procedimento del markdown.

---

## 6. Step presenti nel procedimento ma non rappresentati bene nella timeline

### Problema
Alcuni passaggi esistono nel testo ma non sono gestiti bene negli step finali.

#### Potato Buns
- la preparazione delle patate è descritta nel procedimento
- nel JSON compare solo una `Fase personalizzata` iniziale
- lo step non spiega chiaramente che si tratta del levain e della preparazione preliminare

#### Bagel
- la bollitura è importante ma nel JSON risulta come `Fase personalizzata`
- senza `details` si perde completamente il senso

#### Focaccia Tiktok
- `bulk` e `fold` sono separati ma il testo suggerisce che le pieghe avvengono dentro la bulk
- rischio di doppio conteggio o timeline poco chiara

#### Pan Brioche
- la preparazione del lievito è descritta nel markdown ma non è resa come step chiaro nella timeline finale

#### Pizza in giornata
- anche qui la preparazione iniziale del lievito è descritta nel markdown ma non diventa step esplicito
- lo step `shape` ingloba anche il riposo finale, ma senza dettagli questa informazione si perde

### Correzione richiesta
Ristrutturare gli step in modo che la timeline finale rappresenti il procedimento reale.

### Azione
Riprendere tutti i file fonte e decidere per ogni ricetta:

- quali passaggi devono essere veri step
- quali possono restare note
- quali passaggi preparatori devono essere mappati in `custom`
- quali step vanno rinominati in modo più chiaro

---

## Correzioni specifiche per file

## 1. `bagel-levain.md`

### Problemi
- manca un `bake_type` esplicito normalizzato
- usa una convenzione matematica diversa dalle altre ricette
- nel JSON finale i due step `custom` non spiegano cosa rappresentano
- mancano dettagli per impasto, formatura, bollitura e cottura

### Da fare
- aggiungere `bake_type: bagel`
- decidere se mantenere il modello matematico tecnico o riallinearlo agli altri
- trasformare il primo `custom` in step chiaramente nominato per il levain
- trasformare il secondo `custom` in step chiaramente nominato per la bollitura
- trasferire nel JSON dettagli operativi per ogni step
- compilare `formula.notes`

---

## 2. `potato-buns.md`

### Problemi
- `bake_type` da normalizzare
- classificazione finale attuale troppo generica
- preparazione patate e levain non descritte bene nella timeline finale
- dettagli procedimento assenti nel JSON

### Da fare
- usare `bake_type: buns`
- chiarire se la categoria editoriale resta separata da quella tecnica
- rinominare la `Fase personalizzata` iniziale in modo specifico
- aggiungere nei dettagli step istruzioni su impasto, formatura, appretto e finitura
- portare nel JSON anche le note su glassatura e sesamo
- compilare `formula.notes`

---

## 3. `focaccia-tiktok.md`

### Problemi
- `bake_type` da normalizzare
- possibile doppio conteggio tra `bulk` e `fold`
- variante same-day presente nel testo ma non trasferita negli step
- dettagli assenti nel JSON

### Da fare
- usare `bake_type: focaccia`
- decidere se `fold` resta step separato o viene incorporato nella descrizione della bulk
- aggiungere dettagli per stesura, oliatura, appretto e cottura
- valutare come rappresentare la variante same-day: nota formula o variante separata
- compilare `formula.notes`

---

## 4. `pan-brioche-lievito-madre.md`

### Problemi
- manca `bake_type`
- la preparazione iniziale del lievito non è resa come step chiaro
- il JSON finale non contiene alcuna descrizione utile
- classificazione attuale `dolci` troppo generica

### Da fare
- usare `bake_type: pan-brioche`
- aggiungere o chiarire lo step iniziale di preparazione del lievito
- trasferire dettagli su autolisi, impasto ricco, riposo in frigo, formatura e cottura
- aggiungere note su consistenza e gestione del burro
- compilare `formula.notes`

---

## 5. `pizza-in-giornata.md`

### Problemi
- `inoculationPercent` nel JSON finale è errato
- `bake_type` da normalizzare
- starter prep non rappresentato come step chiaro
- step `shape` troppo generico e povero
- topping e impasto convivono nello stesso impianto testuale ma nel JSON non arriva quasi nulla

### Da fare
- correggere il valore di inoculo nei file fonte e nel JSON
- usare `bake_type: pizza`
- aggiungere o rinominare lo step iniziale relativo al lievito madre
- dettagliare lo step di formatura e riposo dei panetti
- aggiungere note su condimento e cottura finale
- compilare `formula.notes`

---

## Regole di implementazione per il formatter

Il formatter deve essere aggiornato per fare queste cose:

## 1. Leggere tutti i file fonte completi
Non deve limitarsi al frontmatter e ai soli `## Steps`.
Deve leggere anche:

- ingredienti
- procedimento
- note
- varianti
- indicazioni di cottura

## 2. Popolare i campi formula
Per ogni ricetta deve valorizzare almeno:

- `id`
- `name`
- `type`
- `yeastType`
- `totalFlourWeight`
- `totalWaterWeight`
- `saltWeight`
- `servings`
- `inoculationPercent`
- `flourMix`
- `notes`

## 3. Popolare i campi step
Per ogni step deve valorizzare almeno:

- `id`
- `name`
- `typeRaw`
- `durationMinutes`
- `details`
- `notes`
- `temperatureRange` quando presente
- `volumeTarget` quando presente

## 4. Normalizzare gli step type
Uniformare i valori usati nel markdown e nel JSON finale.

Esempio:

- `cold-retard` nel markdown -> `coldRetard` nel JSON
- `autolyse` nel markdown -> `autolysis` nel JSON, solo se questa è la forma ammessa

Serve una tabella unica di mapping e va usata sempre.

## 5. Validare i numeri
Aggiungere controlli automatici almeno per:

- inoculo fuori scala o incoerente
- idratazione incoerente con acqua e farina
- sale incoerente con percentuale dichiarata
- step senza dettagli
- formule senza notes
- ricette senza `bake_type`

---

## Output atteso dopo la correzione

Alla fine della revisione, ogni ricetta deve produrre una formula finale che:

- abbia classificazione coerente
- abbia numeri coerenti con una sola convenzione
- non contenga errori evidenti di inoculo o pesi
- includa il procedimento dentro `details` e `notes`
- rappresenti la timeline reale senza buchi grossi
- includa note utili per l'uso in app

---

## Ordine di lavoro consigliato

1. Riprendere tutti i file markdown sorgente
2. Uniformare `bake_type`
3. Uniformare la convenzione matematica per farine, acqua e inoculo
4. Correggere i valori errati
5. Rivedere gli step uno per uno
6. Trasferire i procedimenti nei `details` e `notes`
7. Rigenerare `system_formulas.json`
8. Validare formula per formula prima dell'import finale

---

## Priorità alta

Correggere subito questi punti prima di qualsiasi altro import:

1. `pizza-in-giornata` -> inoculo errato
2. tutti i file senza `bake_type` esplicito
3. tutti gli step con `details` e `notes` vuoti
4. tutte le formule con `notes` vuoto
5. focaccia -> possibile doppio conteggio `bulk` + `fold`

---

## Conclusione

Le informazioni di procedimento **sono già presenti nei file fonte**, ma oggi **non vengono passate all'app in modo sufficiente**.

Il lavoro da fare non è riscrivere da zero le ricette, ma:

- riprendere tutti i file fonte
- integrare correttamente i procedimenti nel mapping
- correggere gli errori numerici e di classificazione
- rigenerare il file finale in un formato davvero affidabile per l'app

