# Phase 13: MVP Closure — Context

**Gathered:** 2026-03-12
**Status:** Ready to execute

<domain>
## Phase Boundary

Phase 13 chiude l'MVP senza aprire nuovo scope. Non aggiunge macro-feature: stabilizza il loop principale, rende la Home davvero operativa, completa il manual UAT su device reale, e porta l'app al livello di fiducia e leggibilità necessario per considerare l'MVP definitivamente chiuso.

I sei flow operativi definiti in Phase 12 sono la baseline. Phase 13 li porta su device reale e rifinisce gli attriti residui di copy, empty state, esecuzione bake, notifiche, starter flow e micro-UX.

</domain>

<decisions>
## Implementation Decisions

### Priorità bloccanti

- Manual UAT su iPhone reale è la priorità assoluta: finché non è completata l'MVP non è chiuso.
- La Home deve rispondere alla domanda "cosa devo fare adesso o oggi?" — non deve mai risultare solo decorativa.
- Le notifiche devono reggere tutti gli scenari: warm launch, cold launch, entità mancante, entità terminale.

### Home / Today

- I quattro stati (`firstLaunch`, `allClear`, `futureOnly`, `actionable`) devono essere visivamente e operativamente distinti.
- La densità informativa deve permettere all'utente di capire in un colpo d'occhio urgenze, agenda di oggi, e stato dello starter.
- Il tip contestuale compare solo negli stati vuoti, mai come riempitivo.

### Bake execution

- L'esecuzione sequenziale è il comportamento di default; il recovery fuori ordine resta accessibile ma non ambiguo.
- Il feedback "Fuori ordine" deve essere persistente senza sembrare un errore dell'app.
- Lo step attivo deve essere sempre l'elemento più evidente nella lista.

### Notifiche e deep link

- Il reschedule delle notifiche deve avvenire dopo ogni creazione bake, shift timeline, o modifica starter.
- Il fallback se l'entità non esiste deve essere non bloccante: toast transiente + tab safe.

### Starter flow

- Obiettivo: log refresh in ≤ 2 tap / < 30 secondi.
- Lo stato dello starter nella Home deve essere leggibile senza aprire la tab Starter.

### Naming e copy

- Nessun termine doppio per la stessa cosa.
- CTA sempre con verbi chiari.
- Tono uniforme in tutti gli empty state.
- Date e localizzazione italiana verificate.

### Empty states

- Ogni empty state ha una CTA utile e spiega il valore della sezione.
- Il primo avvio spiega il modello dell'app in pochi secondi.

### Micro-UX

- Solo interventi rapidi: toast/banner, haptics, stati disabled, conferme post-azione.
- Nessuna nuova fase di design.

</decisions>

<specifics>
## Specific Ideas

- La Home nel stato `allClear` deve rassicurare, non sembrare rotta.
- Il recovery fuori ordine deve comunicare "hai scelto di deviare" non "qualcosa è andato storto".
- Il log refresh starter deve preferire valori precompilati (ratio default, peso standard) per ridurre l'attrito.
- Il toast di fallback notifica deve apparire solo una volta e non bloccare la navigazione.

</specifics>

<deferred>
## Deferred (fuori scope Phase 13)

- Auth, sync cloud, backup/export
- Macro-feature nuove di qualsiasi tipo
- Analytics avanzate
- Espansione knowledge base
- iPad layout
- Localizzazione non italiana

</deferred>

---

_Phase: 13-mvp-closure_  
_Context gathered: 2026-03-12_
