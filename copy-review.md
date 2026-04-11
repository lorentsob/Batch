# Copy Review — Batch / Levain
_Generato 2026-04-10. Tutto il copy visibile all'utente, ordinato per sezione._

---

## Come leggere questo documento

- Ogni sezione corrisponde a una schermata o un dominio funzionale.
- I blocchi `> ⚠️` segnalano problemi rilevati.
- La sezione **Feedback e proposte** alla fine riassume tutto per priorità.

---

## 1. Navigazione principale (tab bar)

| Elemento | Copy attuale |
|---|---|
| Tab 1 | Oggi |
| Tab 2 | Batch |
| Tab 3 | Guide |

> ⚠️ **Incoerenza di registro**: "Oggi" e "Guide" sono italiani, "Batch" è inglese. Il termine "Batch" compare anche come nome del secondo tab e come titolo dell'app stessa (display name), il che crea ambiguità: l'utente non sa se sta navigando in una sezione o guardando il nome dell'app.

---

## 2. Today — Schermata principale

### Titoli e subtitle
| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Cosa fare oggi |
| Badge contatore | {N} in agenda |
| Badge impasti | {N} impasti attivi |

### Empty state (sezioni disattivate)
| Elemento | Copy attuale |
|---|---|
| Titolo empty | Nessuna sezione attiva |
| Corpo | Attiva almeno una sezione (Impasti, Starter o Kefir) dalle impostazioni per iniziare a usare Levain. |
| CTA | Apri impostazioni |

> ⚠️ **Nome prodotto esposto**: Il copy menziona "Levain" (nome interno) invece di "Batch" (nome pubblico).

### Menu "Nuova preparazione"
| Elemento | Copy attuale |
|---|---|
| Voce principale | Nuova preparazione |
| Sottovoci | Nuovo impasto / Nuovo starter / Nuovo batch kefir |

> ⚠️ **Inconsistenza terminologica**: "Nuovo batch kefir" usa "batch" ma "Nuovo impasto" non usa mai "batch". Sarebbe più uniforme "Nuovo kefir" o usare "batch" per tutto.

### Card fase attiva (TodayStepCardView / ActiveStepHeroCard)

#### Label urgenza
| Stato | Copy attuale |
|---|---|
| Overdue | In ritardo |
| Warning | Da fare |
| Active | Oggi |
| Preview | Domani |

> ⚠️ **Ambiguità "Da fare"**: Questo label viene usato sia come stato urgenza del Today sia come stato della fase (`StepStatus.pending.title = "Da fare"`). Usare lo stesso testo per due concetti diversi (urgenza temporale vs stato della fase) può generare confusione.

#### Chip metriche
| Etichetta | Copy attuale |
|---|---|
| Ora di inizio | Inizio |
| Durata pianificata | Durata |
| Fine / Finestra | Fine / Finestra |

#### Timer block
| Fase | Headline | Label trailing |
|---|---|---|
| Upcoming | Parte tra | Attesa |
| Running | Tempo residuo | Trascorso |
| Overdue | Ritardo accumulato | Ritardo |
| Completed | Fase completata | Esito |

> ⚠️ **"Parte tra" / "Attesa"**: il trailing metric in fase upcoming vale esattamente come il valore principale — mostra la stessa informazione due volte.

#### Pill di stato
| Fase | Copy attuale |
|---|---|
| Upcoming | Programmata |
| Running | In corso |
| Overdue | In ritardo |
| Completed | Completato |

#### Riga dettaglio (detailLine)
| Fase | Copy attuale |
|---|---|
| Upcoming (standard) | Inizio {ora}  ·  Fine {ora} |
| Upcoming (window) | Finestra: {ora} – {ora} |
| Running (standard) | Avviato {ora}  ·  Fine finestra alle {ora} |
| Running (window non aperta) | In corso · Inizio finestra alle {ora} |
| Overdue | Chiusura finestra alle {ora} |
| Completed | Fase chiusa alle {ora}. / Fase chiusa. |

#### Pulsanti azione
| Azione | Copy attuale |
|---|---|
| Avvia fase | Avvia fase |
| Completa fase | Completa fase |
| Dettaglio procedimento | Procedimento |
| Sposta orari (apri sheet) | Sposta |
| Badge quick shift | Sposta rapidamente gli orari |
| Preset quick shift | +15 min / +30 min / +1 h / -15 min / -30 min |
| Personalizzato | Personalizzato |

#### Badge stato nella timeline (StepTimelineRow)
| Stato | Copy attuale |
|---|---|
| Archiviata (bake cancellata) | Archiviata |
| Terminal done/skipped | (da StepStatus.title) |
| Overdue | In ritardo |
| Out of order | Fuori ordine |

#### Riga status (statusLine) 
| Stato | Copy attuale |
|---|---|
| Bake annullato | Impasto annullato — fase non piu attiva |
| Pending overdue | Scaduto alle {ora} |
| Pending normale | {data/ora smart} |
| Running (window) | Finestra dalle {data/ora} |
| Running normale | Iniziato alle {ora} |
| Done con ora | Completato alle {ora} |
| Done senza ora | Completato |
| Skipped con ora | Saltato alle {ora} |
| Skipped senza ora | Saltato |

