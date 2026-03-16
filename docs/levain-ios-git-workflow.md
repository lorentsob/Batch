# Levain iOS Development Workflow

## Scopo del workflow

Questo documento definisce il workflow di sviluppo da adottare per **Levain**, progetto **iOS app**.  
Serve a mantenere il codice stabile, evitare modifiche caotiche su `main`, ridurre il rischio di regressioni e aiutare sia il developer sia l'AI agent a capire **quando un task è ben isolato** e **quando invece sta degenerando in un branch troppo largo**.

Questo workflow non è pensato per enterprise theater.  
È pensato per lavorare in modo serio, leggibile e sostenibile su un'app iOS in evoluzione.

---

## Principi base

### 1. `main` deve essere sempre stabile
Il branch `main` deve rappresentare una versione del progetto sempre apribile, compilabile e ragionevolmente sicura da distribuire o testare.

Su `main` non si lavora direttamente.

### 2. Ogni modifica vive in un branch dedicato
Ogni feature, fix, refactor o task tecnico deve avere un branch proprio.

### 3. Un branch deve avere uno scopo chiaro
Un branch non deve contenere "un po' di tutto".  
Deve rispondere a una singola domanda tipo:

- sto aggiungendo una feature?
- sto correggendo un bug?
- sto rifattorizzando una parte precisa?
- sto sistemando infrastruttura o tooling?

Se la risposta diventa "sto facendo più cose insieme", il branch è probabilmente sbagliato.

### 4. Le Pull Request sono obbligatorie anche se si lavora da soli
La PR non serve solo per il team.  
Serve per:

- rileggere il diff
- verificare lo scope
- far girare la CI
- controllare che la modifica sia davvero pronta
- evitare merge impulsivi su `main`

### 5. Branch piccoli battono branch enormi
Meglio tre branch puliti e rapidi che uno enorme pieno di modifiche miste, difficile da revieware e facile da rompere.

---

## Struttura dei branch

### Branch permanenti

- `main` → branch stabile e protetto

Per ora non serve introdurre altri branch permanenti tipo `develop` o `staging` a meno che il progetto non cresca molto.  
Per Levain, nella fase attuale, `main + feature branches + PR + CI` è il setup più pulito.

### Naming convention dei branch

Usare sempre branch descrittivi con prefisso coerente:

```bash
feature/nome-feature
fix/nome-bug
refactor/nome-area
chore/nome-task
docs/nome-documento
test/nome-scenario
```

Esempi:

```bash
feature/recipe-import
feature/sourdough-timer
fix/onboarding-crash
fix/keyboard-layout-settings
refactor/storage-layer
chore/update-ci-ios
docs/content-pipeline
test/navigation-regression
```

---

## Workflow standard

## 1. Partenza da `main`

Prima di iniziare un nuovo task:

```bash
git switch main
git pull origin main
```

Obiettivo: partire sempre da una base aggiornata e pulita.

---

## 2. Creazione del branch

Creare un branch dedicato per il task:

```bash
git switch -c feature/sourdough-timer
```

Il nome deve riflettere uno scopo preciso.  
Se non si riesce a dare un nome semplice al branch, probabilmente il task è troppo vago o troppo largo.

---

## 3. Sviluppo nel branch

Durante il lavoro sul branch:

- implementare solo ciò che appartiene al task
- evitare modifiche non correlate
- evitare refactor laterali non necessari
- evitare di toccare file estranei "già che ci siamo"

Se durante lo sviluppo emergono altri problemi, valutarli così:

### Se sono bloccanti per il task attuale
Possono restare nello stesso branch.

### Se non sono bloccanti
Si annotano e si spostano in un branch successivo.

Regola pratica:  
**non usare il branch corrente come discarica di miglioramenti casuali**.

---

## 4. Commit

Fare commit piccoli, leggibili e coerenti.

Buoni esempi:

```bash
git commit -m "Add starter refresh timer screen"
git commit -m "Persist timer state across app relaunch"
git commit -m "Fix layout issue in timer settings"
```

Cattivi esempi:

```bash
git commit -m "fix stuff"
git commit -m "updates"
git commit -m "final"
git commit -m "more fixes"
```

Ogni commit deve raccontare una modifica comprensibile.

---

## 5. Push del branch

```bash
git push -u origin feature/sourdough-timer
```

---

## 6. Apertura della Pull Request

Ogni branch va aperto in PR verso `main`.

La PR deve essere leggibile e deve spiegare:

- cosa cambia
- perché cambia
- come testarlo
- quali rischi o aree sensibili ci sono

### Template PR consigliato

```md
## Cosa cambia
## Perché
## Come testarlo
## Note / rischi
```

---

## 7. Verifiche prima del merge

Prima di fare merge, il branch deve soddisfare questi controlli.

### Verifiche Git
- branch con scopo chiaro
- nessun file estraneo
- diff leggibile
- commit sensati

### Verifiche locali
- il progetto apre correttamente in Xcode
- la build gira
- la feature funziona
- non sono stati rotti flow esistenti

### Verifiche automatiche
- CI passata
- eventuali test passati
- lint o static analysis passati, se configurati

### Verifiche prodotto/UI
- comportamento coerente con l'app
- layout accettabile
- edge cases minimi gestiti
- nessuna regressione evidente nelle schermate collegate

---

## 8. Merge

Solo dopo review del diff e CI verde.

Dopo il merge:

- cancellare il branch remoto
- tornare su `main`
- aggiornare `main`

```bash
git switch main
git pull origin main
```

---

## Come capire se un branch è troppo grosso

Questo è uno dei punti più importanti.

Un branch è troppo grosso quando contiene **più di uno scopo reale**.  
Non conta solo il numero di file. Conta la mescolanza concettuale.

### Segnali che il branch sta degenerando

- contiene feature + bugfix + refactor insieme
- tocca UI, storage, networking e navigation senza necessità reale
- la PR è difficile da spiegare in 3-5 righe
- il nome del branch non descrive più bene cosa contiene
- il diff è lungo e disordinato
- ci sono modifiche "già che c'ero"
- sono stati cambiati file non collegati direttamente al task
- durante la review viene da dire "questo magari lo sistemiamo dopo"
- servono troppe parole per spiegare cosa è cambiato
- la modifica non è più facilmente reversibile

### Regola pratica

Se il branch richiede una spiegazione tipo:

> "sì allora ho fatto il timer, poi già che c'ero ho migliorato anche il salvataggio, poi ho sistemato due cose nell'onboarding, poi ho rifatto una parte del model"

allora il branch è sbagliato.

---

## Regola di stop per l'AI agent

L'AI agent deve fermare o correggere il workflow se rileva che il lavoro sta uscendo dallo scope del branch.

### L'agent deve intervenire quando:

1. il task richiesto include più aree funzionali distinte
2. la richiesta mischia feature, fix e refactor nello stesso passo
3. la soluzione proposta tocca molte parti del progetto non direttamente necessarie
4. il branch corrente non è più descrivibile con un obiettivo singolo
5. il diff stimato è troppo ampio per una review semplice
6. stanno emergendo task secondari che meritano branch separati

### In questi casi l'agent deve dire chiaramente che:

- il task sta diventando troppo largo
- conviene dividere il lavoro
- il branch attuale deve mantenere uno scope preciso
- le modifiche extra vanno spostate in branch successivi

### Comportamento atteso dell'agent

Quando rileva caos, l'agent non deve continuare ad accumulare modifiche.  
Deve invece proporre una scomposizione.

Esempio:

invece di lavorare su:

- import contenuti
- parsing markdown
- redesign lista ricette
- nuovi filtri
- fix navigation
- miglioramenti storage

tutto nello stesso branch, deve suggerire:

```text
1. feature/content-import-foundation
2. feature/markdown-parser
3. feature/recipe-list-ui
4. feature/recipe-filters
5. fix/navigation-after-import
```

---

## Regola di scomposizione dei task

Per Levain, un task dovrebbe idealmente appartenere a una sola di queste categorie per branch:

### A. UI / schermata
Esempi:
- nuova schermata timer
- redesign scheda ricetta
- miglioramento settings view

### B. Logica applicativa
Esempi:
- calcolo tempi lievitazione
- stato del timer
- validazione input

### C. Data layer / persistenza
Esempi:
- salvataggio preferenze
- cache locale
- refactor model storage

### D. Navigation / flow
Esempi:
- onboarding flow
- deep link handling
- routing tra schermate

### E. Tooling / infrastruttura
Esempi:
- CI iOS
- fastlane
- configurazione test
- build settings

### F. Bugfix mirato
Esempi:
- crash su schermata ricetta
- layout rotto su iPhone SE
- problema di persistenza timer

Se un branch mischia più categorie, va giustificato.  
Se non c'è una dipendenza tecnica forte, va diviso.

---

## Workflow specifico per progetto iOS

Levain è un'app iOS, quindi il workflow deve tenere conto di problemi tipici dello sviluppo Apple.

### Regole operative per iOS

#### 1. Non mischiare nello stesso branch feature UI e refactor tecnici profondi
Per esempio:

- creare una nuova schermata
- rifare il sistema di persistenza
- cambiare navigation architecture

tutto insieme è una pessima idea.

Su iOS questo tipo di miscela rende più difficile capire se un bug dipende da:

- SwiftUI / UIKit view
- state management
- navigation stack
- model
- persistenza
- lifecycle app

#### 2. Ogni branch deve poter essere testato facilmente in Xcode
L'obiettivo è arrivare a una PR che sia:

- buildabile
- apribile
- testabile su simulator
- comprensibile in review

#### 3. Ridurre i branch che rompono troppe schermate insieme
Su app mobile è facile che un cambio a cascata rompa navigation, stato o layout su più device.

Meglio branch verticali e controllabili.

#### 4. Fare attenzione ai branch che toccano asset, modelli e view insieme
Questo trio può essere legittimo, ma va monitorato.  
Se il lavoro tocca:

- nuovi asset
- nuovi model
- nuove view
- nuove logiche di stato
- nuove dipendenze

allora l'agent deve valutare se il task va spezzato.

---

## Criteri pratici per decidere se restare nello stesso branch

Una modifica può restare nello stesso branch se soddisfa quasi tutte queste condizioni:

- serve direttamente a completare la feature principale
- senza quella modifica la feature non funziona
- il diff resta leggibile
- la PR resta spiegabile facilmente
- il test locale resta semplice
- la modifica non introduce un secondo obiettivo autonomo

Se una modifica genera un secondo obiettivo autonomo, deve diventare un altro branch.

---

## Esempi concreti per Levain

## Esempio corretto

Branch:

```bash
feature/sourdough-timer
```

Contiene:
- nuova schermata timer
- logica timer collegata
- persistenza minima necessaria
- piccoli fix di layout direttamente legati al timer

Questo è ok, perché tutto serve a completare una feature unica.

---

## Esempio sbagliato

Branch:

```bash
feature/sourdough-timer
```

Contiene anche:
- redesign onboarding
- refactor storage globale
- fix categorie ricette
- aggiornamento icone app
- miglioramento CI

Questo è caos.  
Va spezzato.

---

## Altro esempio corretto

```bash
fix/recipe-detail-crash
```

Contiene:
- fix crash
- test manuale del flow collegato
- eventuale piccola protezione su optional o state handling

Ok.

---

## Altro esempio sbagliato

```bash
fix/recipe-detail-crash
```

Contiene:
- fix crash
- redesign della schermata
- cambio naming model
- refactor parser markdown

No.  
Il bugfix è diventato un branch ibrido.

---

## Uso della CI per Levain

