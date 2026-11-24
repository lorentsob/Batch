# Batch Product Design Showcase Content

**Purpose:** contenuti strutturati da inserire nello showcase pubblico di Batch per far emergere il lavoro da product designer, usando `docs/case-history/final-showcase-plan.md` come source of truth.

**Pagina esistente analizzata:** `https://lorenzoboschi.it/it/progetti/batch`

**Gap principale:** la pagina copre già concept, spiegazione generale, problema/soluzione e schermate finali. Mancano le prove di processo: ricerca, sintesi, decisioni di prodotto, architettura UX, modelli di stato, iterazioni, validazione e trade-off.

---

## 1. Diagnosi Della Pagina Attuale

### Già coperto

- Intro prodotto: app nativa iPhone per preparazioni basate sulla fermentazione.
- Problema: strumenti esistenti troppo vicini a ricettari o community.
- Soluzione: app planner-first centrata sulla prossima cosa da fare.
- Concept visivo e schermate.
- Nota generale su UX/UI e sistema essenziale.
- Risultato finale.

### Da aggiungere

- Ruolo e responsabilità da product designer.
- Metodo di ricerca practice-led.
- Evidenza delle osservazioni e dei vincoli.
- Sintesi: insight, opportunità, principi.
- Architettura informativa aggiornata `Oggi / Batch / Guide`.
- Core flows e logica degli stati.
- Iterazioni progettuali e UAT.
- Validazione, limiti e prossimi sviluppi.

### Da correggere nella pagina

La sezione "Architettura dell'app" deve riflettere la IA finale:

```text
Oggi
Batch
Guide
```

Evitare di descrivere la seconda area come `Fermentazioni`: nel caso finale `Batch` è l'hub dei domini operativi, con `Impasti`, `Starter`, `Kefir` e `Ricette`.

---

## 2. Struttura Consigliata Dello Showcase

Questa struttura mantiene la pagina già pubblicata, ma inserisce il lavoro UX/prodotto tra la spiegazione iniziale e la gallery finale.

1. **Hero / Intro prodotto**
   - Tenere ciò che esiste.
   - Aggiungere metadati più forti: ruolo, piattaforma, scope, stato, vincoli.

2. **Contesto e challenge**
   - Tenere "Il problema", ma renderlo più specifico.
   - Spiegare perché la fermentazione non è solo ricetta: è tempo, stato, interruzioni, manutenzione.

3. **Ricerca e framing**
   - Nuova sezione.
   - Mostra come è stato compreso il dominio senza fingere una ricerca di mercato ampia.

4. **Sintesi progettuale**
   - Nuova sezione.
   - Insight, opportunità, principi e decisioni di scope.

5. **Architettura UX**
   - Aggiornare la sezione IA esistente.
   - Mostrare evoluzione da struttura frammentata a `Oggi / Batch / Guide`.

6. **Flussi e modelli di stato**
   - Nuova sezione.
   - Dimostra che l'interfaccia semplice poggia su regole operative chiare.

7. **Design system e interazione**
   - Espandere la sezione UX/UI esistente.
   - Legare colore, card, CTA e gerarchia al comportamento del prodotto.

8. **Iterazione e validazione**
   - Nuova sezione.
   - Mostra maturità: cosa è cambiato dopo audit, UAT e regression pass.

9. **Schermate finali guidate**
   - Tenere le schermate, ma organizzarle come storyboard, non come gallery.

10. **Outcome e riflessione**
   - Tenere "Risultato", ma chiudere con evidenze, limiti e learnings.

---

## 3. Blocchi Editoriali Pronti

### 3.1 Ruolo E Scope

**Titolo sezione:** Ruolo e responsabilità

**Copy:**

Ho seguito Batch come progetto end-to-end di product design e sviluppo iOS: dalla definizione del problema alla struttura dei flussi, dalla modellazione degli stati operativi fino alla UI nativa SwiftUI. Il lavoro non si è limitato alla resa visiva delle schermate: la parte centrale è stata trasformare routine fermentative reali in un sistema leggibile, affidabile e gestibile nel tempo.