> ⚠️ **Errore ortografico**: `"fase non piu attiva"` — manca l'accento su **più**.

> ⚠️ **Inconsistenza**: "fase" vs "passaggio" — vedi nota generale alla fine.

### Today — Starter reminder row
Il testo del titolo e sottotitolo viene da `TodayAgendaItem.title` / `.subtitle` / `.state` / `.actionTitle` (costruiti in `TodayAgendaBuilder`).

---

## 3. Impasti (BakesView)

### Titoli
| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Impasti |
| Subtitle | I tuoi impasti attivi o in programma |
| Sezione attivi | Impasti attivi |
| Badge | {N} attivi / {N} ricette |
| CTA principale | Nuovo impasto |

### Empty state
| Elemento | Copy attuale |
|---|---|
| Titolo | Nessun impasto ancora |
| Corpo | Scegli una ricetta e crea il tuo primo impasto |

### Card ricette
| Elemento | Copy attuale |
|---|---|
| Titolo card | Le tue ricette |
| Corpo | Consulta le ricette e creane di nuove |

### Archivio impasti
| Elemento | Copy attuale |
|---|---|
| Titolo sheet | Archivio impasti |
| Filtri | Tutti / Completati / Annullati |
| Empty globale — titolo | Nessun impasto in archivio |
| Empty globale — corpo | Qui trovi gli impasti completati o annullati. Archivia un impasto dalla lista principale per vederlo qui. |
| Empty globale — CTA | Chiudi |
| Empty filtro | Nessun impasto per questo filtro. |
| Badge | Completato / Annullato |
| Toolbar | Seleziona / Deseleziona / Elimina selezionati |
| Swipe | Elimina / Ripristina |

---

## 4. Dettaglio impasto (BakeDetailView)

| Elemento | Copy attuale |
|---|---|
| Label fase attiva | Fase attiva |
| Timeline archiviata | Timeline archiviata |
| Titolo sezione timeline | Timeline / Ricetta step by step |
| Nessuna fase successiva — titolo | Nessun'altra fase da seguire. |
| Nessuna fase successiva — corpo | Quando chiudi la fase corrente, la prossima comparirà qui. |
| Badge contatore fasi | Fasi |
| Azione annulla | Annulla impasto |
| Azione elimina | Elimina impasto |

> ⚠️ **"Ricetta step by step"**: mix italiano/inglese. Il resto dell'app usa "Timeline" o "Fasi".

---

## 5. Dettaglio fase (BakeStepDetailView)

### Sezioni
| Titolo sezione | Copy attuale |
|---|---|
| Ingredienti | Ingredienti |
| Procedimento | Procedimento |
| Timing | Timing |
| Obiettivi | Obiettivi qualitativi |
| Esecuzione | Esecuzione |

### Campi timing
| Etichetta | Copy attuale |
|---|---|
| Ora pianificata | Pianificato |
| Durata pianificata | Durata pianificata |
| Inizio finestra | Inizio finestra |
| Fine finestra | Fine finestra |
| Inizio reale | Inizio reale |
| Fine reale | Fine reale |

### Campi qualità
| Etichetta | Copy attuale |
|---|---|
| Temperatura | Temperatura |
| Target volume | Target volume |

### Pulsanti
| Azione | Copy attuale |
|---|---|
| Avvia | Avvia fase |
| Completa | Completa fase |

> ⚠️ **"Timing"** è inglese in un contesto altrimenti italiano. "Tempi" o "Orari" sarebbero più coerenti.

> ⚠️ **"Target volume"**: mix. Potrebbe essere "Volume target" (già usato altrove) o "Obiettivo volume".

---

## 6. Sposta orari (ShiftTimelineView)

| Elemento | Copy attuale |
|---|---|
| Titolo navigazione | Sposta gli orari |
| Sezione selezionata | Fase selezionata |
| Descrizione | Sposterai la fase selezionata e tutte le fasi successive non completate. |
| Sezione spostamento | Spostamento |
| Stepper | Sposta di: {N} min |
| Bottone conferma | Applica |
| Bottone annulla | Chiudi |

---

## 7. Creazione impasto (BakeCreationView)

| Elemento | Copy attuale |
|---|---|
| Sezione ricetta | Ricetta |
| Picker | Ricetta |
| Sezione pianificazione | Pianificazione |
| Campo nome (opzionale) | Nome impasto (opzionale) |
| Label target | Quando vuoi sfornare |

---

## 8. Ingredienti impasto (BakeIngredientsView)

| Etichetta | Copy attuale |
|---|---|
| Sezione | Baker's math |
| Farina | Farina |
| Acqua | Acqua |
| Idratazione | Idratazione |
| Porzioni | Porzioni |
| Sale | Sale |

> ⚠️ **"Baker's math"**: È un termine tecnico inglese usato intenzionalmente (come nel mondo della panificazione). È accettabile se il target conosce il gergo. Controllare se appare solo qui o anche altrove (es. KnowledgeCategory).

