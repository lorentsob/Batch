# Levain v2
## Product Definition, UX Direction e contesto definitivo per l’estensione a milk kefir

**Versione:** 2.0 working draft  
**Lingua prodotto:** Italiano-first  
**Piattaforma:** iPhone only  
**Stack confermato:** SwiftUI + SwiftData + UserNotifications + JSON locali  
**Ambito:** progetto personale, internal testing, offline-first

---

# 1. Sintesi della decisione

Levain non deve più essere trattata come un’app verticale sulla lievitazione del pane con una feature extra dedicata al kefir.

Da questa versione in poi il prodotto viene riposizionato come:

**planner operativo e journal leggero per preparazioni fermentate domestiche**

La promessa centrale resta invariata:

**"Cosa devo fare adesso?"**

Questa promessa continua a governare tutta la UX.

La modifica strutturale è che il prodotto non ha più come centro esclusivo la panificazione, ma un contenitore più ampio di preparazioni fermentate. Il primo nuovo verticale da integrare è il **milk kefir**.

La direzione approvata è il **Flow B**:

1. **Home / Oggi**
2. **Preparazioni**
3. **Knowledge**

Questa scelta sostituisce l’attuale navigazione centrata su:

- Today
- Bakes
- Starter
- Knowledge

con una shell più scalabile, mantenendo però separati i domini interni dove serve per preservare la chiarezza d’uso.

---

# 2. Obiettivo della v2

L’obiettivo della v2 è estendere Levain oltre il perimetro pane + lievito madre senza rompere ciò che oggi funziona:

- Today come centro operativo
- logica action-first
- reminder locali affidabili
- offline-first
- knowledge leggera e filtrabile
- dati avanzati nascosti e non invasivi

La v2 deve permettere di:

- mantenere il verticale **Pane e lievito madre**
- introdurre il verticale **Milk kefir**
- supportare un uso da **fermentation journal**
- tracciare preparazioni che vivono nel tempo e si trasformano giorno dopo giorno
- rendere chiaro il rapporto tra batch, origine del batch e routine di gestione

---

# 3. Nuovo posizionamento del prodotto

## 3.1 Cosa diventa Levain

Levain diventa un’app nativa iPhone per:

- gestire attività operative legate a fermentazioni domestiche
- mantenere storico e continuità delle preparazioni
- supportare routine ricorrenti e batch attivi
- raccogliere note e differenze tra batch nel tempo
- consultare conoscenza pratica e troubleshooting con filtri per dominio

## 3.2 Cosa non diventa

Levain non deve diventare:

- una recipe app generica
- un database enciclopedico di fermentazioni
- una piattaforma social
- un assistente AI
- una dashboard scientifica piena di metriche inutili
- un sistema multi-device con sync e backend

## 3.3 Tensione progettuale da preservare

La v2 amplia il perimetro ma non deve perdere la disciplina del prodotto originale.

Regola chiave:

**il prodotto resta operativo prima di tutto, editoriale e storico solo in seconda battuta**

Il journal esiste, ma non deve soffocare l’azione.

---

# 4. Decisioni definitive concordate

## 4.1 Ambito fermentato incluso in v2

Per ora Levain v2 include solo:

- **Pane e lievito madre**
- **Milk kefir**

## 4.2 Kefir incluso

Il verticale nuovo è solo:

- **milk kefir**

## 4.3 Kefir escluso

Resta fuori da questa fase:

- water kefir
- fermentazioni secondarie avanzate come area autonoma
- ricette basate sul kefir
- statistiche complesse o analisi pseudo-scientifiche

## 4.4 Tipo di prodotto desiderato

Levain deve evolvere verso:

- **planner operativo**
- **fermentation journal** leggero ma utile

## 4.5 Organizzazione interna del verticale pane

Il verticale pane deve esistere come hub dedicato, ma internamente devono restare separati:

- **Impasti**
- **Starter**

perché questa separazione migliora la UX e riflette due tipi di attività diverse.

## 4.6 Modello operativo del kefir

Il kefir è una **routine quotidiana**, ma ogni preparazione deve essere trattata come un **batch**.

Un batch può:

