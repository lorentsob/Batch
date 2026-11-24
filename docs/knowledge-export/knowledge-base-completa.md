# Batch Knowledge Base completa

Export Markdown della knowledge base caricata dall'app da `Levain/Resources/knowledge.json`.

- Articoli esportati: 13
- Formato: un articolo per sezione, con metadati app preservati
- Nota: il testo e i campi sono copiati dal JSON runtime senza correzioni editoriali

---

## 1. Basi del lievito madre



**ID:** `starter-basics`  
**Categoria:** `starter`

**Tag:** `starter`, `rinfresco`, `manutenzione`

**Alias:** `starter`, `lievito madre`, `sourdough starter`

## Sintesi

Cos'è lo starter, come funziona e i segnali di uno starter sano.

## Contenuto

Lo starter è un impasto di farina e acqua fermentato in modo continuo, che ospita lieviti e batteri lattici in equilibrio stabile. La sua forza dipende da: regolarità dei rinfreschi, temperatura di conservazione, rapporto di rinfresco (es. 1:4:4) e tipo di farina usata. Dovrebbe raddoppiare o quasi entro 4–8 ore dopo un rinfresco. Segnali positivi: molte bolle diffuse, superficie leggermente bombata, odore lattico/fruttato, consistenza aerata.

## Collegamenti app

- Step collegati: `starterRefresh`
- Stati starter collegati: `ok`, `dueToday`

---

## 2. Manutenzione starter in frigo



**ID:** `starter-maintenance-fridge`  
**Categoria:** `starter`

**Tag:** `frigo`, `conservazione`, `rinfresco`

**Alias:** `starter in frigo`, `manutenzione starter`, `rinfresco in frigo`

## Sintesi

Come conservare e rinfrescare lo starter in frigorifero.

## Contenuto

Conservare lo starter in frigo a 4–8 °C rallentera la fermentazione. Fai un rinfresco con rapporto alto (es. 1:4:4), lascialo partire un po' a temperatura ambiente, poi mettilo in frigo. Ripeti ogni 5–7 giorni circa. Prima di un bake importante, fai 1–2 rinfreschi a temperatura ambiente per riportarlo in piena forma.

## Collegamenti app

- Step collegati: `starterRefresh`
- Stati starter collegati: `dueToday`, `overdue`

---

## 3. Recuperare uno starter pigro



**ID:** `starter-recovery`  
**Categoria:** `starter`

**Tag:** `recupero`, `attività`, `troubleshooting`

**Alias:** `starter pigro`, `starter debole`, `hooch`

## Sintesi

Come riattivare uno starter che cresce lentamente o mostra segni di stanchezza.

## Contenuto

Aumenta temporaneamente la temperatura (22–26 °C). Fai rinfreschi più frequenti per alcuni giorni. Integra una quota di farina integrale o di segale (25–50%) per stimolare l'attività. Usa acqua leggermente tiepida, evitando temperature troppo alte. Se compare il 'hooch' (strato liquido in superficie), è un segnale di acidità alta: scarta parte dello starter e rinfresca con più farina.

## Collegamenti app

- Step collegati: `starterRefresh`
- Stati starter collegati: `overdue`

---

## 4. Levain



**ID:** `levain-guide`  
**Categoria:** `starter`

**Tag:** `levain`, `prefermento`, `starter prep`

**Alias:** `starter prep`, `prefermento`, `build del levain`, `lievito di riporto`

## Sintesi

Quando costruire un levain, come leggerlo e in cosa si distingue dallo starter nel barattolo.

## Contenuto

Il levain è una porzione di starter rinfrescata in una quantità pensata per una ricetta specifica. Serve a portare l'inoculo al punto giusto senza stressare il barattolo principale e permette di scegliere idratazione, forza e finestra di maturazione in base all'impasto. In genere è pronto quando ha aumentato chiaramente il volume, è aerato e ha un profumo lattico-acidulo pulito. Se collassa presto o resta molto compatto, conviene regolare temperatura, rapporto di rinfresco o tempo di attesa prima di usarlo.

## Collegamenti app

- Step collegati: nessuno
- Stati starter collegati: nessuno

---

## 5. Bulk fermentation