---

## 9. Ricette (FormulaListView)

| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Ricette |
| Subtitle | Consulta le ricette e creane di nuove |
| Badge | {N} ricette / {N} personali |
| CTA | Nuova ricetta |
| Empty — titolo | Nessuna ricetta |
| Empty — corpo | Le ricette di sistema appariranno al prossimo avvio. |
| Sezione archivio | Archivio ricette |
| Badge ricetta | Mia ricetta / Modificata |
| Metriche card | Lievito / Idratazione / Porzioni |
| Swipe | Archivia |

### Archivio ricette
| Elemento | Copy attuale |
|---|---|
| Titolo sheet | Archivio ricette |
| Empty — titolo | Archivio vuoto |
| Empty — corpo | Scorri a sinistra su una ricetta per archiviarla. |
| Empty — CTA | Chiudi |
| Badge | Mia ricetta / {N}% idr. |
| Toolbar | Seleziona tutto / Deseleziona / Elimina selezionati |
| Swipe | Ripristina / Elimina |

---

## 10. Editor ricetta (FormulaEditorView)

| Elemento | Copy attuale |
|---|---|
| Sezione identità | Identità |
| Campo nome | Nome della ricetta |
| Placeholder nome | es. Pane di Segale |
| Picker tipo | Tipo |
| Stepper porzioni | Porzioni: {N} |
| Sezione ingredienti | Ingredienti |
| Campo farina | Farina totale (g) |
| Campo acqua | Acqua totale (g) |
| Campo sale | Sale (g) |
| Picker lievito | Agente lievitante |
| Campo inoculo (sourdough) | Inoculo starter (%) |
| Campo lievito (commerciale) | Quantità lievito (%) |

> ⚠️ **"Inoculo starter (%)"**: "inoculo" è un termine tecnico/scientifico. Gli utenti più pratici capiscono, ma "% starter" o "Quantità starter (%)" sarebbe più accessibile. Valutare in base all'utente target.

---

## 11. Dettaglio ricetta (FormulaDetailView)

| Elemento | Copy attuale |
|---|---|
| Titolo navigazione | Ricetta |
| Error state | Ricetta non trovata |

---

## 12. Starter (StarterView)

| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Starter |
| Subtitle | Controlla i tuoi starter |
| CTA | Aggiungi starter |
| Empty — titolo | Nessuno starter ancora |
| Empty — corpo | Aggiungi il tuo lievito madre per tracciare i rinfreschi, calcolare il prossimo e ricevere promemoria al momento giusto. |
| Sezione archiviati | Archiviati |
| Swipe | Archivia / Ripristina |
| Context menu | Modifica / Archivia / Ripristina |

> ⚠️ **"Controlla i tuoi starter"**: "controlla" è un po' generico. "Gestisci i tuoi starter" o "I tuoi starter" sarebbe più preciso.

---

## 13. Dettaglio starter (StarterDetailView)

| Elemento | Copy attuale |
|---|---|
| Sezione log | Log rinfreschi |
| Descrizione sezione | Registro dei rinfreschi passati con dosi, tempi e note. |
| Empty log | Ancora nessun rinfresco registrato. |
| Pulsante log completo | Tutti i rinfreschi |
| Sezione impasti collegati | Impasti collegati |

---

## 14. Editor starter (StarterEditorView)

| Elemento | Copy attuale |
|---|---|
| Sezione | Identità / Setup / Mix Farine |
| Campo nome | Nome dello starter |
| Placeholder nome | es. Ciccio |
| Campo idratazione | Idratazione (%) |
| Campo peso contenitore | Peso contenitore (g) |
| Picker conservazione | Conservazione |
| Label intervallo | Intervallo rinfresco: {N} giorni |
| Toggle promemoria | Promemoria attivi |
| CTA aggiungi farina | Aggiungi farina |
| Warning farine | Attenzione: il totale è {N}% (dovrebbe essere 100%) |

---

## 15. Log rinfresco (RefreshLogView)

| Elemento | Copy attuale |
|---|---|
| Titolo navigazione | Log rinfresco |
| Toolbar | Chiudi / Salva |
| Sezione pesi | Pesi |
| Campo farina | Farina (g) |
| Campo acqua | Acqua (g) |
| Campo starter usato | Starter usato (g) |
| Sezione dettagli | Dettagli |
| Campo data/ora | Quando |
| Campo rapporto | Rapporto |
| Campo temp. ambiente | Fuori frigo (°C) |
| Sezione farine | Mix Farine |
| CTA aggiungi farina | Aggiungi farina |
| Sezione frigo | Passaggio in frigo |
| Toggle frigo immediato | Messo subito in frigo |
| DatePicker frigo | Messo in frigo alle |
| Sezione note | Note |
| Campo note | Note sul rinfresco |
| Warning farine | Attenzione: il totale è {N}% (dovrebbe essere 100%) |
| Toast conferma | Rinfresco salvato per {nome} |