- essere un batch unico che continua giorno dopo giorno
- derivare da un batch precedente
- convivere con altri batch paralleli
- stare in condizioni diverse
- avere destinazioni e comportamenti diversi

Esempi supportati:

- batch gestito fuori frigo con refresh giornaliero
- batch in frigo
- batch in congelatore in pausa
- batch derivato da un batch attivo principale
- batch destinato a un certo uso o test

## 4.7 Tracking opzionale dei grani

L’utente vuole poter tracciare, ma in modo opzionale:

- quantità grani
- crescita dei grani
- cambiamenti nel tempo
- note qualitative sullo stato

## 4.8 Knowledge

La knowledge deve restare comune a tutta l’app ma con:

- **filtri per dominio**
- categorizzazione chiara
- integrazione contestuale secondaria

---

# 5. Nuova architettura concettuale del prodotto

## 5.1 Shell condivisa

La shell generale dell’app è unica e comprende:

- Home / Oggi
- Preparazioni
- Knowledge

Questa shell è comune a tutti i domini.

## 5.2 Verticali interni

Dentro Preparazioni vivono verticali separati:

### Pane e lievito madre
Con sotto-separazione interna tra:
- Impasti
- Starter
- Formule

### Milk kefir
Con sotto-separazione interna tra:
- Batch
- Colture / grani
- Storico / journal

## 5.3 Principio di progetto

**Shell comune, logiche interne diverse.**

Il prodotto non deve forzare pane e kefir nello stesso identico modello operativo.

Il pane continua a usare una logica:

- timeline-based
- step-based
- target-time-based

Il kefir usa invece una logica:

- cycle-based
- batch-based
- routine-based
- lineage-aware

---

# 6. Nuova Information Architecture

## 6.1 Tab bar v2

La nuova tab bar definitiva della v2 è:

1. **Oggi**
2. **Preparazioni**
3. **Knowledge**

## 6.2 Razionale

### Oggi
Resta il centro operativo assoluto.

### Preparazioni
Diventa il punto di accesso ai verticali e sostituisce la vecchia separazione rigida tra Bakes e Starter.

### Knowledge
Resta una libreria leggera, filtrabile, contestuale e cross-domain.

## 6.3 Cosa cambia rispetto alla v1

### Prima
- Today
- Bakes
- Starter
- Knowledge

### Dopo
- Oggi
- Preparazioni
- Knowledge

Con questa modifica:

- il pane non sparisce
- starter non sparisce
- kefir non viene appiccicato come quarta tab arbitraria
- il prodotto guadagna una struttura scalabile

---

# 7. UX principles confermati e adattati

## 7.1 Action-first

Ogni schermata deve continuare a rispondere prima di tutto a:

**"Cosa devo fare adesso?"**

## 7.2 Un’azione primaria per card

Ogni card espone una sola azione primaria visibile.

## 7.3 Progressive disclosure

Dati tecnici, note lunghe e campi nerd restano:

- collassabili
- secondari
- fuori dal flusso principale

## 7.4 Il journal non deve rompere il planner

Storico e journaling esistono, ma:

- non dominano Home
- non trasformano l’app in un diario pesante
- servono a contestualizzare il batch, non a sostituire l’azione

## 7.5 Separazione chiara dei modelli mentali

Pane e kefir devono essere riconoscibili come domini con comportamenti diversi.

---

# 8. UX dettagliata della nuova shell

# 8.1 Oggi

## Ruolo
Oggi resta la home principale e operativa.

Non è una dashboard descrittiva. È una to-do board per fermentazioni vive.

## Contenuti di Oggi
La schermata aggrega task da tutti i verticali:

- step degli impasti
- reminder starter
- batch kefir da gestire
- batch kefir in warning
- batch kefir in pausa che richiedono riattivazione
- elementi pianificati per oggi o domani

## Ordine di priorità
Ordine di priorità v2:

1. **Adesso / in ritardo**
2. **Più tardi oggi**
3. **Da controllare**
4. **Domani / dopo**

## Categorie aggregate
### Pane
- step in corso
- step in ritardo
- step da avviare oggi

### Starter
- rinfreschi dovuti
- starter in stato overdue