**Dati sintetici:**

| Area | Scelta |
|---|---|
| Ruolo | Product design, UX/UI, iOS implementation |
| Piattaforma | iPhone native app |
| Lingua prodotto | Italiano-first |
| Persistenza | Locale, SwiftData |
| Notifiche | Locali, senza backend |
| Stato progetto | MVP personale/interno portfolio-ready |

### 3.2 Vincoli Di Prodotto

**Titolo sezione:** Vincoli che hanno guidato le decisioni

**Copy:**

Batch nasce come prodotto locale e personale, quindi molte decisioni sono state intenzionalmente restrittive: nessun account, nessun backend, nessuna community, nessuna automazione che completi gli step al posto dell'utente. Il valore doveva stare nella chiarezza operativa: sapere cosa richiede attenzione adesso, anche quando il piano originale cambia.

**Constraint cards:**

- **Local-first:** i dati restano sul dispositivo, con SwiftData.
- **No setup pesante:** niente account, onboarding esteso o cloud sync.
- **Affidabilità offline:** notifiche locali e contenuti guida in bundle.
- **iPhone-only:** interazione pensata per uso rapido, in cucina o durante una routine.
- **Italian-first:** etichette, seed data e guide allineate all'uso reale del prodotto.

### 3.3 Ricerca Practice-Led

**Titolo sezione:** Ricerca: modellare una pratica reale

**Copy:**

La ricerca è stata trattata come practice-led research: non una validazione di mercato ampia, ma un lavoro profondo sulla struttura operativa delle routine fermentative. Ho scomposto preparazioni, manutenzioni e momenti di controllo per capire dove una ricetta statica smette di essere utile e dove serve invece un sistema che riporti attenzione, priorità e stato.

**Fonti usate:**

- Esperienza diretta con lievito madre, impasti e kefir.
- Decomposizione dei workflow: piano, esecuzione, ritardi, rinnovi, cronologia.
- Product audit di strumenti adiacenti: ricettari, timer, note, app community.
- UAT e regression pass sui flussi principali.
- Scenari runtime deterministici in simulatore con dati operativi.

**Nota di rigore da inserire:**

Il caso non va presentato come una ricerca quantitativa o broad-market. La sua forza è la profondità del modello operativo: poche routine osservate bene, trasformate in regole di prodotto verificabili.

### 3.4 Domande Di Ricerca

**Titolo sezione:** Le domande che hanno orientato il progetto

**Domande:**

- Come può un'app dire chiaramente cosa richiede attenzione ora?
- Come separare il piano originale da quello che succede davvero durante l'esecuzione?
- Quando uno stato è un dato da salvare e quando è solo un'interpretazione UI?
- Come tenere insieme domini diversi, come impasti, starter e kefir, senza creare un generico archivio di ricette?
- In quali momenti la conoscenza è utile: prima, durante o dopo l'azione?

### 3.5 Insight

**Titolo sezione:** Dalle osservazioni alle decisioni

**Insight cards:**

1. **La domanda centrale non è "che ricetta uso?", ma "cosa devo fare adesso?"**
   - Decisione: `Oggi` diventa agenda operativa cross-domain, non dashboard passiva.

2. **Il piano e l'esecuzione reale devono restare separati.**
   - Decisione: gli orari pianificati convivono con `actualStart` e `actualEnd`.

3. **Un ritardo non è uno stato salvato, è una lettura del contesto.**
   - Decisione: overdue/late è derivato in UI, non persistito come status.

4. **I domini fermentativi condividono attenzione, ma non logica interna.**
   - Decisione: `Batch` è un hub estensibile, ma impasti, starter e kefir mantengono modelli specifici.

5. **La conoscenza serve quando supporta una decisione.**
   - Decisione: `Guide` resta browse/search, ma può apparire come supporto contestuale nell'azione.