> ⚠️ **"Fuori frigo (°C)"**: il label suggerisce temperatura ambiente, ma il nome è ambiguo — potrebbe essere letto come "temperatura dello starter fuori frigo". Qualcosa come "Temp. ambiente (°C)" o "Temperatura locale (°C)" è più chiaro.

> ⚠️ **"Passaggio in frigo"**: "passaggio" qui significa "trasferimento", non "fase". Rischio confusione con il termine "passaggio/fase" usato altrove. Alternativa: "In frigo" o "Messa in frigo".

> ⚠️ **"Log rinfresco"** / **"Log rinfreschi"**: "log" è un termine tecnico/inglese. L'app alterna "log" (titolo) e "registro" (nella descrizione della sezione). Scegliere uno solo.

---

## 16. BreadHub (BreadHubView)

| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Pane e lievito madre |
| Subtitle | Impasti attivi e i tuoi starter. |
| Sezione impasti | Impasti attivi |
| Empty impasti — titolo | Nessun impasto attivo |
| Empty impasti — corpo | Scegli una ricetta e crea il tuo primo impasto |
| CTA impasto | Nuovo impasto |
| Sezione starter | Starter |
| Empty starter — titolo | Nessuno starter ancora |
| Empty starter — corpo | Aggiungi il tuo lievito madre per tracciare i rinfreschi e ricevere promemoria. |
| CTA starter | Aggiungi starter |
| Label utilizzo | Utilizzo |
| Label prossima fase | Prossima fase |
| Sezione ricette | Ricette |
| Context menu | Modifica |

---

## 17. Fermentations hub (FermentationsView)

| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Batch |
| Subtitle | I tuoi batch attivi. |
| Empty — titolo | Nessuna sezione attiva |
| Empty — corpo | Attiva le sezioni dalle impostazioni. |
| Empty — CTA | Apri impostazioni |
| Menu | Nuova preparazione |
| Tile impasti | Impasti |
| Tile starter | Starter |
| Tile kefir | Kefir |
| Tile ricette | Ricette |
| Subtile impasti | {N} in corso |
| Subtile starter | {N} gestiti |
| Subtile ricette | {N} salvate |
| Subtile kefir | {N} in corso / {N} in pausa |
| Subtile kefir da rinnovare | {N} da rinnovare |
| Empty tile impasti | Crea un impasto |
| Empty tile starter | Aggiungi starter |
| Empty tile kefir | Crea batch |
| Empty tile ricette | Aggiungi ricetta |
| Toolbar | Impostazioni |

> ⚠️ **"I tuoi batch attivi."** con punto finale: il punto in una subtitle breve è insolito e incoerente con altri subtitle dell'app (alcuni terminano con punto, altri no — vedi la sezione coerenza punteggiatura sotto).

---

## 18. Kefir hub (KefirHubView)

| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Kefir |
| Subtitle | I tuoi batch di Kefir. |
| Empty — titolo | Nessun batch attivo |
| Empty — corpo | Quando avvii il primo batch lo trovi qui. |
| CTA | Nuovo batch |
| Badge urgenza | {N} da seguire / {N} in corso / {N} in pausa / {N} archiviato/i |
| Sezione cronologia | Cronologia batch |
| Descrizione cronologia | Tieni traccia dei rinfreschi dei tuoi batch |
| Bottone cronologia | Apri cronologia |

> ⚠️ **"I tuoi batch di Kefir."**: "Kefir" con K maiuscola nel mezzo del subtitle. Altrove è "kefir" minuscolo. Uniformare.

> ⚠️ **"Tieni traccia dei rinfreschi dei tuoi batch"**: usa "rinfreschi" per il kefir, ma il termine corretto per il kefir è "rinnovi" o "gestioni". "Rinfresco" è specifico per il lievito madre.

---

## 19. Editor kefir batch (KefirBatchEditorView)

| Elemento | Copy attuale |
|---|---|
| Titolo nuovo | Nuovo batch |
| Titolo derivato | Crea derivato |
| Bottone crea | Crea |
| Toolbar | Chiudi |
| Sezione identità | Identità |
| Campo nome | Nome batch |
| Placeholder nome | es. Batch cucina |
| Picker conservazione | Conservazione |
| Label routine | Routine attesa |
| Toggle riattivazione | Pianifica riattivazione |
| DatePicker riattivazione | Data riattivazione |
| Sezione contesto | Contesto |

---

## 20. Gestione kefir batch (KefirBatchManageSheet)

| Elemento | Copy attuale |
|---|---|
| Titolo navigazione | Gestisci batch |
| Toolbar | Chiudi / Salva |
| Sezione azione immediata | Azione immediata |
| Bottone rinnova | Rinnova |
| Bottone riattiva | Riattiva adesso |
| Hint rinnova | Segna il rinnovo adesso. |
| Hint riattiva | Riporta il batch in attività. |
| Footer conservazione | Ogni modifica ricalcola la scadenza del prossimo rinnovo. |
| Picker conservazione | Conservazione |
| Stepper routine | Routine attesa |
| Toggle riattivazione | Pianifica riattivazione |
| DatePicker riattivazione | Data riattivazione |