### Kefir
- batch da filtrare o rinnovare
- batch quasi scaduti
- batch scaduti
- batch in pausa da riattivare
- batch con reminder legati a routine diverse

## Principio visuale
In Oggi i task devono essere mostrati in modo uniforme come oggetti operativi, ma con chiara indicazione del dominio:

- Pane
- Starter
- Kefir

## Esempi di card in Oggi
### Pane
- "Bulk fermentation · Pane base"
- "In corso · fine prevista 15:40"
- CTA: `Apri step`

### Starter
- "Starter grano duro"
- "Da rinfrescare oggi"
- CTA: `Rinfresca`

### Kefir
- "Batch kefir principale"
- "Quasi da rinnovare · 2h rimanenti"
- CTA: `Gestisci batch`

oppure

- "Batch kefir frigo"
- "In pausa · controlla entro domani"
- CTA: `Apri batch`

## Empty state di Oggi
L’empty state va aggiornato.

Nuovo messaggio:

- titolo: **Tutto sotto controllo**
- descrizione: **Nessuna attività urgente. Crea un impasto, aggiungi uno starter o avvia un batch kefir.**
- CTA primaria: `Nuova preparazione`
- CTA secondaria: `Esplora knowledge`

---

# 8.2 Preparazioni

## Ruolo
Preparazioni è il nuovo hub strutturale del prodotto.

Serve per:

- entrare nei verticali
- vedere lo stato generale dei domini
- creare nuovi oggetti
- riprendere rapidamente ciò che conta

## Root layout
La root di Preparazioni mostra due card-hub principali:

1. **Pane e lievito madre**
2. **Milk kefir**

Ogni card-hub mostra:

- titolo
- sottotitolo descrittivo
- stato sintetico
- contatore oggetti attivi
- ultima attività
- CTA primaria per entrare

## Card hub 1: Pane e lievito madre
Sottotitolo:

**Impasti, starter e formule**

Micro contenuti possibili:

- 2 impasti attivi
- 1 starter da rinfrescare
- ultima attività oggi 09:20

CTA: `Apri hub`

## Card hub 2: Milk kefir
Sottotitolo:

**Batch, colture e routine giornaliera**

Micro contenuti possibili:

- 3 batch attivi
- 1 batch in warning
- ultimo rinnovo ieri 22:10

CTA: `Apri hub`

## Quick actions opzionali in alto
Preparazioni può includere una fascia leggera di quick actions:

- Nuovo impasto
- Nuovo starter
- Nuovo batch kefir

Da usare solo se non appesantisce troppo la root.

---

# 8.3 Hub interno: Pane e lievito madre

## Principio
Questo hub deve restare internamente separato per migliorare UX.

Non va mischiato tutto insieme.

## Sezioni interne
L’hub Pane e lievito madre contiene tre ingressi distinti:

1. **Impasti**
2. **Starter**
3. **Formule**

## Impasti
Raccoglie:

- impasti in corso
- pianificati
- completati

Qui la UX può restare molto vicina all’attuale Bakes.

## Starter
Raccoglie:

- profili starter
- storico rinfreschi
- reminder
- impostazioni dedicate

Qui la UX può restare molto vicina all’attuale Starter.

## Formule
Raccoglie:

- formule riusabili
- step template
- creazione e modifica

## Regola importante
La v2 non deve rompere la UX dell’attuale verticale pane, ma solo spostarlo dentro un hub più alto.

Il principio è:

**mantenere il verticale pane quasi intatto, cambiando il modo in cui viene raggiunto**

---

# 8.4 Hub interno: Milk kefir

## Ruolo
Questo è il nuovo verticale v2.

Deve essere pensato per una routine quotidiana basata su batch vivi e continui, non come semplice lista di rinfreschi.

## Sezioni interne consigliate
L’hub Milk kefir contiene almeno tre aree:

1. **Batch**
2. **Colture / grani**
3. **Journal / storico**

In alternativa, per una prima versione più semplice:

1. **Batch**
2. **Colture**
3. **Archivio**

## 8.4.1 Batch
Qui vivono i batch attivi e storici.

Ogni batch rappresenta una preparazione concreta e può:

- essere attivo
- proseguire giorno dopo giorno
- derivare da un batch precedente
- avere una routine diversa
- essere gestito in modo separato dagli altri batch

### Informazioni visibili in card
- nome batch
- stato
- origine del batch se presente
- condizione di conservazione
- ultima gestione
- prossimo alert
- eventuale uso previsto

### Esempi
- Batch principale · fuori frigo
- Batch frigo · backup
- Batch congelatore · pausa lunga
- Batch derivato · test latte diverso

## 8.4.2 Colture / grani
Questa sezione riguarda il lato più biologico e meno operativo, ma importante per chi vuole tracciare continuità e crescita.

Qui vanno:

- quantità grani attuale, opzionale
- crescita nel tempo, opzionale
- note su stato e comportamento
- eventuali passaggi di divisione o derivazione

Questa sezione non deve essere obbligatoria per l’uso base.

## 8.4.3 Journal / storico
Questa sezione serve a leggere la storia del kefir nel tempo.

Contiene:

- log eventi
- rinnovi
- cambi di stato
- cambi di conservazione
- variazioni tra batch
- note sull’uso

Il journal deve aiutare a confrontare batch e capire differenze, non diventare una timeline infinita e ingestibile.

---

# 8.5 Knowledge

## Ruolo
Knowledge resta una tab autonoma, leggera e filtrabile.

## Struttura v2
La struttura base resta valida ma va estesa con filtri per dominio.

### Filtri principali
- Tutti
- Pane
- Starter
- Kefir
- Troubleshooting
- Routine

## Search
La ricerca deve restare globale.

## Uso contestuale
Gli articoli restano accessibili anche:

- da step e schede pane
- da starter detail
- da batch kefir
- da stati problematici

## Regola
Knowledge deve restare di supporto, non protagonista.

---

# 9. Nuovi flussi UX principali

# 9.1 Flusso: apertura app

1. apertura app
2. arrivo su Oggi
3. visione immediata di ciò che richiede attenzione
4. accesso diretto al task rilevante

Questo principio resta invariato.

# 9.2 Flusso: navigazione esplorativa nel pane

1. apri Preparazioni
2. tocchi Pane e lievito madre
3. scegli una delle sotto-aree:
   - Impasti
   - Starter
   - Formule
4. entri nel flusso dedicato

# 9.3 Flusso: navigazione esplorativa nel kefir

1. apri Preparazioni
2. tocchi Milk kefir
3. scegli o visualizzi:
   - Batch attivi
   - Colture / grani
   - Journal / archivio
4. entri nell’oggetto da gestire

# 9.4 Flusso: gestione batch kefir da Oggi

1. da Oggi compare batch in warning o da rinnovare
2. tap su card
3. apertura dettaglio batch
4. azione primaria:
   - rinnova
   - segna come gestito
   - cambia stato
   - apri log
5. aggiornamento reminder e storico

# 9.5 Flusso: creazione nuovo batch kefir

1. apri hub Milk kefir
2. tap su `Nuovo batch`
3. scegli:
   - batch completamente nuovo
   - batch derivato da batch esistente
4. compili campi base
5. salvi
6. sistema crea batch e reminder iniziali

# 9.6 Flusso: derivazione di batch da batch esistente

Questo è un flusso nuovo e importante.

1. apri batch esistente
2. azione `Deriva nuovo batch`
3. il form propone dati precompilati
4. l’utente modifica ciò che cambia
5. salva
6. nuovo batch registra il riferimento all’origine

Risultato:

- il nuovo batch mantiene genealogia
- si può confrontare nel journal
- si capisce la differenza tra i due usi

---

# 10. Modello concettuale del milk kefir

## 10.1 Concetti principali

Per il verticale milk kefir servono almeno questi oggetti concettuali:

### KefirBatch
La preparazione concreta gestita nel tempo.

### KefirCulture
L’insieme di informazioni sulla coltura / grani.

### KefirEvent
I log operativi o di journal collegati al batch.

## 10.2 Relazione tra batch e cultura

Un batch può:

- essere collegato a una cultura
- nascere da un batch esistente
- avere una routine e destinazione diversa da altri batch legati alla stessa cultura

## 10.3 Regola progettuale

Per il kefir il batch è l’unità operativa primaria.