6. **La fiducia nasce dagli edge case.**
   - Decisione: notifiche, deep link, archiviazione e fallback visibili diventano parte dell'esperienza prodotto.

### 3.6 Product Strategy

**Titolo sezione:** Strategia di prodotto

**Copy:**

La strategia di Batch è stata ridurre il prodotto alla sua promessa più utile: rendere visibili e azionabili routine che cambiano nel tempo. Per questo il progetto evita funzioni attraenti ma dispersive, come community, AI suggestion o cloud sync, e concentra il design su priorità, stato, azione e continuità locale.

**Principi:**

- Action-first, non dashboard-first.
- Una sola azione primaria per card.
- Campi avanzati dietro progressive disclosure.
- Stati derivati dai dati, non duplicati.
- Modelli specifici per dominio.
- Guide a supporto dell'azione, non centro del prodotto.
- Estendibilità solo quando un nuovo dominio ha regole operative chiare.

**Out of scope da mostrare:**

- Backend e account.
- Cloud sync.
- Community/social.
- AI suggestions.
- Auto-completamento degli step.
- Ricettario generico.
- Kombucha nel perimetro attuale, anche se è una possibile estensione futura.

---

## 4. Architettura UX

### 4.1 IA Finale

**Titolo sezione:** Architettura: da sezioni separate a hub operativo

**Copy:**

L'architettura iniziale separava i domini in aree autonome. La versione finale riduce la navigazione di primo livello a tre superfici: `Oggi`, `Batch` e `Guide`. Questo sposta il focus dalla categoria alla situazione: prima vedo cosa richiede attenzione, poi entro nel dominio specifico.

```text
Oggi
  Agenda operativa
  Card per dominio
  Stati empty / all-clear / future-only / actionable
  Nuova preparazione
  Supporto guide

Batch
  Impasti
  Starter
  Kefir
  Ricette

Guide
  Browse
  Categorie
  Ricerca
  Articoli
  Supporto contestuale
```

**Prima / dopo:**

| Prima | Dopo | Perché |
|---|---|---|
| `Oggi / Impasti / Starter / Knowledge` | `Oggi / Batch / Guide` | Meno frammentazione, più chiarezza sul ruolo di ogni area |
| Knowledge come tab tecnica | Guide come supporto leggibile | Etichetta italiana e più coerente con l'esperienza |
| Kefir come estensione secondaria | Kefir come dominio completo | Rinnovo, cronologia, archivio e confronto hanno logiche proprie |

### 4.2 Oggetti E Relazioni

**Titolo sezione:** Modellare il prodotto prima delle schermate

**Copy:**

Per evitare che Batch diventasse un archivio generico, il lavoro UX è partito dagli oggetti operativi: formula, preparazione, step, starter, rinnovo, batch di kefir, evento e guida. Ogni schermata espone solo una parte di questo modello, ma la coerenza nasce dalla relazione tra oggetti, stati e azioni.

**Diagramma da produrre:**

```text
RecipeFormula -> Bake -> BakeStep
Starter -> StarterRefresh
KefirBatch -> KefirEvent
KnowledgeItem -> relatedStepTypes / relatedStarterStates
```

**Annotazione chiave:**

Le guide non sono ricette salvate dall'utente: sono contenuti bundled che aiutano a interpretare passaggi, stati e concetti nel momento giusto.

---

## 5. Core Flows Da Mostrare

### 5.1 Oggi Agenda

**Goal:** mostrare il cuore del prodotto.

**Flow:**

```text
Apri Oggi
-> vedi cosa è in ritardo o richiede attenzione
-> apri la card del dominio
-> esegui l'azione primaria
-> torna a Oggi con priorità aggiornata
```

**Cosa evidenziare nelle callout:**

- `Cosa fare oggi` come promessa della schermata.
- Card raggruppate per dominio, non per tipo tecnico.
- Priorità: overdue/critical, oggi, attivo, prossimo.
- CTA `Nuova preparazione` sempre raggiungibile.

