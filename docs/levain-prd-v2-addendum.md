# Levain v2 — PRD Addendum
## Decisioni integrative per PRD definitiva

**Versione:** 1.0  
**Stato:** definitivo  
**Da usare insieme a:** `levain_v_2_prd_ux_multi_fermentations.md`

Questo documento chiude tutti i nodi aperti identificati in fase di review della PRD v2 e va considerato parte integrante della specifica.

---

## A1. Navigazione verso il verticale pane — mitigazione regressione

### Problema
La nuova struttura Preparazioni → Pane e LM → Impasti introduce un livello di navigazione extra rispetto alla v1. Per un utente bread-first questo è un downgrade percepito.

### Decisione
Il deep link da Oggi bypassa la gerarchia.

Un tap su qualsiasi card pane o starter in Oggi porta direttamente al dettaglio dell'oggetto, senza passare per Preparazioni → hub Pane.

La gerarchia completa (Preparazioni → Pane e LM → Impasti) serve per esplorazione e creazione, non per l'uso operativo quotidiano.

### Regola implementativa
Ogni card in Oggi deve avere un deep link diretto all'oggetto sottostante.
Il router deve supportare navigazione diretta a:
- dettaglio impasto
- dettaglio starter
- dettaglio batch kefir

senza richiedere il traversal della tab Preparazioni.

---

## A2. Struttura di Oggi — revisione del modello a priorità

### Problema
La PRD originale definisce quattro sezioni ordinate: Adesso / Più tardi oggi / Da controllare / Domani. Questa struttura è troppo rigida e non riflette l'uso reale.

### Decisione
Oggi è una **dashboard operativa giornaliera**, non una to-do board a bucket fissi.

Tutto ciò che è attivo è visibile. L'urgenza è comunicata visivamente sulla card, non tramite separazione in sezioni fisse.

### Contenuto di Oggi

**Sempre visibili se presenti:**
- Batch kefir fuori frigo con stato e ore/minuti al prossimo rinfresco
- Tutti gli starter attivi con indicazione giorni al prossimo rinfresco
- Impasti attivi con step corrente e stato

**Ordinamento:**
1. Oggetti overdue o in warning critico
2. Oggetti da gestire oggi
3. Oggetti attivi senza urgenza immediata (panoramica)

Nessuna sezione "Da controllare" come categoria separata. L'urgenza è un attributo della card, non un filtro strutturale.

### Principio
L'utente apre l'app e vede immediatamente lo stato di tutto ciò che è vivo, con chiarezza visiva sull'urgenza relativa.

---

## A3. Notifiche kefir — valori default

### Decisione
Valori di default per i reminder, modificabili dall'utente per ogni batch:

| Storage mode | Window default | Comportamento |
|---|---|---|
| `room_temperature` | 24 ore | Warning a 4h, overdue dopo 24h |
| `fridge` | 7 giorni | Warning a 1 giorno, overdue dopo 7 giorni |
| `freezer` | Nessun alert automatico | Nessuna notifica a meno di riattivazione pianificata dall'utente |

### Regola
La severità del badge e del microcopy in Oggi dipende dallo storage mode del batch.

Un batch fuori frigo overdue è rosso e urgente.  
Un batch in frigo overdue è arancione e meno aggressivo.  
Un batch in freezer non mostra mai stato di urgenza automatico.

---

## A4. Quick actions in root Preparazioni

### Decisione
Le quick actions sono sempre visibili nella root di Preparazioni.

Le tre azioni esposte:
- `Nuovo impasto`
- `Nuovo starter`
- `Nuovo batch kefir`

### Regola
Le quick actions devono essere compatte e non rubare spazio alle card hub.  
Posizionate preferibilmente in una fascia orizzontale scrollabile o come bottoni secondari sotto i titoli delle card hub.

---

## A5. Empty state hub Milk kefir — prima apertura

### Decisione
L'utente che apre per la prima volta l'hub Milk kefir vede un empty state con:

- Titolo: **Nessun batch attivo**
- Descrizione breve: **Avvia il tuo primo batch di milk kefir per iniziare a tracciare la routine.**
- CTA primaria: `Nuovo batch`

Non viene richiesta la creazione di una coltura prima del batch. L'utente può creare un batch direttamente. Il collegamento alla coltura è opzionale e può avvenire in seguito.

---

## A6. Journal — asimmetria dichiarata tra pane e kefir

### Decisione
Il journal strutturato esiste solo nel verticale kefir.

Il verticale pane usa lo storico bake già esistente come memoria degli impasti passati. Non viene introdotto un journal dedicato per il pane in v2.

### Conseguenza
- Kefir: journal con log eventi tipizzati (sezione 16 della PRD)
- Pane: storico bake con stati completato/archiviato come già oggi
- Questa asimmetria è intenzionale e non va colmata in v2

---

## A7. Empty state card hub in Preparazioni

### Problema non affrontato dalla PRD originale
Cosa mostra la card hub quando non ci sono oggetti attivi in quel verticale?

### Decisione

**Card hub Pane e LM — empty state:**
- Contatore: `0 impasti attivi`
- CTA sulla card: `Nuovo impasto`

**Card hub Milk kefir — empty state:**
- Contatore: `0 batch attivi`
- CTA sulla card: `Nuovo batch`

In entrambi i casi la card hub resta visibile anche vuota. Non sparisce mai dalla root Preparazioni.

---

## A8. Migrazione schema v1 → v2

### Problema non affrontato dalla PRD originale
La ristrutturazione della tab bar e l'aggiunta dei nuovi modelli kefir richiedono una versione schema SwiftData aggiornata.

### Regola
- I modelli esistenti (Bake, BakeStep, Starter, StarterRefresh, RecipeFormula, KnowledgeItem, AppSettings) restano invariati nella v2
- I nuovi modelli kefir (KefirBatch, KefirCulture, KefirEvent) sono aggiunte, non modifiche
- La migrazione v1 → v2 è classificata come migrazione additive: nessun dato esistente viene toccato
- Va implementata con VersionedSchema prima di qualsiasi rilascio che includa i nuovi modelli

### Collocazione nella roadmap
La migration plan va preparata nella Phase A, prima di toccare il data layer, anche se i nuovi modelli entrano solo dalla Phase C.

---

## A9. Tiebreaker ordinamento in Oggi

### Regola
Quando più oggetti hanno la stessa urgenza, l'ordinamento è:

1. Oggetti overdue → per tempo di scadenza, prima il più vecchio
2. Oggetti in warning → per tempo rimanente, prima il più vicino alla scadenza
3. Oggetti attivi senza urgenza → per ultimo aggiornamento, prima il più recente

In caso di parità tra domini diversi (pane vs starter vs kefir), non esiste priorità di dominio: conta solo il tempo.

---

## Riepilogo decisioni per implementazione

| Nodo | Decisione |
|---|---|
| Navigazione pane | Deep link da Oggi, bypass gerarchia |
| Struttura Oggi | Dashboard operativa, tutto visibile, urgenza sulla card |
| Notifiche kefir default | 24h temp ambiente, 7gg frigo, nessun alert freezer |
| Quick actions Preparazioni | Sempre visibili |
| Empty state kefir primo avvio | CTA Nuovo batch, no coltura obbligatoria prima |
| Journal | Strutturato solo kefir, pane usa storico bake |
| Empty state card hub | Card sempre visibili anche vuote, con CTA inline |
| Migrazione schema | Additive, VersionedSchema in Phase A |
| Tiebreaker ordinamento | Time-based, nessuna priorità di dominio |

---

*Addendum approvato. Da usare insieme alla PRD v2 principale come specifica definitiva per l'implementazione.*