La cultura è l’unità biologica di supporto.

Il journal è la memoria degli eventi.

---

# 11. Data model direction v2

# 11.1 Modelli esistenti da mantenere

Questi modelli restano validi per il verticale pane:

- RecipeFormula
- Bake
- BakeStep
- Starter
- StarterRefresh
- KnowledgeItem
- AppSettings

# 11.2 Nuovi modelli consigliati per kefir

## KefirBatch
Campi consigliati:

- id
- name
- createdAt
- lastManagedAt
- nextDueAt
- state
- storageMode
- sourceBatchId
- cultureId
- useLabel
- notes
- alertsEnabled
- archiveState

Campi utili di contesto:

- milkType
- milkVolume
- expectedRoutine
- batchKind
- locationLabel

Campi di journaling leggero:

- lastOutcomeNote
- differentiationNote
- comparisonTags

## KefirCulture
Campi consigliati:

- id
- name
- createdAt
- state
- notes
- grainWeightOptional
- grainGrowthTrackingEnabled
- lastMeasuredGrainWeightOptional
- preferredRoutine

## KefirEvent
Campi consigliati:

- id
- batchId
- eventType
- dateTime
- milkType
- milkVolume
- storageMode
- note
- grainWeightOptional
- derivedFromBatchIdOptional

## AppSettings
Può includere preferenze generali per:

- reminder default kefir
- visualizzazione opzionale di metriche grani
- filtri iniziali knowledge

---

# 12. Stati del kefir

# 12.1 Stati del batch

Gli stati devono essere semplici, leggibili e orientati all’azione.

Stati consigliati:

- `active`
- `due_soon`
- `due_now`
- `overdue`
- `paused_fridge`
- `paused_freezer`
- `archived`

Nota importante:

A differenza degli step del pane, qui può avere senso avere stati derivati forti basati sul tempo e sulla modalità di conservazione, ma vanno comunque gestiti senza creare una macchina a stati complessa e fragile.

## 12.2 Stati della cultura

Stati consigliati:

- `active`
- `stable`
- `monitor`
- `paused`
- `archived`

## 12.3 Regola di derivazione

Molti stati devono essere derivati da:

- ultimo evento
- modalità di conservazione
- routine attesa
- prossima gestione prevista

---

# 13. Modalità di conservazione del kefir

Questa dimensione è fondamentale e deve essere esplicita.

Valori minimi consigliati:

- `room_temperature`
- `fridge`
- `freezer`

Effetti UX:

- cambiano microcopy e reminder
- cambia la severità dei badge
- cambia l’aspettativa temporale
- cambia il senso dello stato attuale

Esempio:

- batch fuori frigo: attenzione alta, ciclo rapido
- batch in frigo: stato tranquillo, reminder più dilatato
- batch in freezer: pausa lunga, nessun alert urgente salvo riattivazione pianificata

---

# 14. Dettaglio UX del batch kefir

## 14.1 Batch list

La lista batch deve mostrare:

- batch attivi in alto
- batch in warning dopo
- batch in pausa separati
- batch archiviati collassabili

## 14.2 Batch card

Ogni card mostra:

- nome batch
- stato
- storage mode
- provenienza se derivato
- ultimo rinnovo / ultima gestione
- prossimo alert
- uso o nota sintetica

CTA primaria dinamica:

- `Gestisci`
- `Rinnova`
- `Apri`

CTA secondaria opzionale:

- `Log`

## 14.3 Batch detail

Il dettaglio batch deve mostrare:

### Header
- nome batch
- stato
- storage mode
- origine
- uso / funzione del batch

### Sezione stato operativo
- ultima gestione
- prossima gestione prevista
- alert attivi

### Sezione eventi recenti
- rinnovi
- cambi storage
- note
- misure grani opzionali

### Sezione differenze e uso
- destinazione batch
- note comparative rispetto all’origine
- modifiche deliberate

### Azioni rapide
- rinnova batch
- deriva nuovo batch
- cambia stato
- sposta in frigo
- sposta in freezer
- archivia

---

# 15. Dettaglio UX della cultura kefir