### 5.2 Nuova Preparazione

**Goal:** mostrare l'hub estensibile senza sembrare generico.

**Flow:**

```text
Nuova preparazione
-> scegli dominio
-> impasto / starter / kefir
-> entra nel flow specifico
```

**Decisione UX:**

Il selettore non è una lista di ricette. È un punto di ingresso ai diversi modelli operativi del prodotto.

### 5.3 Esecuzione Impasto

**Goal:** dimostrare la separazione tra piano ed esecuzione.

**Flow:**

```text
Crea preparazione da formula
-> timeline generata a ritroso dalla data target
-> step pending
-> start
-> complete / skip
-> eventuale shift della timeline
```

**Regole da annotare:**

- Gli step non si completano mai da soli.
- `actualStart` e `actualEnd` sono separati dalla pianificazione.
- Lo shift sposta solo step futuri e non terminali.

### 5.4 Starter Refresh

**Goal:** mostrare una routine frequente e veloce.

**Flow:**

```text
Starter due / overdue
-> apri dettaglio
-> log rinfresco
-> aggiorna lastRefresh
-> ricalcola prossimo stato
```

**Decisione UX:**

Il refresh deve essere più rapido di un form completo: i dettagli avanzati restano secondari.

### 5.5 Kefir Renewal, History, Archive

**Goal:** mostrare che Batch non è sourdough-only.

**Flow:**

```text
Kefico overdue
-> Rinfresca
-> evento registrato
-> cronologia aggiornata
-> eventuale nuovo batch derivato
-> archivio consultabile
-> confronto tra batch collegati
```

**Decisione UX:**

La cronologia kefir è automatic-first: l'utente non deve tenere un diario manuale per avere memoria operativa.

### 5.6 Guide Lookup

**Goal:** posizionare le guide come supporto, non come centro dell'app.

**Flow:**

```text
Guide
-> categorie / ricerca
-> articolo
-> eventuale richiamo contestuale da un'azione
```

**Decisione UX:**

Il contenuto editoriale aumenta fiducia quando risponde a un dubbio operativo, non quando obbliga l'utente a navigare prima di agire.

### 5.7 Notifiche E Deep Link

**Goal:** mostrare prodotto affidabile.

**Flow:**

```text
Notifica locale
-> tap
-> validazione entità live
-> dettaglio corretto
-> fallback visibile se l'oggetto non esiste più o non è raggiungibile
```

**Decisione UX:**

La notifica non è solo un reminder: è un punto di ingresso nel modello operativo. Per questo il routing deve gestire oggetti mancanti, archiviati o terminali.

---

## 6. Modelli Di Stato Da Visualizzare

### 6.1 Priorità Di Oggi

```text
1. Overdue / critical
2. Azioni previste oggi
3. Elementi attivi
4. Prossime azioni future
5. Supporto guide
```

**Copy breve:**

Oggi non ordina semplicemente per data: traduce stato, dominio e urgenza in una gerarchia di attenzione.

### 6.2 Step Lifecycle

```text
pending -> running -> done
pending -> skipped
running -> skipped
```

**Regola:**

Il tempo può rendere uno step in ritardo, ma non può completarlo. Il controllo resta all'utente.

### 6.3 Bake Derived Status

```text
cancelled: isCancelled == true
completed: tutti gli step sono done/skipped
in_progress: almeno uno step running o actualStart presente
planned: fallback
```

**Regola:**

Lo stato del bake si deriva dagli step e dai fatti salvati, evitando ridondanze che potrebbero divergere.

### 6.4 Kefir State

```text
lastManagedAt
storageMode
expectedInterval
plannedReactivation
archivedAt
events
```

**Regola:**

Il batch di kefir resta leggibile anche dopo l'archiviazione e può generare nuovi batch derivati.

---

## 7. Design System Story

### Titolo Sezione

Un sistema visivo legato al comportamento

