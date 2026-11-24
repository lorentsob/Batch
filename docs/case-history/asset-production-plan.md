# Batch Showcase Asset Production Plan

**Purpose:** definire quali asset creare per lo showcase product-design di Batch, dove crearli, come produrli e quale output esportare per il sito portfolio.

**Source of truth:** `docs/case-history/final-showcase-plan.md`

**Related content plan:** `docs/case-history/product-design-showcase-content.md`

---

## 1. Regola Di Produzione

Non creare gli asset finali direttamente nel sito.

Usare tre livelli:

1. **Runtime evidence nel repo**
   - Screenshot reali dell'app.
   - File sorgente tracciabili.
   - Nessuna reinterpretazione visiva.

2. **Master modificabile in Figma/FigJam**
   - Diagrammi.
   - Annotazioni.
   - Composizioni device.
   - Asset cover e social.

3. **Export ottimizzati per portfolio**
   - PNG/JPG/WebP per il sito.
   - SVG solo per diagrammi semplici se il sito li gestisce bene.
   - Naming stabile e leggibile.

---

## 2. Dove Crearli

### A. Screenshot runtime

**Dove:** nel repo, partendo dall'app reale.

**Cartella sorgente attuale:**

```text
docs/case-history/assets/
```

**Cartella consigliata se il set cresce:**

```text
docs/case-history/assets/runtime/
```

**Come crearli:**

- Lanciare la build iOS con seed operativo.
- Catturare schermate da simulatore o device reale.
- Non ridisegnare le UI in Figma se lo scopo è mostrare il prodotto shipped.
- Ricatturare a risoluzione alta prima della pubblicazione finale.

**Output:**

- Screenshot puliti in PNG o JPG.
- Nomi descrittivi:

```text
runtime-01-oggi-actionable.png
runtime-02-batch-hub.png
runtime-03-guide-browse.png
runtime-04-new-preparation-menu.png
runtime-05-kefico-detail.png
runtime-06-kefir-chronology.png
runtime-07-bake-step-shift.png
```

### B. Diagrammi UX e prodotto

**Dove:** Figma/FigJam.

**Perché:**

- Devono essere modificabili.
- Servono nel case come artefatti product-design, non come screenshot tecniche.
- Vanno mantenuti coerenti per stile, scala, griglia e annotazioni.

**Cartella export consigliata:**

```text
docs/case-history/assets/diagrams/
```

**Output:**

- SVG se il sito supporta bene linee e testo.
- PNG 2x se il sito rasterizza meglio o se ci sono device/sfondi.

### C. Composizioni device e hero

**Dove:** Figma.

**Perché:**

- Serve controllo su crop, device frames, sfondo, gerarchia e ritmo della pagina.
- Le composizioni devono usare screenshot reali come contenuto, non mock inventati.

**Cartella export consigliata:**

```text
docs/case-history/assets/compositions/
```

**Output:**

```text
hero-batch-overview.webp
composition-oggi-batch-guide.webp
composition-kefir-operational-flow.webp
case-thumbnail.webp
social-preview-batch.webp
```

### D. Annotazioni su schermate

**Dove:** Figma.

**Perché:**

- Le callout devono essere progettate come layer editoriali sopra screenshot reali.
- Devono poter essere aggiornate quando cambia copy o layout della pagina.

**Cartella export consigliata:**

```text
docs/case-history/assets/annotated/
```

**Output:**

```text
annotated-oggi-priority-model.webp
annotated-kefico-detail-state-actions.webp
annotated-batch-hub-domain-model.webp
```

---

## 3. Asset Prioritari

### P0 - Necessari Per Rendere Il Caso Da Product Designer

| Asset | Dove crearlo | Come | Output finale |
|---|---|---|---|
| IA finale `Oggi / Batch / Guide` | FigJam/Figma | Mappa semplice a 3 livelli con before/after | `diagrams/ia-oggi-batch-guide.svg` |
| Oggi priority model | Figma | Diagramma verticale con ordine di priorità | `diagrams/oggi-priority-model.svg` |
| Flow nuova preparazione | FigJam/Figma | Flow a lane: entry, dominio, azione | `diagrams/new-preparation-flow.svg` |
| BakeStep state diagram | FigJam/Figma | Stato pending/running/done/skipped con regole | `diagrams/bake-step-state-model.svg` |
| Kefir lifecycle | FigJam/Figma | Rinnovo, evento, cronologia, archivio, derivazione, confronto | `diagrams/kefir-lifecycle-flow.svg` |
| Annotazione Oggi | Figma | Screenshot runtime + 3 callout | `annotated/annotated-oggi-priority.webp` |
| Annotazione Kefico detail | Figma | Screenshot runtime + callout su stato, metrica, azioni | `annotated/annotated-kefico-detail.webp` |
| Hero 3-5 schermate | Figma | Composizione con Oggi, Batch, Kefico, Guide, menu | `compositions/hero-batch-overview.webp` |