### Toast banner
| Azione | Copy attuale |
|---|---|
| Riattivazione | Batch riattivato |
| Rinnovo | Gestione aggiornata a ora |
| Salva | Conservazione aggiornata |

> ⚠️ **"Gestione aggiornata a ora"**: suona strano. "Rinnovo registrato" o "Rinnovo salvato" sarebbero più chiari.

---

## 21. Dettaglio kefir batch (KefirBatchDetailView)

| Elemento | Copy attuale |
|---|---|
| Alert archivia — titolo | Archivia batch |
| Alert archivia — corpo | Il batch resta leggibile in archivio. Puoi sempre crearne uno nuovo a partire da questo. |
| Alert archivia — bottons | Annulla / Archivia |
| Sezione note | Note e dettagli |
| Badge origine | Origine |
| Badge derivati | Derivati |
| Badge uso | Come si usa |

---

## 22. Knowledge / Guide (KnowledgeView)

| Elemento | Copy attuale |
|---|---|
| Titolo schermata | Guide |
| Subtitle | Tutto sulla fermentazione |
| Badge risultati | {N} risultati |
| Pill tutto | Tutti |
| Empty — titolo | Nessun risultato |
| Empty — corpo | Prova a modificare la ricerca o rimuovere il filtro per categoria. |
| Empty — CTA | Mostra tutte le guide |
| Placeholder ricerca | Cerca guide e consigli |

---

## 23. Impostazioni (SettingsView)

| Elemento | Copy attuale |
|---|---|
| Titolo navigazione | Impostazioni |
| Toolbar | Chiudi |
| Sezione sezioni | Sezioni attive |
| Descrizione sezioni | Attiva o disattiva le sezioni. Le sezioni disattivate non compaiono in Oggi o in Batch. |
| Toggle impasti | Impasti |
| Toggle starter | Starter (lievito madre) |
| Toggle kefir | Kefir |
| Sezione backup | Backup |
| Descrizione backup | Esporta o ripristina solo i dati utente. Knowledge e template di sistema restano nel bundle dell'app. |
| Bottone esporta | Esporta backup |
| Bottone importa | Importa backup |
| Sezione contenuto | Contenuto incluso |
| Descrizione contenuto | Starter, rinfreschi, ricette salvate, impasti e fasi. |
| Nota esclusioni | Non include knowledge, template di sistema o flag tecnici interni. |
| Alert importa — titolo | Sostituire i dati correnti? |
| Alert importa — corpo | L'import sostituirà starter, ricette, impasti e fasi attuali con il contenuto del backup selezionato. |
| Alert importa — buttons | Annulla / Importa |
| Alert errore | Operazione non riuscita |
| Toast successo esporta | Backup pronto per l'esportazione. |
| Toast successo importa | Backup importato. Notifiche riallineate. |

> ⚠️ **"Knowledge"** compare due volte nel copy delle impostazioni come termine inglese (es. "Knowledge e template di sistema", "Non include knowledge…"). Scegliere una traduzione coerente (es. "guide", "contenuti") o usare sempre il termine in italiano.

> ⚠️ **"flag tecnici interni"**: questo è un termine da sviluppatore, non dovrebbe essere visibile all'utente nella UI.

---

## 24. Notifiche push

### Rinfresco starter
| Campo | Copy attuale |
|---|---|
| Titolo | {nome dello starter} |
| Corpo (giorno previsto, ore 9:00) | Oggi è previsto un rinfresco. Apri lo starter per registrarlo. |
| Corpo (follow-up +24h) | Non hai ancora registrato il rinfresco di oggi. Apri lo starter per farlo adesso. |

### Fasi impasto
| Tipo | Titolo | Corpo |
|---|---|---|
| Reminder step | {nome fase} · {nome impasto} | Se running: "Questo passaggio è in corso. Apri l'impasto per aggiornarlo." |
| Reminder step | {nome fase} · {nome impasto} | Se pending: "È il momento di intervenire su questo passaggio. Apri l'impasto per continuare." |
| Window open | {nome fase} · {nome impasto} | "Il tuo impasto è pronto per il prossimo passaggio. Aprilo per continuare." |
| Window close | {nome fase} · {nome impasto} | "La finestra utile sta per chiudersi. Apri l'impasto se devi intervenire ora." |

> ⚠️ **Inconsistenza "passaggio" vs "fase"**: Le notifiche usano sempre "passaggio", mentre la UI usa quasi sempre "fase". L'utente riceve una notifica che parla di "passaggio" e poi nell'app trova "fase". Unificare a "fase" ovunque.

> ⚠️ **"Apri l'impasto per aggiornarlo"**: se la fase è già in corso, l'utente non deve "aggiornarla" ma "completarla". Messaggio più preciso: "Apri l'impasto per completarla."

> ⚠️ **"La finestra utile sta per chiudersi."**: manca soggetto (la finestra di che?). Aggiungere contesto: "La finestra utile per questa fase sta per chiudersi."