### Copy

Il design system di Batch non cerca un'estetica rustica o laboratoriale. Usa un linguaggio nativo iOS, chiaro e leggero, dove colore, spaziatura e gerarchia indicano cosa fare, cosa è passato e cosa richiede attenzione.

### Semantica

| Colore | Significato | Uso |
|---|---|---|
| Verde | Azione, piano, attività corrente | CTA, stati attivi, percorsi primari |
| Neutro | Storico, archivio, secondario | Card passate, informazioni, azioni non primarie |
| Rosso | Ritardo, problema, rischio | Overdue, destructive, feedback ad alta priorità |

### Componenti Da Annotare

- **Oggi hero card:** promessa e conteggio agenda.
- **Operational card:** dominio, stato, orario, descrizione, azione primaria.
- **State badge:** stato leggibile a colpo d'occhio.
- **Batch hub tile:** dominio + sintesi operativa.
- **Kefir metric tiles:** stato, ultimo rinnovo, prossima azione.
- **Quick actions:** azioni secondarie senza competere con `Rinfresca`.
- **Guide row/search:** contenuto leggero, non editoriale invasivo.

### Principio UI Da Evidenziare

Ogni card deve avere una sola azione primaria visibile. Tutto il resto entra in dettaglio, sheet o azioni secondarie.

---

## 8. Iterazioni Da Raccontare

Usare 3-5 esempi, non tutta la roadmap.

### Esempio 1 - Oggi Da Dashboard A Agenda

**Prima:** una home troppo statica, utile per vedere informazioni ma non abbastanza forte nel dire cosa fare.

**Dopo:** `Oggi` diventa agenda cross-domain con priorità, card operative e ingresso rapido alla nuova preparazione.

**Perché conta:** il prodotto passa da archivio organizzato a strumento operativo.

### Esempio 2 - IA Da Domini Separati A Hub

**Prima:** `Oggi / Impasti / Starter / Knowledge`.

**Dopo:** `Oggi / Batch / Guide`.

**Perché conta:** il secondo tab non è una categoria singola, ma il contenitore dei batch e delle routine fermentative.

### Esempio 3 - Kefir Da Placeholder A Dominio

**Prima:** kefir trattato come rinnovo o estensione.

**Dopo:** batch detail, rinnovo, cronologia, archivio e confronto.

**Perché conta:** dimostra che l'architettura può accogliere nuovi domini senza diventare generica.

### Esempio 4 - Stato Derivato E Fiducia

**Prima:** rischio di stati salvati o routing fragile.

**Dopo:** overdue derivato in UI, validazione entità live, fallback visibili nei deep link.

**Perché conta:** l'affidabilità è parte dell'esperienza, non solo implementazione.

### Esempio 5 - Design System Hardening

**Prima:** componenti e stati non sempre allineati alla semantica operativa.

**Dopo:** verde/neutro/rosso legati a comportamento, card e CTA coerenti, parità runtime/portfolio.

**Perché conta:** il sistema visivo diventa una grammatica di prodotto.

---

## 9. Validazione E Outcome

### Titolo Sezione

Validare un prodotto locale-first

### Copy

La validazione di Batch ha combinato test automatici, scenari runtime deterministici e passaggi UAT sui flussi principali. L'obiettivo non era solo verificare che le schermate fossero corrette, ma che il prodotto restasse affidabile quando cambiano tempo, stato, notifiche e dati salvati.

### Evidenze Da Mostrare

- App avviata in simulatore con seed `operational`.
- Schermate runtime catturate dalla build reale.
- UAT completata sui flow principali.
- Regression pass su Today, routing, notifiche, kefir e design-system parity.
- Test su planner, modelli di stato, routing e flussi UI dove rilevante.

### Outcome

Batch ha raggiunto un modello local-first affidabile per routine fermentative: dati persistenti, stati derivati, notifiche locali, guide offline e un sistema visivo legato al significato operativo.

### Limiti Onesti