### P1 - Rafforzano La Lettura UX

| Asset | Dove crearlo | Come | Output finale |
|---|---|---|---|
| Object model | FigJam/Figma | Relazioni tra oggetti persistiti e contenuti | `diagrams/object-model.svg` |
| Timeline shift flow | FigJam/Figma | Prima/dopo su step futuri non terminali | `diagrams/timeline-shift-flow.svg` |
| Deep-link fallback matrix | Figma | Matrice evento -> validazione -> destinazione/fallback | `diagrams/notification-fallback-matrix.svg` |
| Design-system anatomy | Figma | Componenti e semantica colore | `annotated/design-system-anatomy.webp` |
| Before/after IA | Figma | Vecchia struttura vs nuova | `diagrams/ia-before-after.svg` |

### P2 - Editoriali / Marketing

| Asset | Dove crearlo | Come | Output finale |
|---|---|---|---|
| Case thumbnail | Figma | Crop 16:9 o card progetto | `compositions/case-thumbnail.webp` |
| Social preview | Figma | Open Graph crop con brand e 2-3 screen | `compositions/social-preview-batch.webp` |
| Portfolio cover | Figma | Immagine cover coerente con hero | `compositions/portfolio-cover-batch.webp` |

---

## 4. Screenshot Mancanti Da Catturare

Questi vanno catturati dall'app, non ricreati a mano.

| Priorità | Screen | Perché serve |
|---|---|---|
| Alta | Kefir chronology / recent history | Prova la dimensione memoria/eventi |
| Alta | Kefir comparison | Prova lineage e confronto non generico |
| Alta | Bake detail with step timeline | Prova impasti e pianificazione |
| Alta | Step detail + shift timeline sheet | Prova esecuzione reale e adattamento |
| Media | Starter detail + refresh sheet | Prova manutenzione veloce |
| Media | Guide article | Prova contenuto a supporto |
| Media | Notification fallback/banner | Prova affidabilità e edge case |
| Bassa | Oggi all-clear / empty first-launch | Utile per stati, meno urgente per il primo pass |

---

## 5. Stile Comune Degli Asset

### Diagrammi

- Sfondo chiaro.
- Linee sottili neutre.
- Verde solo per percorso primario/azione.
- Rosso solo per rischio, overdue o fallback problematico.
- Testi brevi, etichette in italiano quando corrispondono alla UI.
- Non usare look tecnico da architettura software: devono sembrare artefatti di product design.

### Annotazioni

- Screenshot reale al centro.
- Massimo 3-4 callout per immagine.
- Callout brevi: una decisione, non una spiegazione lunga.
- Frecce o leader lines leggere.
- Evitare callout che coprono CTA o stati importanti.

### Device compositions

- Usare screenshot shipped.
- Device frame coerenti tra tutti gli asset.
- Non usare troppi telefoni nella stessa composizione.
- Hero: 3-5 schermate massimo.
- Evitare sfondi decorativi che spostano il focus dalla UI.

---

## 6. Sequenza Di Lavoro Consigliata

### Passo 1 - Ricattura screenshot

Ricatturare gli screen mancanti e, se possibile, sostituire gli attuali JPG 369x800 con export più puliti e ad alta risoluzione.

### Passo 2 - Creare libreria Figma del caso

Un file Figma dedicato:

```text
Batch - Portfolio Showcase Assets
```

Pagine consigliate:

```text
00 Source Screens
01 Diagrams
02 Annotated Screens
03 Device Compositions
04 Exports
```

### Passo 3 - Disegnare prima i P0

Ordine:

1. IA finale.
2. Oggi priority model.
3. Kefir lifecycle.
4. BakeStep state diagram.
5. Annotated Oggi.
6. Annotated Kefico.
7. Hero composition.

### Passo 4 - Esportare nel repo/sito

Salvare gli export in cartelle semantiche:

```text
docs/case-history/assets/diagrams/
docs/case-history/assets/annotated/
docs/case-history/assets/compositions/
```

Nel repo portfolio finale, usare gli stessi nomi file o una variante con prefisso progetto.

### Passo 5 - Montare nella pagina

Inserire gli asset in questo ordine:

1. Hero composition.
2. Research/process block con diagramma priority o IA.
3. IA before/after.
4. Core flow diagrams.
5. Annotated Oggi e Kefico.
6. Final screen storyboard.
7. Validation/outcome.

---

## 7. Primo Batch Di Produzione

Se bisogna partire subito, creare solo questi 6 asset:

1. `hero-batch-overview.webp`
2. `ia-oggi-batch-guide.svg`
3. `oggi-priority-model.svg`
4. `kefir-lifecycle-flow.svg`
5. `annotated-oggi-priority.webp`
6. `annotated-kefico-detail.webp`

Questi bastano per trasformare la pagina da "progetto spiegato con schermate" a "case history product-design con processo, decisioni e sistema".