### Kefir
| Tipo | Titolo | Corpo |
|---|---|---|
| Warning (temperatura ambiente) | {nome batch} | Tra poco sarà il momento di rinnovare il batch |
| Warning (frigo) | {nome batch} | Domani conviene controllare il batch in frigo |
| Warning (freezer) | {nome batch} | Tra poco sarà il momento di riattivare il batch |
| Due (temperatura ambiente) | {nome batch} | È il momento di rinnovare il batch. |
| Due (frigo) | {nome batch} | È il momento di controllare il batch in frigo. |
| Due (freezer) | {nome batch} | È il momento di riattivare il batch. |

> ⚠️ **Inconsistenza punctuation**: i corpi "warning" non terminano con punto (es. "Tra poco sarà il momento di rinnovare il batch"), i "due" sì (es. "È il momento di rinnovare il batch."). Uniformare aggiungendo il punto finale a tutti.

> ⚠️ **"Domani conviene controllare il batch in frigo"**: tono informale/colloquiale ("conviene") rispetto al tono più diretto degli altri messaggi. Uniformare: "Domani è il momento di controllare il batch in frigo."

### Fridge reminder (NotificationService)
| Tipo | Copy attuale |
|---|---|
| Fridge reminder (dopo rinfresco) | Sono passate 3 ore dal rinfresco. Vuoi mettere lo starter in frigo? |

---

## 25. Enums / etichette di dominio

### BakeStepType (nomi fasi)
| Tipo | Copy attuale |
|---|---|
| starterRefresh | Rinfresco starter |
| autolysis | Autolisi |
| mix | Impasto |
| bulk | Puntata |
| fold | Pieghe |
| preshape | Preforma |
| benchRest | Riposo al banco |
| shape | Formatura |
| proof | Appretto |
| coldRetard | Riposo in frigo |
| bake | Cottura |
| cool | Raffreddamento |
| custom | Fase personalizzata |

> ⚠️ **"Puntata"** e **"Appretto"**: termini tecnici corretti nella panificazione. Ok se il target è esperto. Se si vuole rendere più accessibile: "Lievitazione in massa" e "Lievitazione finale".

### StepStatus
| Stato | Copy attuale |
|---|---|
| pending | Da fare |
| running | In corso |
| done | Completato |
| skipped | Saltato |

### BakeStatus
| Stato | Copy attuale |
|---|---|
| planned | Pianificato |
| inProgress | In corso |
| completed | Completato |
| cancelled | Annullato |

### StarterDueState
| Stato | Copy attuale |
|---|---|
| ok | Ok |
| dueToday | Da rinfrescare oggi |
| overdue | In ritardo |

### KefirBatchState
| Stato | Copy attuale |
|---|---|
| active | Attivo |
| dueSoon | Attenzione |
| dueNow | Da rinfrescare |
| overdue | In ritardo |
| pausedFridge | In frigo |
| pausedFreezer | In freezer |
| archived | Archiviato |

> ⚠️ **"Attenzione"** per `dueSoon`: un badge che dice solo "Attenzione" non dice all'utente cosa fare. "Da rinnovare presto" o "Rinnovo in arrivo" sarebbero più informativi.

> ⚠️ **"Da rinfrescare"** per un batch kefir: "rinfresco" è terminologia del lievito madre. Per il kefir dovrebbe essere "Da rinnovare".

### StorageMode (starter)
| Stato | Copy attuale |
|---|---|
| roomTemperature | Fuori frigo |
| fridge | Frigo |

### KefirStorageMode
| Stato | Copy attuale |
|---|---|
| roomTemperature | Fuori frigo |
| fridge | Frigo |
| freezer | Freezer |