La CI deve bloccare merge di codice instabile.

Per un progetto iOS, il minimo consigliato è:

- build del progetto
- test automatici disponibili
- eventuale lint/static checks se configurati
- controllo che il branch sia mergeabile

Se la CI fallisce, non si mergea.

### Regola
`main` non deve ricevere codice che non passa i controlli automatici di base.

---

## Protezioni consigliate su `main`

Impostare appena possibile queste regole nel repository:

1. vietare push diretti su `main`
2. richiedere PR per il merge
3. richiedere CI verde
4. preferire branch piccoli e merge frequenti
5. cancellare i branch mergiati

Questo impedisce il workflow impulsivo tipo:

- modifico
- pusho su `main`
- spero che vada tutto bene

che è rapido solo finché non esplode qualcosa.

---

## Regole operative per l'AI agent

L'AI agent deve seguire queste regole in modo esplicito.

### Regola 1
Non proporre modifiche dirette su `main`.

### Regola 2
Quando viene richiesto un lavoro nuovo, aiutare a identificare il branch giusto.

### Regola 3
Se il task è troppo ampio, proporre subito una scomposizione in branch separati.

### Regola 4
Se durante il lavoro emergono modifiche laterali non strettamente necessarie, segnalarle e proporle come task successivi.

### Regola 5
Non incoraggiare refactor gratuiti dentro branch di feature o fix.

### Regola 6
Prima di considerare un branch pronto, richiamare sempre:
- scope
- controlli locali
- CI
- review del diff

### Regola 7
Se il branch diventa difficile da nominare o spiegare, fermare il lavoro e proporre una divisione.

### Regola 8
Per task iOS, tenere separate quando possibile:
- UI
- stato/logica
- persistenza
- navigation
- tooling

### Regola 9
Quando suggerisce codice, l'agent deve preferire modifiche mirate e locali, evitando riscritture ampie se non richieste.

### Regola 10
L'agent deve privilegiare PR piccole, testabili e reversibili.

---

## Checklist pre-PR

Prima di aprire o approvare una PR, controllare:

### Scope
- il branch ha uno scopo chiaro?
- il nome del branch descrive ancora il lavoro?
- il diff contiene solo modifiche pertinenti?

### Stabilità
- il progetto compila?
- il flow toccato funziona?
- le schermate collegate sono state provate?

### Qualità
- commit leggibili
- niente file temporanei
- niente debug lasciato a caso
- niente modifiche laterali non necessarie

### Review
- la PR si spiega in poche righe?
- chi legge il diff capisce il cambiamento?
- la modifica è facilmente reversibile?

Se la risposta è no a più punti, il branch va ripensato.

---

## Workflow operativo sintetico

```text
1. Aggiorna main
2. Crea branch dedicato
3. Lavora solo sullo scope previsto
4. Fai commit leggibili
5. Pusha il branch
6. Apri PR verso main
7. Controlla build, test, CI e diff
8. Merge solo se pulito
9. Cancella branch
10. Torna su main aggiornato
```

---

## Comandi base

### Nuovo task

```bash
git switch main
git pull origin main
git switch -c feature/nome-task
```

### Commit e push

```bash
git add .
git commit -m "Add starter timer settings screen"
git push -u origin feature/nome-task
```

### Aggiornare il branch con `main`

```bash
git switch main
git pull origin main
git switch feature/nome-task
git rebase main
git push --force-with-lease
```

---

## Conclusione operativa

L'obiettivo del workflow Levain è semplice:

- proteggere `main`
- mantenere branch piccoli e leggibili
- usare PR come checkpoint obbligatorio
- evitare branch ibridi e caotici
- permettere all'AI agent di riconoscere quando il lavoro sta uscendo dallo scope

La regola più importante è questa:

**un branch deve avere un solo obiettivo reale.**

Quando quell'obiettivo si sporca, si divide il lavoro.  
Non si trascina il caos fino al merge.