- Progetto personale/interno, non ricerca quantitativa di mercato.
- iPhone-only per scelta di scope.
- Nessun sync cloud nel perimetro attuale.
- Kombucha e altri domini sono estensioni possibili, non parte dello scope spedito.
- Le notifiche locali richiedono sempre verifica su device reale prima di distribuzione ampia.

---

## 10. Asset Da Produrre Per Rendere Il Caso Solido

### Priorità Alta

- Diagramma IA `Oggi / Batch / Guide`.
- Oggi priority model.
- Flow `Nuova preparazione -> dominio -> azione`.
- State diagram `BakeStep`.
- Kefir lifecycle: rinnovo, evento, archivio, derivazione, confronto.
- Annotazioni su `runtime-01-oggi-actionable.jpg`.
- Annotazioni su `runtime-05-kefir-detail.jpg`.

### Priorità Media

- Object model `RecipeFormula / Bake / BakeStep / Starter / KefirBatch / KefirEvent / KnowledgeItem`.
- Timeline shift flow.
- Deep-link fallback matrix.
- Before/after IA.
- Design-system component anatomy.

### Screenshot Mancanti Più Utili

- Kefir chronology.
- Kefir comparison.
- Starter detail + refresh.
- Bake detail with timeline.
- Step detail + shift timeline sheet.
- Guide article.
- Notification fallback/banner.

---

## 11. Microcopy Per Callout Schermate

### Oggi

- "La home non mostra tutto: ordina ciò che richiede attenzione."
- "Le card sono raggruppate per dominio, ma priorizzate per urgenza."
- "`Nuova preparazione` resta un ingresso rapido, non un percorso nascosto."

### Batch Hub

- "`Batch` raccoglie domini diversi senza appiattirli in un ricettario."
- "Impasti, Starter, Kefir e Ricette mantengono modelli specifici."
- "La struttura può estendersi ad altri fermentati solo quando hanno regole operative chiare."

### Kefico Detail

- "Lo stato overdue è una lettura derivata, non un valore salvato."
- "`Rinfresca` è l'azione primaria; cronologia, confronto e archivio restano secondari."
- "Metriche e azioni rapide rendono leggibile una routine ricorrente."

### Guide

- "Le guide supportano il momento operativo, non sostituiscono l'azione."
- "Categorie e search servono a recuperare conoscenza senza trasformare l'app in enciclopedia."

### New Preparation

- "Il selettore apre domini operativi, non semplici template."
- "Ogni dominio porta a un flow coerente con la sua routine."

---

## 12. Cosa Evitare Nel Caso Finale

- Non presentare Batch come app solo per lievito madre.
- Non usare `Knowledge` come label finale: usare `Guide`.
- Non usare `Fermentazioni` come tab finale se la UI shipped usa `Batch`.
- Non promettere kombucha come feature attuale.
- Non posizionare il progetto come ricerca quantitativa o validazione market-wide.
- Non mettere le schermate prima del ragionamento UX se l'obiettivo è un case da product designer.
- Non descrivere overdue come status salvato.
- Non suggerire auto-completamento degli step.

---

## 13. Inserimento Nella Pagina Esistente

### Dove Inserire

1. Dopo "Il Progetto": aggiungere ruolo/scope/vincoli.
2. Dopo "Il problema": aggiungere ricerca practice-led e domande di ricerca.
3. Dopo "La soluzione": aggiungere insight e product strategy.
4. Sostituire "Architettura dell'app" con IA aggiornata + before/after.
5. Espandere "UX/UI" in design system + interaction principles.
6. Prima di "Risultato": aggiungere iterazione/UAT e validazione.

### Titoli Raccomandati

- `Il lavoro di product design`
- `Ricerca e definizione del problema`
- `Insight e principi di prodotto`
- `Architettura UX`
- `Flussi, stati e regole operative`
- `Sistema visivo`
- `Iterazioni e validazione`
- `Risultato e limiti`