> ⚠️ **"Frigo"** vs **"Frigorifero"**: entrambe le forme appaiono nella UI (nella notifica kefir compare "frigo" come parola nell'espressione, nelle etichette è il label). Scegliere uno e mantenerlo — "Frigo" è il più compatto e colloquiale, ok per il contesto.

### RecipeCategory
| Categoria | Copy attuale |
|---|---|
| pane | Pane |
| pizza | Pizza |
| focaccia | Focaccia |
| grandiLievitati | Grandi lievitati |
| dolci | Dolci |
| custom | Altro |

### YeastType
| Tipo | Titolo completo | Titolo breve |
|---|---|---|
| sourdough | Lievito madre | Madre |
| dryYeast | Lievito di birra secco attivo | Lievito |
| freshYeast | Lievito di birra fresco | Lievito |
| instantYeast | Lievito secco istantaneo | Lievito |
| none | Nessun lievito | Nessun lievito |

> ⚠️ **ShortTitle identici per yeast commerciali**: "Madre" per sourdough è distintivo, ma i tre tipi commerciali hanno tutti "Lievito" come shortTitle. Se questi compaiono insieme in una UI compatta (chip, badge), saranno indistinguibili.

### FlourCategory
| Categoria | Titolo completo | Titolo breve |
|---|---|---|
| strong | Manitoba | Manitoba |
| medium | 00/0 | Bianca |
| weak | Debole | Debole |
| whole | Integrale | Integrale |
| rye | Segale | Segale |
| semolina | Semola | Semola |
| special | Spezzata/Multicereale | Multicereale |
| custom | Altro | Altra |

> ⚠️ **Inconsistenza genere**: "Altro" (neutro/maschile) vs "Altra" (femminile) per la stessa categoria a seconda del contesto (shortTitle usa femminile). Controllare il contesto d'uso: se "Altro" si riferisce a una farina, il femminile "Altra (farina)" è corretto. Se è standalone, usare "Altro" ovunque.

### KnowledgeCategory
| Categoria | Copy attuale |
|---|---|
| starter | Starter |
| fermentation | Fermentazione |
| bakerMath | Baker's math |
| troubleshooting | Problemi comuni |

### YeastProfile
| Profilo | Titolo completo | Titolo breve |
|---|---|---|
| slow | Lenta (16–20h) | Lenta |
| medium | Media (8–12h) | Media |
| fast | Rapida (2–4h) | Rapida |

### TodayAgendaItem.Domain (label header Today feed)
| Dominio | Copy attuale |
|---|---|
| pane | Lievitati |
| starter | Starter |
| kefir | Kefir |

> ⚠️ **"Lievitati"** come label per il dominio pane: nella tab bar è "Batch", nella sezione è "Impasti", ma nel Today feed il dominio è "Lievitati". Tre nomi diversi per lo stesso concetto.

---

## 26. Azioni globali ricorrenti

| Azione | Copy attuale |
|---|---|
| Chiudi sheet | Chiudi |
| Salva | Salva |
| Aggiungi | Aggiungi |
| Elimina | Elimina |
| Annulla (alert) | Annulla |
| Modifica | Modifica |
| Archivia | Archivia |
| Ripristina | Ripristina |

✅ Le azioni globali sono consistenti e ben scelte.

---

---

# Feedback generale e proposte

## 🔴 Priorità alta — Da risolvere prima della release

### 1. "passaggio" vs "fase" — scegliere uno e usarlo ovunque

**Problema**: la UI usa quasi sempre "fase" (Avvia fase, Completa fase, Fase selezionata, Fase attiva, Timeline archiviata) ma le notifiche push usano "passaggio" (es. "questo passaggio è in corso", "il prossimo passaggio"). L'utente legge la notifica, apre l'app e non trova il termine — piccola frizione, ma incoerente.

**Proposta**: unificare a **"fase"** ovunque — è già il termine dominante nella UI.

Notification bodies da aggiornare:
- `"Questo passaggio è in corso..."` → `"Questa fase è in corso..."`
- `"È il momento di intervenire su questo passaggio..."` → `"È il momento di avanzare con questa fase..."`
- `"Il tuo impasto è pronto per il prossimo passaggio..."` → `"Il tuo impasto è pronto per la fase successiva..."`
- `"La finestra utile sta per chiudersi..."` → `"La finestra utile per questa fase sta per chiudersi."`

### 2. Errore ortografico

`"Impasto annullato — fase non piu attiva"` → `"Impasto annullato — fase non più attiva"`

File: `BakeStepCardView.swift`, `statusLine`

### 3. "Da rinfrescare" per il kefir

`KefirBatchState.dueNow.title = "Da rinfrescare"` — "rinfresco" è terminologia del lievito madre, non del kefir.

**Proposta**: `"Da rinnovare"` (coerente con il CTA "Rinnova" già presente).

Stesso problema in `KefirHubView`: "Tieni traccia dei rinfreschi dei tuoi batch" → "Tieni traccia dei rinnovi dei tuoi batch".

### 4. Nome prodotto interno esposto

`"...per iniziare a usare Levain."` nell'empty state di Today. Il nome pubblico è **Batch**.

**Proposta**: rimuovere il nome prodotto dalla frase o cambiare in "Batch".

### 5. Punteggiatura notifiche kefir incoerente

Le notifiche "warning" non hanno il punto finale, le "due" sì.

**Proposta**: aggiungere punto a tutte:
- `"Tra poco sarà il momento di rinnovare il batch."` ← aggiungi punto
- `"Domani conviene controllare il batch in frigo."` ← aggiungi punto  
- `"Tra poco sarà il momento di riattivare il batch."` ← aggiungi punto

---

## 🟡 Priorità media — Migliora coerenza e chiarezza

### 6. Toast "Gestione aggiornata a ora"

Il messaggio è awkward. **Proposta**: `"Rinnovo registrato"`.

### 7. "Timing" in BakeStepDetailView

Sezione titolo in inglese in un contesto italiano. **Proposta**: `"Tempi"` o `"Orari"`.

### 8. "Kefir" con K maiuscola inconsistente

`"I tuoi batch di Kefir."` — la K maiuscola non è usata altrove. **Proposta**: `"I tuoi batch di kefir."`.

### 9. "Attenzione" come stato kefir

`KefirBatchState.dueSoon.title = "Attenzione"` — non dice cosa fare.

**Proposta**: `"Rinnovo in arrivo"` o `"Da rinnovare presto"`.

### 10. Punto finale nei subtitle

Alcuni subtitle finiscono con punto (es. `"I tuoi batch attivi."`, `"I tuoi batch di Kefir."`), altri no. Controllare e uniformare — suggerisco **senza punto** per le brevi label descrittive.

### 11. "Ricetta step by step"

In `BakeDetailView`. **Proposta**: `"Fasi della ricetta"` o semplicemente `"Timeline"` (già usato in alternativa).

### 12. "Knowledge" e "flag tecnici interni" nel copy impostazioni

Due stringhe esposte all'utente con terminologia da sviluppatore. **Proposte**:
- `"Knowledge e template di sistema"` → `"Guide e modelli di sistema"`
- `"flag tecnici interni"` → rimuovere questa specifica, l'utente non ha bisogno di saperlo.

### 13. "Fuori frigo (°C)" nel RefreshLogView

Label ambigua per il campo temperatura. **Proposta**: `"Temp. ambiente (°C)"`.

### 14. "Passaggio in frigo" come titolo sezione

Crea confusione con il termine "passaggio" usato per le fasi. **Proposta**: `"In frigo"` o `"Messa in frigo"`.

### 15. "Log rinfresco" vs "registro"

Il titolo usa "Log" (inglese), la descrizione usa "Registro" (italiano). **Proposta**: scegliere uno. `"Registro rinfresco"` è più consistente con il tono italiano del resto.

---

## 🟢 Priorità bassa — Rifinitura e considerazioni aperte

### 16. "Controlla i tuoi starter" (StarterView subtitle)

Un po' generico. **Proposta**: `"I tuoi starter"` o `"Gestisci i tuoi starter"`.

### 17. "Inoculo starter (%)" nell'editor ricetta

Termine tecnico. Se il target è esperto, ok. Alternativa più accessibile: `"% di starter"` o `"Quantità starter (%)"`.

### 18. "Lievitati" vs "Impasti" vs "Batch" per lo stesso dominio

Nel Today feed il dominio pane è etichettato "Lievitati", nelle tab è "Batch", nella sezione è "Impasti". Tre nomi diversi per lo stesso concetto. Valutare se uniformare — almeno i due visibili in navigazione ("Impasti" nell'header sezione e "Lievitati" nel Today header) dovrebbero accordarsi.

### 19. ShortTitle identici per lieviti commerciali

I tre `YeastType` commerciali hanno tutti `shortTitle = "Lievito"`. Se compaiono insieme in un contesto compatto, diventano identici. Eventualmente differenziare: "Birra fresco", "Birra secco", "Istantaneo".

### 20. "Baker's math"

Termine inglese tecnico accettato nel mondo della panificazione. Ok lasciare così — è un termine consolidato anche tra gli appassionati italiani. Verificare che appaia solo nelle sezioni dove è appropriato (tecnico) e non in navigazione generale.

### 21. "Fuori frigo" / "Frigo" come label conservazione

Informali ma coerenti. Ok per il tono dell'app. Assicurarsi che "Frigo" sia usato consistentemente (non "Frigorifero" in alcuni punti e "Frigo" in altri).

---

## Riepilogo rapido per priorità

| # | Problema | Tipo | Priorità |
|---|---|---|---|
| 1 | "passaggio" vs "fase" nelle notifiche | Inconsistenza terminologica | 🔴 Alta |
| 2 | "fase non piu attiva" — manca accento | Errore ortografico | 🔴 Alta |
| 3 | "Da rinfrescare" per kefir, "rinfreschi" per kefir | Termine sbagliato | 🔴 Alta |
| 4 | "Levain" nell'empty state Today | Nome interno esposto | 🔴 Alta |
| 5 | Punto finale mancante in 3 notifiche kefir | Punteggiatura | 🔴 Alta |
| 6 | Toast "Gestione aggiornata a ora" | Copy confuso | 🟡 Media |
| 7 | "Timing" in inglese nel dettaglio fase | Inconsistenza lingua | 🟡 Media |
| 8 | "Kefir" con K maiuscola | Inconsistenza stile | 🟡 Media |
| 9 | "Attenzione" come stato kefir | Label poco informativo | 🟡 Media |
| 10 | Punto finale subtitle inconsistente | Punteggiatura | 🟡 Media |
| 11 | "Ricetta step by step" | Mix italiano/inglese | 🟡 Media |
| 12 | "Knowledge" e "flag tecnici" nel copy impostazioni | Termine tecnico/interno | 🟡 Media |
| 13 | "Fuori frigo (°C)" label ambiguo | Chiarezza | 🟡 Media |
| 14 | "Passaggio in frigo" — confusione col termine fase | Ambiguità | 🟡 Media |
| 15 | "Log" vs "registro" | Inconsistenza lingua | 🟡 Media |
| 16 | "Controlla i tuoi starter" generico | Miglioramento tono | 🟢 Bassa |
| 17 | "Inoculo starter (%)" — termine tecnico | Accessibilità | 🟢 Bassa |
| 18 | "Lievitati" vs "Impasti" vs "Batch" stesso dominio | Inconsistenza naming | 🟢 Bassa |
| 19 | ShortTitle lieviti commerciali identici | UX compatta | 🟢 Bassa |