## Ruolo
La cultura non è il centro del flusso operativo quotidiano, ma deve esistere per chi vuole continuità biologica e tracking più consapevole.

## Contenuti
- nome cultura
- stato generale
- batch collegati
- quantità grani opzionale
- ultima misura grani opzionale
- crescita nel tempo opzionale
- note

## CTA
- nuovo batch da questa cultura
- aggiorna grani
- apri batch collegati

## Regola
Se l’utente non usa il tracking grani, questa area deve restare estremamente leggera.

---

# 16. Journal e storia

## 16.1 Perché esiste

Il journal serve per:

- capire la continuità nel tempo
- confrontare batch diversi
- vedere derivazioni
- ricordare usi, eccezioni e cambiamenti

## 16.2 Cosa contiene

Il journal può includere:

- avvio batch
- rinnovo batch
- cambio latte
- cambio conservazione
- derivazione batch
- misurazione grani
- nota manuale
- archiviazione

## 16.3 Regola di progetto

Il journal non deve essere richiesto per usare bene l’app.

Deve essere una memoria strutturata utile, non un obbligo.

---

# 17. Knowledge v2

## 17.1 Estensione dei contenuti

Oltre ai contenuti attuali dedicati a pane e starter, vanno previste nuove categorie kefir.

## 17.2 Categorie nuove consigliate

- kefir basics
- routine quotidiana milk kefir
- batch fuori frigo
- batch in frigo
- batch in freezer
- riattivazione
- gestione dei grani
- troubleshooting kefir
- differenze tra batch

## 17.3 Uso dei filtri

Knowledge deve permettere almeno questi filtri visibili:

- Tutti
- Pane
- Starter
- Kefir
- Troubleshooting
- Routine

## 17.4 Uso contestuale

Esempi:

- batch overdue kefir → articolo correlato
- batch frigo in pausa → tip contestuale
- starter pigro → tip pane/starter
- bulk lunga o in ritardo → knowledge pane

---

# 18. Notifiche e reminder v2

## 18.1 Conferme

La strategia tecnica non cambia:

- notifiche solo locali
- niente backend
- niente push esterne
- dati persistiti localmente
- deep link tramite router interno

## 18.2 Reminder pane

Restano invariati:

- step reminders
- rescheduling dopo shift timeline
- reminder starter

## 18.3 Reminder kefir

Serve una logica dedicata e distinta.

Ogni batch kefir può avere:

- reminder principale
- warning vicino alla prossima gestione
- stato overdue se supera la finestra prevista

## 18.4 Regola importante

Le notifiche kefir non devono essere hardcoded tutte a 24 ore in modo cieco.

Il documento allegato propone una logica molto rigida centrata su batch fuori frigo entro 24h, ma la decisione finale di prodotto v2 è più ampia:

- il batch può vivere in contesti diversi
- la severità dipende dalla routine e dallo storage mode
- la UI deve mostrare chiaramente il contesto del batch

Quindi:

**il tempo è centrale, ma non esiste una sola regola universale uguale per tutti i batch**

---

# 19. Cambiamenti espliciti rispetto al documento kefir allegato

Il documento allegato è utile come base per:

- necessità utente
- centralità del tempo
- reminder
- idea di coltura e batch
- importanza del tracking semplice

Ma per la v2 definitiva si fissano queste correzioni:

## 19.1 Non solo coltura centrica
Il kefir non viene modellato soltanto come coltura con storico rinfreschi.

Il centro operativo è il **batch**.

## 19.2 Non solo refresh lineare
Il batch può continuare nel tempo e trasformarsi, non è sempre solo un singolo refresh chiuso.

## 19.3 Derivazione batch obbligatoriamente prevista
La v2 deve prevedere la possibilità di sapere se un batch nasce da un altro batch.

## 19.4 Conservazione come variabile primaria
Frigo e freezer non sono eccezioni marginali, ma parti reali del modello d’uso.

## 19.5 Grani opzionali
Il tracking grani esiste ma non deve essere imposto a tutti.

## 19.6 Knowledge filtrata
Il verticale kefir deve integrarsi nella stessa knowledge tab, non in un sistema editoriale separato.

---

# 20. Implicazioni architetturali

## 20.1 Regola generale
La struttura tecnica deve restare semplice e Apple-native.