**ID:** `bulk-fermentation-basics`  
**Categoria:** `fermentation`

**Tag:** `bulk`, `fermentazione`, `temperatura`

**Alias:** `bulk`, `prima lievitazione`, `first rise`

## Sintesi

Come leggere e gestire la bulk fermentation per un impasto ben sviluppato.

## Contenuto

La bulk fermentation è la fase di lievitazione principale dopo l'impasto. L'impasto è pronto quando è aumentato del 50–75%, è ben aerato e si stacca pulito dalle pareti del contenitore. La temperatura incide molto: a 24 °C la bulk dura 4–5 ore, a 22 °C circa 6–7 ore. Durante questa fase si eseguono le pieghe (stretch & fold) per rinforzare la struttura del glutine.

## Collegamenti app

- Step collegati: `bulk`, `fold`
- Stati starter collegati: nessuno

---

## 6. Appretto



**ID:** `appretto-guide`  
**Categoria:** `fermentation`

**Tag:** `appretto`, `proof`, `lievitazione finale`

**Alias:** `proof`, `final proof`, `second rise`, `seconda lievitazione`, `lievitazione finale`

## Sintesi

Come riconoscere l'appretto giusto prima della cottura o del passaggio in frigo.

## Contenuto

L'appretto è la lievitazione finale dopo la formatura. In questa fase l'impasto deve gonfiarsi senza perdere tensione: deve risultare più leggero, leggermente elastico al tatto e capace di recuperare lentamente se premi la superficie con un dito infarinato. Un appretto troppo corto porta a pane fitto e tagli che si aprono in modo irregolare; troppo lungo porta invece a poca spinta in forno e struttura fragile. Se prevedi un cold retard, l'impasto deve entrare in frigo già ben formato ma non al limite della sovralievitazione.

## Collegamenti app

- Step collegati: `proof`
- Stati starter collegati: nessuno

---

## 7. Baker's math e idratazione



**ID:** `bakers-math`  
**Categoria:** `bakerMath`

**Tag:** `percentuale`, `idratazione`, `calcolo`

**Alias:** `baker's math`, `bakers math`, `idratazione`, `hydration`

## Sintesi

Come usare la baker's percentage per calcolare e scalare le ricette.

## Contenuto

Nella baker's math la farina totale è sempre 100%. Tutti gli altri ingredienti sono espressi come percentuale della farina. Formula: (peso ingrediente ÷ peso farina) × 100. Idratazioni tipiche: 65–72% per sourdough artigianale, 75–85% per focaccia e ciabatta. Il sale è tipicamente al 2%, l'inoculazione (starter) tra il 10% e il 20%.

## Collegamenti app

- Step collegati: `mix`
- Stati starter collegati: nessuno

---

## 8. Formatura e preforma



**ID:** `shaping-guide`  
**Categoria:** `fermentation`

**Tag:** `formatura`, `tensione`, `bench rest`

**Alias:** `formatura`, `preforma`, `bench rest`, `shape`, `shaping`

## Sintesi

Tecniche di preforma e formatura per costruire tensione superficiale.

## Contenuto

La preforma crea una tensione iniziale e dà all'impasto una struttura temporanea prima del bench rest. Dopo 20–30 minuti di riposo, la formatura finale costruisce la tensione superficiale necessaria per trattenere i gas durante la lievitazione finale. Un buon filo di tensione si vede dalla superficie liscia e leggermente tesa del pane formato.

## Collegamenti app

- Step collegati: `preshape`, `benchRest`, `shape`
- Stati starter collegati: nessuno

---

## 9. Cold retard



**ID:** `cold-retard-guide`  
**Categoria:** `fermentation`

**Tag:** `frigo`, `retarder`, `sapore`

**Alias:** `cold retard`, `lievitazione finale in frigo`, `proof in frigo`

## Sintesi

Come e perché usare il frigo durante la lievitazione finale.

## Contenuto

Il cold retard (lievitazione finale in frigo a 4–6 °C) sviluppa sapore e facilita il taglio grazie all'impasto freddo e compatto. La finestra è tipicamente tra le 12 e le 48 ore. Un impasto ben formato e non sovralievitato prima dell'ingresso in frigo darà risultati migliori. Si può infornare direttamente dal frigo senza bisogno di riportare a temperatura.