## 20.2 Strato condiviso da estendere
Vanno estesi i livelli già esistenti:

- AppRouter
- TodayAgendaBuilder
- NotificationService
- KnowledgeLoader
- RootTabView

## 20.3 Nuove feature area consigliate
Nel progetto possono essere aggiunte aree come:

- `Features/Preparations/`
- `Features/BreadHub/`
- `Features/Kefir/`

oppure una struttura equivalente purché chiara.

## 20.4 Nuovi services consigliati
- `KefirAgendaBuilder`
- `KefirReminderService` oppure integrazione in `NotificationService`
- `KefirBatchDerivationService`
- `KefirHistoryFormatter`

## 20.5 Principio da non tradire
Niente over-abstraction.

Niente modello generico mostruoso per tutte le fermentazioni.

Serve una shell condivisa con domini specifici chiari.

---

# 21. Migrazione UX dalla v1 alla v2

## 21.1 Cosa resta quasi invariato
- Today come cuore dell’app
- dettaglio impasto
- starter management
- formule
- knowledge leggera
- notifiche locali

## 21.2 Cosa cambia davvero
- nuova tab bar
- nuovo hub Preparazioni
- pane spostato dentro hub dedicato
- nuovo verticale kefir
- journal più esplicito
- aggregazione cross-domain in Oggi

## 21.3 Percezione utente desiderata
L’utente non deve percepire una rifondazione traumatica.

Deve percepire che:

- l’app è diventata più ampia
- il pane è ancora al suo posto
- il kefir ha finalmente una casa coerente
- tutto continua a convergere su ciò che va fatto adesso

---

# 22. Scope v2

## Incluso
- nuova shell Oggi / Preparazioni / Knowledge
- hub Pane e lievito madre
- hub Milk kefir
- gestione batch kefir
- derivazione batch
- tracking storage mode
- tracking uso e differenze batch
- tracking grani opzionale
- knowledge con filtri cross-domain
- estensione Today per task kefir
- journaling leggero

## Escluso per ora
- water kefir
- ricette kefir
- sistema avanzato di analytics
- grafici complessi
- social / condivisione
- sync cloud
- backend
- AI generativa
- iPad

---

# 23. Priorità di implementazione consigliata

## Phase A
Ristrutturazione shell e routing:
- nuova tab bar
- Preparazioni root
- pane spostato in hub dedicato

## Phase B
Integrazione Today cross-domain:
- agenda item kefir
- card kefir in Oggi
- deep link routing aggiornato

## Phase C
Verticale milk kefir base:
- batch list
- batch detail
- nuovo batch
- cambio stato
- reminder base

## Phase D
Lineage e journal:
- derivazione batch
- log eventi
- archivio

## Phase E
Tracking grani opzionale e knowledge kefir:
- scheda cultura
- misure grani opzionali
- nuove categorie knowledge

---

# 24. Success criteria della v2

La v2 è considerata coerente se:

1. Oggi aggrega pane, starter e kefir senza confondere.
2. Preparazioni funziona come hub scalabile.
3. Il verticale pane non perde chiarezza.
4. Il verticale kefir supporta più batch con logiche diverse.
5. L’origine di un batch può essere tracciata.
6. L’utente può distinguere batch per uso, stato e conservazione.
7. Il tracking dei grani esiste ma resta opzionale.
8. Knowledge filtra bene i contenuti per dominio.
9. L’app continua a sembrare uno strumento operativo, non un database pieno di rumore.

---

# 25. Formula finale del prodotto v2

Levain v2 è un’app nativa iPhone per gestire fermentazioni domestiche vive come sistema operativo personale leggero.

Il prodotto resta planner-first e action-first, ma ora supporta più verticali all’interno di una shell unica.

Il pane continua a vivere con la sua logica a timeline e step.

Il milk kefir entra con una logica propria basata su batch, continuità, routine e journal.

La struttura corretta per questa evoluzione è:

- **Oggi** come centro operativo unico
- **Preparazioni** come hub dei verticali
- **Knowledge** come libreria filtrabile e contestuale

Questa è la direzione definitiva da usare come base per la progettazione e implementazione della v2.