## Collegamenti app

- Step collegati: `coldRetard`, `proof`
- Stati starter collegati: nessuno

---

## 10. Autolisi



**ID:** `autolisi-guide`  
**Categoria:** `fermentation`

**Tag:** `autolisi`, `impasto`, `idratazione`

**Alias:** `autolysis`

## Sintesi

Perché lasciare farina e liquidi a riposo prima dell'impasto completo può migliorare struttura ed estensibilità.

## Contenuto

L'autolisi è un riposo iniziale di farina e acqua, oppure farina e parte dei liquidi, prima di inserire sale, grassi o inoculo. In questo tempo la farina si idrata meglio e il glutine inizia a organizzarsi da solo, così l'impasto richiede meno lavoro meccanico e diventa più estensibile. Nelle ricette ricche o molto dolci l'autolisi va tenuta breve e controllata, perché latte, uova, zucchero e burro cambiano il comportamento dell'impasto rispetto a un pane magro.

## Collegamenti app

- Step collegati: `autolysis`, `mix`
- Stati starter collegati: nessuno

---

## 11. Pieghe e stretch & fold



**ID:** `pieghe-guide`  
**Categoria:** `fermentation`

**Tag:** `pieghe`, `stretch & fold`, `glutine`

**Alias:** `pieghe`, `stretch & fold`, `stretch and fold`, `giri di pieghe`

## Sintesi

Quando fare le pieghe durante la bulk e cosa devono cambiare davvero nell'impasto.

## Contenuto

Le pieghe servono a rinforzare la maglia glutinica e redistribuire temperatura e gas durante la bulk fermentation. Ogni giro dovrebbe tendere l'impasto senza strapparlo: se oppone troppa resistenza, conviene aspettare ancora un po'; se invece è molto rilassato o si allarga subito, un altro giro può aiutare. Nella pratica 2–4 giri ben distanziati sono spesso sufficienti. Più che contare i minuti, osserva se l'impasto tiene meglio la forma dopo ogni serie.

## Collegamenti app

- Step collegati: `fold`, `bulk`
- Stati starter collegati: nessuno

---

## 12. Bollitura



**ID:** `bollitura-guide`  
**Categoria:** `fermentation`

**Tag:** `bollitura`, `bagel`, `boil and bake`

**Alias:** `boil and bake`, `boil`, `bollire i bagel`

## Sintesi

Perché la bollitura è decisiva nei bagel e come evitare che la fase rovini forma e consistenza.

## Contenuto

La bollitura gelatinizza in superficie l'amido e crea la pelle elastica che distingue i bagel da un pane cotto direttamente in forno. L'acqua deve sobbollire, non essere troppo violenta, e il passaggio dura in genere 30–60 secondi per lato a seconda dello stile. Se i bagel collassano o affondano troppo a lungo, spesso il problema è un appretto eccessivo; se restano opachi e poco tesi, la bollitura può essere stata troppo breve o l'impasto troppo freddo e poco maturo. Conviene portare forno e teglie in temperatura prima di iniziare, così il trasferimento resta rapido.

## Collegamenti app

- Step collegati: nessuno
- Stati starter collegati: nessuno

---

## 13. Problemi comuni e soluzioni



**ID:** `common-problems`  
**Categoria:** `troubleshooting`

**Tag:** `troubleshooting`, `crosta`, `mollica`, `pane piatto`

**Alias:** `troubleshooting`, `underproofing`, `overproofing`

## Sintesi

Diagnosi e soluzioni per i problemi più frequenti nella panificazione con lievito madre.

## Contenuto

Pane piatto: starter non abbastanza attivo oppure sovralievitazione. Mollica troppo fitta: underproofing (lievitazione insufficiente) o farina debole. Crosta troppo spessa: temperatura forno troppo alta o cottura troppo lunga senza vapore. Acidità eccessiva: bulk troppo lunga o temperatura troppo alta. Taglio che non apre: tensione superficiale insufficiente nella formatura o lama non abbastanza affilata.

## Collegamenti app

- Step collegati: `bake`
- Stati starter collegati: `overdue`

---
