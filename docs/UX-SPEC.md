# UX-SPEC.md — Levain
**Version:** 1.0 — 2026-03-10
**Riferimento visivo:** Planta (card grandi, gerarchia Apple, azioni prominenti, whitespace generoso)
**Modalità:** Light only · iPhone only · SF Pro · Squircles continui

---

## Indice

1. [Principi di interazione](#1-principi-di-interazione)
2. [Pattern globali](#2-pattern-globali)
3. [Libreria componenti](#3-libreria-componenti)
4. [Today Tab](#4-today-tab)
5. [Bakes Tab](#5-bakes-tab)
6. [Starter Tab](#6-starter-tab)
7. [Knowledge Tab](#7-knowledge-tab)
8. [Flussi di creazione (Sheet)](#8-flussi-di-creazione-sheet)
9. [Step Detail Sheet](#9-step-detail-sheet)
10. [Mappa stati visivi](#10-mappa-stati-visivi)

---

## Nota sui token Theme

Il file `Theme.swift` (v0.1) è la fonte autorevole dei token. I componenti scaffold esistenti
(`EmptyStateView`, `SectionCard`, `StateBadge`) usano token legacy (`Theme.ink`, `Theme.panel`,
`Theme.accent`…) che **non esistono** in Theme.swift v0.1. Prima di sviluppare qualunque
feature, quei tre file vanno aggiornati per usare i token corretti:

| Token legacy | Token corretto |
|---|---|
| `Theme.ink` | `Theme.Color.textPrimary` |
| `Theme.muted` | `Theme.Color.textSecondary` |
| `Theme.panel` | `Theme.Color.surface` |
| `Theme.accent` | `Theme.Color.accent` |
| `Theme.accentSoft` | `Theme.Color.accentLight` |
| `Theme.success` | `Theme.Color.primary` |
| `Theme.warning` | `Theme.Color.accent` |
| `Theme.danger` | `Theme.Color.error` |

---

## 1. Principi di interazione

### Gerarchia Apple
Ogni schermata ha **un solo focus visivo primario** — titolo grande, card principale o CTA
principale. Gli elementi secondari scalano visivamente verso il basso usando la scala
tipografica di `Theme.Typography`.

### Action-first
La domanda a cui ogni schermata deve rispondere prima di tutto: *"Cosa devo fare adesso?"*
Le CTA non sono mai sepolte — stanno nella card stessa, full-width, visibili senza scroll
quando possibile.

### Spazio come linguaggio
Whitespace generoso tra sezioni (`Theme.Spacing.xxl` = 48pt tra tab sections).
Padding interno card costante (`Theme.Spacing.md` = 16pt).
Le card non si toccano — `Theme.Spacing.sm` (8pt) tra card adiacenti.

### Un'azione primaria per card
Ogni card espone un **solo bottone primario** (verde pieno). Azioni secondarie (skip, dettaglio,
sposta) stanno nel detail sheet o come ghost button sotto il primario.

### Progressive disclosure
Campi avanzati (note, temperatureRange, volumeTarget, photoURI, ambientTemp) vivono in sezioni
collassabili dentro i form, mai visibili nel flusso primario.

---

## 2. Pattern globali

### Tab bar
Tab bar nativa iOS standard. Quattro voci:

| Index | Label | SF Symbol |
|---|---|---|
| 0 | Oggi | `sun.max.fill` (attivo) / `sun.max` |
| 1 | Impasti | `loaf.fill` → usare `fork.knife` |
| 2 | Starter | `drop.fill` (attivo) / `drop` |
| 3 | Knowledge | `book.closed.fill` (attivo) / `book.closed` |

Tint color della tab bar: `Theme.Color.primary` (verde).
Background: `Theme.Color.background` con separatore `Theme.Color.border`.

### Navigazione
- Ogni tab ha il proprio `NavigationStack`
- Push navigation per i dettagli (BakeDetail, StarterDetail, KnowledgeArticle)
- **Mai** push per la creazione — sempre `.sheet` bottom-up
- I sheet di creazione hanno `presentationDetents([.large])` e drag indicator visibile

### ScrollView layout standard
Ogni tab root usa `ScrollView` con:
```
.padding(.horizontal, Theme.Spacing.md)   // 16pt laterale
.padding(.top, Theme.Spacing.sm)          // 8pt sopra il primo elemento
.padding(.bottom, Theme.Spacing.xxxl)     // 64pt sotto l'ultimo (clearance tab bar)
```

### NavigationBar style
- Large title per le root view di ogni tab
- Inline title per i detail screen
- Background: `.background` material o trasparente con scroll
- Tint: `Theme.Color.primaryDark`

### Empty state
`EmptyStateView` centrata verticalmente nella scroll area. Struttura:
```
VStack(spacing: Theme.Spacing.lg) {
    Image(systemName: <icona SF>) — 48pt, color: Theme.Color.textTertiary
    Text(titolo)       — Theme.Typography.title3, textPrimary
    Text(descrizione)  — Theme.Typography.body, textSecondary, multiline centrato
    PrimaryButton(label) { action }  — larghezza fissa 220pt
}
```

### Sezione header
```
HStack {
    Text(label)                       // Theme.Typography.overline, textTertiary, uppercase
    Spacer()
    Text(count opzionale)             // Theme.Typography.footnote, textTertiary
}
.padding(.horizontal, Theme.Spacing.xxs)
.padding(.bottom, Theme.Spacing.xs)
```

### Sheet header standard
Ogni sheet modale inizia con:
```
HStack {
    Button("Annulla") { dismiss }     // foreground: textSecondary
    Spacer()
    Text(titolo)                      // Typography.headline
    Spacer()
    Button("Salva" / "Crea") { save } // foreground: primaryDark, bold
}
.padding(.horizontal, md)
.padding(.vertical, sm)
```
Seguito da `Divider()` color `Theme.Color.border`.

---

## 3. Libreria componenti

### 3.1 PrimaryButton
Bottone verde pieno, full-width, usato come CTA principale nelle card e nei form.

```
// Aspetto
background:       Theme.Color.primary
foreground:       Theme.Color.textOnPrimary
font:             Theme.Typography.headline (semibold 17pt)
cornerRadius:     Theme.Radius.md (16pt, .continuous)
height:           52pt
padding H:        Theme.Spacing.md
shadow:           Theme.Shadow.primary (verde tintato)

// Stati
default:   opacity 1.0
pressed:   scaleEffect 0.97, animation .micro
disabled:  background Theme.Color.border, foreground textTertiary, no shadow
```

### 3.2 SecondaryButton
Bottone ghost/outline, usato per azioni secondarie sotto il PrimaryButton.

```
background:       Color.clear
foreground:       Theme.Color.primaryDark
font:             Theme.Typography.subheadline (15pt regular)
cornerRadius:     Theme.Radius.md
height:           44pt
border:           Theme.Color.border, lineWidth 1.5
```

### 3.3 DestructiveButton
Per "Annulla bake", "Elimina" — usato solo in ActionSheet o come terzo CTA in detail.

```
foreground:       Theme.Color.error
font:             Theme.Typography.subheadline
```

### 3.4 StepCard (componente centrale)
La card principale dell'app — usata in TodayView e BakeDetailView.

**Struttura interna (top → bottom):**
```
VStack(alignment: .leading, spacing: Theme.Spacing.sm) {

    // Row 1 — Contesto + badge stato
    HStack {
        Text(nomeBake)              // Typography.caption1Semibold, textTertiary, uppercase
        Spacer()
        StateBadge(step.status)
    }

    // Row 2 — Nome step
    Text(step.displayName)          // Typography.title3 (20pt semibold), textPrimary

    // Row 3 — Orario + durata
    HStack(spacing: Theme.Spacing.xs) {
        Image(systemName: "clock")  // 12pt, textTertiary
        Text(orarioPianificato)     // Typography.footnote, textSecondary
        Text("·")                  // textTertiary
        Text(durata)               // Typography.footnote, textSecondary
        Spacer()
        if isOverdue {
            Text(deltaOverdue)      // Typography.footnoteSemibold, Color.error
        }
    }

    // Row 4 — Descrizione (se presente, max 2 righe)
    if !step.descriptionText.isEmpty {
        Text(step.descriptionText)
            .font(Theme.Typography.subheadline)
            .foregroundStyle(Theme.Color.textSecondary)
            .lineLimit(2)
    }

    Divider().foregroundStyle(Theme.Color.border)

    // Row 5 — CTA primaria
    PrimaryButton(ctaLabel) { primaryAction }

    // Row 6 — CTA secondaria (solo se .running o .pending con actualStart)
    SecondaryButton("Vedi dettaglio") { openDetail }
}
.padding(Theme.Spacing.md)
.background(cardBackground)
.squircle(radius: Theme.Radius.xl)
.themeShadow(cardShadow)
```

**Varianti per stato:**

| Stato | Background | Shadow | Badge |
|---|---|---|---|
| `.pending` (futuro) | `Color.surface` | `Shadow.sm` | — |
| `.pending` (overdue) | `Color.amber50` | `Shadow.accent` | "In ritardo" amber |
| `.running` | `Color.primary50` | `Shadow.primary` | "In corso" green |
| `.done` | `Color.surface` opacity 0.6 | nessuna | "Completato" green |
| `.skipped` | `Color.surface` opacity 0.5 | nessuna | "Saltato" grigio |

**Label CTA per stato:**

| Stato step | CTA primaria | CTA secondaria |
|---|---|---|
| `.pending` (prossimo) | "Avvia" | "Vedi dettaglio" |
| `.pending` (overdue) | "Avvia" (sfondo amber) | "Vedi dettaglio" |
| `.running` | "Completa" | "Vedi dettaglio" |
| `.done` / `.skipped` | — (no CTA) | "Vedi dettaglio" |

Nota: per `.pending` overdue il PrimaryButton usa `Theme.Color.accent` come background
invece di `Theme.Color.primary`, con `Theme.Color.textOnAccent` come testo.

### 3.5 StarterCard
Card per singolo starter nella StarterView.

```
VStack(alignment: .leading, spacing: Theme.Spacing.sm) {

    // Row 1 — Nome + badge stato
    HStack {
        Text(starter.name)          // Typography.title3, textPrimary
        Spacer()
        StarterStateBadge(starter.dueState())
    }

    // Row 2 — Tipo + idratazione
    HStack(spacing: Theme.Spacing.xs) {
        Text(starter.type.title)    // Typography.footnote, textSecondary
        Text("·")
        Text("Idrat. \(Int(starter.hydration))%")
        Text("·")
        Text(starter.storageMode.title)
    }
    .font(Theme.Typography.footnote)
    .foregroundStyle(Theme.Color.textSecondary)

    // Row 3 — Ultimo rinfresco
    HStack(spacing: Theme.Spacing.xs) {
        Image(systemName: "arrow.clockwise")  // 11pt
        Text("Ultimo rinfresco: \(dataFormattata)")
    }
    .font(Theme.Typography.footnote)
    .foregroundStyle(Theme.Color.textTertiary)

    // Row 4 — Prossimo rinfresco (se overdue o dueToday, evidenziato)
    if starter.dueState() != .ok {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "exclamationmark.circle.fill")
            Text(messaggioDuoDate)
        }
        .font(Theme.Typography.footnoteSemibold)
        .foregroundStyle(dueStateColor)
    }

    Divider().foregroundStyle(Theme.Color.border)

    // Row 5 — CTA
    PrimaryButton("Rinfresca") { openRefreshSheet }
    SecondaryButton("Cronologia") { openHistory }
}
.padding(Theme.Spacing.md)
.background(Theme.Color.surface)
.squircle(radius: Theme.Radius.xl)
.themeShadow(Theme.Shadow.md)
```

**Varianti stato StarterCard:**

| Stato | Background card | Icona stato |
|---|---|---|
| `.ok` | `Color.surface` | checkmark.circle, primary |
| `.dueToday` | `Color.amber50` | clock.badge.exclamationmark, accent |
| `.overdue` | `Color.errorLight` | exclamationmark.triangle.fill, error |

### 3.6 BakeCard
Card nella lista bake (BakesView).

```
HStack(alignment: .top, spacing: Theme.Spacing.sm) {

    // Colonna sinistra — icona tipo bake
    ZStack {
        Circle()
            .fill(Theme.Color.primary100)
            .frame(width: 44, height: 44)
        Image(systemName: bakeTypeIcon)
            .font(.system(size: 20))
            .foregroundStyle(Theme.Color.primaryDark)
    }

    // Colonna destra — contenuto
    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
        HStack {
            Text(bake.name)         // Typography.headline, textPrimary
            Spacer()
            BakeStatusBadge(bake.derivedStatus)
        }
        Text(bake.type.title)       // Typography.footnote, textSecondary
        Text(dataTarget)            // Typography.footnote, textTertiary
        if bake.derivedStatus == .inProgress, let next = bake.activeStep {
            Text("Prossimo: \(next.displayName)")
                .font(Theme.Typography.caption1Semibold)
                .foregroundStyle(Theme.Color.primaryDark)
                .padding(.top, Theme.Spacing.xxs)
        }
    }

    Image(systemName: "chevron.right")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(Theme.Color.textTertiary)
}
.padding(Theme.Spacing.md)
.background(Theme.Color.surface)
.squircle(radius: Theme.Radius.lg)
.themeShadow(Theme.Shadow.sm)
```

**Icone per BakeType:**

| BakeType | SF Symbol |
|---|---|
| `.countryLoaf` | `oval.fill` |
| `.focaccia` | `rectangle.fill` |
| `.panBrioche` | `cube.fill` |
| `.pizza` | `circle.fill` |
| `.custom` | `star.fill` |

### 3.7 StateBadge (aggiornamento token)
Il componente esistente va aggiornato con i token corretti di Theme.swift v0.1.
Logica colori per stato:

| Testo | Background | Foreground |
|---|---|---|
| "In corso" / "running" | `primary100` | `primaryDark` |
| "In ritardo" / "overdue" | `errorLight` | `error` |
| "Completato" / "done" / "ok" | `primary100` | `primaryDark` |
| "Saltato" / "skipped" | `surface` | `textSecondary` |
| "Pianificato" / default | `amber100` | `accentDark` |
| "Da rinfrescare oggi" | `amber100` | `accentDark` |

### 3.8 FormField
Campo di input standard per i form di creazione.

```
VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
    Text(label)                      // Typography.caption1Semibold, textSecondary, uppercase
    TextField(placeholder, text: $value)
        .font(Theme.Typography.body)
        .padding(Theme.Spacing.md)
        .background(Theme.Color.surface)
        .squircle(radius: Theme.Radius.md)
        .squircleBorder(radius: Theme.Radius.md, color: isFocused ? primaryDark : border)
}
```

### 3.9 StepRowCompact
Usata dentro BakeDetailView per mostrare la lista degli step con focus su timeline.

```
HStack(alignment: .top, spacing: Theme.Spacing.md) {

    // Colonna orario (larghezza fissa 56pt)
    VStack(alignment: .trailing, spacing: 2) {
        Text(oraInizio)             // Typography.caption1Semibold, textPrimary
        Text(data se diversa oggi) // Typography.caption2, textTertiary
    }
    .frame(width: 56)

    // Linea temporale verticale + dot
    VStack(spacing: 0) {
        Circle()
            .fill(dotColor)
            .frame(width: 10, height: 10)
        Rectangle()
            .fill(Theme.Color.border)
            .frame(width: 2)
            .frame(maxHeight: .infinity)
    }

    // Contenuto step
    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
        Text(step.displayName)      // Typography.subheadlineSemibold, textPrimary
        Text(durata)                // Typography.caption1, textSecondary
        if step.status == .running || step.isOverdue() {
            StateBadge(step.status.title)
        }
    }
    .padding(.bottom, Theme.Spacing.md)
}
```

Colori `dotColor`:
- `.pending` (futuro): `border`
- `.pending` (overdue): `error`
- `.running`: `primary`
- `.done`: `primaryDark`
- `.skipped`: `textTertiary`

### 3.10 SectionDivider con label
Separatore tra sezioni in un form o detail screen.

```
HStack {
    Text(label)
        .font(Theme.Typography.overline)
        .foregroundStyle(Theme.Color.textTertiary)
    Rectangle()
        .fill(Theme.Color.border)
        .frame(height: 1)
}
```

---

## 4. Today Tab

### 4.1 Root — TodayView

**NavigationBar:**
- Large title: "Oggi"
- Subtitle inline (non nativo): data per esteso — `subheadline`, `textSecondary`, sotto il titolo nell'header custom se necessario, altrimenti omessa

**Struttura scroll:**
```
ScrollView {
    VStack(spacing: Theme.Spacing.xxl) {

        // Sezione 1 — "Adesso" (solo se presenti step overdue o running)
        if !nowItems.isEmpty {
            SectionHeader("Adesso", count: nowItems.count)
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(nowItems) { StepCard($0, context: .today) }
            }
        }

        // Sezione 2 — "Più tardi oggi"
        if !laterItems.isEmpty {
            SectionHeader("Più tardi oggi", count: laterItems.count)
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(laterItems) { StepCard($0, context: .today) }
            }
        }

        // Sezione 3 — "Starter" (starter refreshes due)
        if !starterItems.isEmpty {
            SectionHeader("Starter")
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(starterItems) { StarterReminderRow($0) }
            }
        }

        // Sezione 4 — "Domani" (preview, collassata)
        if !tomorrowItems.isEmpty {
            SectionHeader("Domani")
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(tomorrowItems.prefix(2)) { StepCard($0, context: .tomorrow) }
                if tomorrowItems.count > 2 {
                    Text("+ \(tomorrowItems.count - 2) altri step")
                        .font(Theme.Typography.footnote)
                        .foregroundStyle(Theme.Color.textTertiary)
                        .padding(.leading, Theme.Spacing.md)
                }
            }
        }

        // Empty state — nessun lavoro oggi
        if allItems.isEmpty {
            EmptyStateToday()
        }
    }
    .padding(.horizontal, Theme.Spacing.md)
    .padding(.bottom, Theme.Spacing.xxxl)
}
```

**EmptyStateToday:**
```
Icona:       "checkmark.circle.fill", 56pt, primary
Titolo:      "Tutto fatto per oggi"
Descrizione: "Nessuno step attivo. Crea un nuovo impasto o controlla il tuo lievito."
CTA:         PrimaryButton("Nuovo impasto") { presentNewBakeSheet }
```

### 4.2 StarterReminderRow
Riga compatta per i reminder del lievito nella Today view (non usa la StarterCard completa).

```
HStack(spacing: Theme.Spacing.md) {
    Image(systemName: dueStateIcon)
        .font(.system(size: 22))
        .foregroundStyle(dueStateColor)
        .frame(width: 32)

    VStack(alignment: .leading, spacing: 2) {
        Text(starter.name)          // Typography.subheadlineSemibold, textPrimary
        Text(messaggioDuoDate)      // Typography.footnote, dueStateColor
    }

    Spacer()

    Button("Rinfresca") { openRefreshSheet }
        .font(Theme.Typography.footnoteSemibold)
        .foregroundStyle(Theme.Color.primaryDark)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.Color.primary100)
        .squircle(radius: Theme.Radius.sm)
}
.padding(Theme.Spacing.md)
.background(Theme.Color.surface)
.squircle(radius: Theme.Radius.lg)
.themeShadow(Theme.Shadow.sm)
```

---

## 5. Bakes Tab

### 5.1 Root — BakesView

**NavigationBar:**
- Large title: "Impasti"
- Trailing button: `+` (SF `plus`) → presenta NewBakeSheet

**Struttura scroll:**
```
ScrollView {
    VStack(spacing: Theme.Spacing.xxl) {

        // Sezione 1 — "In corso"
        if !inProgressBakes.isEmpty {
            SectionHeader("In corso", count: inProgressBakes.count)
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(inProgressBakes) { BakeCard($0) }
            }
        }

        // Sezione 2 — "Pianificati"
        if !plannedBakes.isEmpty {
            SectionHeader("Pianificati", count: plannedBakes.count)
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(plannedBakes) { BakeCard($0) }
            }
        }

        // Sezione 3 — "Completati" (collassabile)
        if !completedBakes.isEmpty {
            DisclosureGroup {
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(completedBakes) { BakeCard($0).opacity(0.7) }
                }
            } label: {
                SectionHeader("Completati", count: completedBakes.count)
            }
        }

        // Empty state
        if allBakes.isEmpty {
            EmptyStateBakes()
        }
    }
    .padding(.horizontal, Theme.Spacing.md)
    .padding(.bottom, Theme.Spacing.xxxl)
}
```

**EmptyStateBakes:**
```
Icona:       "fork.knife", 48pt, textTertiary
Titolo:      "Nessun impasto"
Descrizione: "Crea il tuo primo impasto scegliendo una formula e impostando l'orario di cottura."
CTA:         PrimaryButton("Nuovo impasto") { presentNewBakeSheet }
```

### 5.2 BakeDetailView

Navigazione: push dentro BakesTab (`.navigationTitle(bake.name)`, inline).

**Struttura:**
```
ScrollView {
    VStack(spacing: Theme.Spacing.xl) {

        // Header card — riepilogo bake
        BakeHeaderCard(bake)

        // Timeline steps
        SectionHeader("Timeline")
        VStack(spacing: 0) {
            ForEach(bake.sortedSteps) { StepRowCompact($0) }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Color.surface)
        .squircle(radius: Theme.Radius.xl)

        // Azioni bake
        VStack(spacing: Theme.Spacing.sm) {
            if bake.derivedStatus != .cancelled && bake.derivedStatus != .completed {
                DestructiveButton("Annulla impasto") { confirmCancel }
            }
        }
    }
    .padding(.horizontal, Theme.Spacing.md)
    .padding(.bottom, Theme.Spacing.xxxl)
}
```

**BakeHeaderCard:**
```
VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
    HStack {
        VStack(alignment: .leading, spacing: 4) {
            Text(bake.type.title)     // Typography.caption1Semibold, textTertiary, uppercase
            Text(bake.name)           // Typography.title2, textPrimary
        }
        Spacer()
        BakeStatusBadge(bake.derivedStatus)
    }

    Divider()

    // Metriche su due colonne
    HStack(spacing: Theme.Spacing.md) {
        MetricItem(label: "Cottura", value: dataOraTarget)
        MetricItem(label: "Farina", value: "\(Int(bake.totalFlourWeight))g")
        MetricItem(label: "Idratazione", value: "\(Int(bake.hydrationPercent))%")
        MetricItem(label: "Porzioni", value: "\(bake.servings)")
    }
}
.padding(Theme.Spacing.md)
.background(Theme.Color.surface)
.squircle(radius: Theme.Radius.xl)
.themeShadow(Theme.Shadow.md)
```

**MetricItem:**
```
VStack(alignment: .leading, spacing: 2) {
    Text(label)    // Typography.caption2, textTertiary
    Text(value)    // Typography.subheadlineSemibold, textPrimary
}
.frame(maxWidth: .infinity, alignment: .leading)
```

---

## 6. Starter Tab

### 6.1 Root — StarterView

**NavigationBar:**
- Large title: "Starter"
- Trailing button: `+` (SF `plus`) → presenta NewStarterSheet

**Struttura scroll:**
```
ScrollView {
    VStack(spacing: Theme.Spacing.sm) {  // sm tra card starters
        ForEach(starters) { StarterCard($0) }
    }
    .padding(.horizontal, Theme.Spacing.md)
    .padding(.bottom, Theme.Spacing.xxxl)

    // Empty state
    if starters.isEmpty {
        EmptyStateStarter()
    }
}
```

**EmptyStateStarter:**
```
Icona:       "drop.fill", 48pt, textTertiary
Titolo:      "Nessun lievito madre"
Descrizione: "Aggiungi il tuo primo lievito per tracciare i rinfreschi e ricevere promemoria."
CTA:         PrimaryButton("Aggiungi lievito") { presentNewStarterSheet }
```

### 6.2 StarterDetailView

Navigazione: push (`.navigationTitle(starter.name)`, inline).

Accessibile: tap su StarterCard (corpo, non sul bottone "Rinfresca").

**Struttura:**
```
ScrollView {
    VStack(spacing: Theme.Spacing.xl) {

        // Header — stato lievito
        StarterDetailHeader(starter)

        // Storico rinfreschi
        SectionHeader("Rinfreschi recenti", count: starter.refreshes.count)
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(recentRefreshes) { RefreshHistoryRow($0) }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Color.surface)
        .squircle(radius: Theme.Radius.xl)

        // Impostazioni (collassabile)
        DisclosureGroup("Impostazioni") {
            StarterSettingsForm(starter)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Color.surface)
        .squircle(radius: Theme.Radius.xl)

        // CTA bottom
        PrimaryButton("Rinfresca ora") { presentRefreshSheet }
    }
    .padding(.horizontal, Theme.Spacing.md)
    .padding(.bottom, Theme.Spacing.xxxl)
}
```

**RefreshHistoryRow:**
```
HStack {
    VStack(alignment: .leading, spacing: 2) {
        Text(dataOra)               // Typography.subheadlineSemibold, textPrimary
        Text(ratioText)             // Typography.footnote, textSecondary (es. "1:2:2")
    }
    Spacer()
    VStack(alignment: .trailing, spacing: 2) {
        Text("\(Int(refresh.flourWeight))g farina")    // Typography.footnote, textSecondary
        Text("\(Int(refresh.waterWeight))g acqua")     // Typography.footnote, textSecondary
    }
}
.padding(.vertical, Theme.Spacing.xs)
```

---

## 7. Knowledge Tab

### 7.1 Root — KnowledgeView

**NavigationBar:**
- Large title: "Knowledge"
- Barra di ricerca: `.searchable(text: $query)` nativa iOS

**Struttura:**
```
ScrollView {
    VStack(spacing: Theme.Spacing.xl) {

        // Filtro categorie (horizontal scroll di pill)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                CategoryPill("Tutti", isSelected: selectedCategory == nil)
                ForEach(KnowledgeCategory.allCases) { cat in
                    CategoryPill(cat.title, isSelected: selectedCategory == cat)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
        }

        // Lista articoli
        VStack(spacing: Theme.Spacing.sm) {
            ForEach(filteredItems) { KnowledgeRow($0) }
        }
        .padding(.horizontal, Theme.Spacing.md)
    }
    .padding(.bottom, Theme.Spacing.xxxl)
}
```

**CategoryPill:**
```
Text(label)
    .font(Theme.Typography.subheadlineSemibold)
    .foregroundStyle(isSelected ? Theme.Color.textOnPrimary : Theme.Color.textSecondary)
    .padding(.horizontal, Theme.Spacing.md)
    .padding(.vertical, Theme.Spacing.xs)
    .background(isSelected ? Theme.Color.primary : Theme.Color.surface)
    .squircle(radius: Theme.Radius.full)
    .squircleBorder(radius: Theme.Radius.full,
                   color: isSelected ? .clear : Theme.Color.border)
    .animation(Theme.Animation.micro, value: isSelected)
```

**KnowledgeRow:**
```
VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
    HStack {
        Text(item.category.title)  // Typography.overline, textTertiary
        Spacer()
        Image(systemName: "chevron.right")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Theme.Color.textTertiary)
    }
    Text(item.title)               // Typography.headline, textPrimary
    Text(item.summary)             // Typography.footnote, textSecondary, lineLimit 2
}
.padding(Theme.Spacing.md)
.background(Theme.Color.surface)
.squircle(radius: Theme.Radius.lg)
.themeShadow(Theme.Shadow.sm)
```

### 7.2 KnowledgeArticleView

Navigazione: push (`.navigationTitle("")`, inline, titolo mostrato nell'header del contenuto).

```
ScrollView {
    VStack(alignment: .leading, spacing: Theme.Spacing.xl) {

        // Header articolo
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(item.category.title)   // overline, textTertiary
            Text(item.title)            // largeTitle, textPrimary
        }
        .padding(.horizontal, Theme.Spacing.md)

        // Corpo
        Text(item.content)
            .font(Theme.Typography.body)
            .foregroundStyle(Theme.Color.textPrimary)
            .lineSpacing(6)
            .padding(.horizontal, Theme.Spacing.md)

        // Tags
        if !item.tags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(item.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(Theme.Typography.caption1)
                            .foregroundStyle(Theme.Color.textTertiary)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xxs)
                            .background(Theme.Color.surface)
                            .squircle(radius: Theme.Radius.full)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }
    .padding(.vertical, Theme.Spacing.md)
    .padding(.bottom, Theme.Spacing.xxxl)
}
```

---

## 8. Flussi di creazione (Sheet)

Tutti i sheet usano `presentationDetents([.large])`, `presentationDragIndicatorVisibility(.visible)`.

### 8.1 NewBakeSheet

Titolo header: "Nuovo impasto"
CTA salvataggio: "Crea" (disabilitato finché nome e formula non sono validi)

**Sezione principale (sempre visibile):**
```
FormField("NOME IMPASTO", placeholder: "Es. Pagnotta sabato mattina", text: $name)

// Tipo impasto — segmented
VStack(alignment: .leading, spacing: xs) {
    Text("TIPO")  // caption1Semibold, textSecondary
    Picker("", selection: $type) {
        ForEach(BakeType.allCases) { Text($0.title) }
    }
    .pickerStyle(.segmented)
}

// Formula — picker stilizzato (lista dentro la sheet)
FormPickerRow("FORMULA", value: formula?.name ?? "Seleziona", hasValue: formula != nil)
    .onTapGesture { showFormulaPicker = true }

// Data e ora target
DatePickerField("COTTURA PREVISTA", selection: $targetDateTime, displayedComponents: [.date, .hourAndMinute])
```

**Sezione "Starter" (opzionale, collassabile):**
``` 
DisclosureGroup("Starter (opzionale)") {
    FormPickerRow("STARTER", value: starter?.name ?? "Nessuno", hasValue: starter != nil)
        .onTapGesture { showStarterPicker = true }
}
```

**Sezione "Avanzate" (collassabile, collapsed di default):**
```
DisclosureGroup("Impostazioni avanzate") {
    NumericField("INOCULAZIONE %", value: $inoculationPercent)
    NumericField("FARINA TOTALE (g)", value: $totalFlourWeight)
    NumericField("ACQUA TOTALE (g)", value: $totalWaterWeight)
    NumericField("PORZIONI", value: $servings)
    TextEditorField("NOTE", text: $notes)
}
```

**Flow di conferma:** dopo tap "Crea" → `BakeScheduler` genera gli step → naviga a `BakeDetailView` del bake appena creato (via `AppRouter`).

### 8.2 NewStarterSheet

Titolo header: "Nuovo lievito"
CTA: "Aggiungi"

**Sezione principale:**
```
FormField("NOME", placeholder: "Es. Licoli integrale", text: $name)

// Tipo — segmented (4 casi)
SegmentedPicker("TIPO", selection: $type, cases: StarterType.allCases)

// Idratazione — slider + label
SliderField("IDRATAZIONE", value: $hydration, range: 50...200, unit: "%")

// Intervallo rinfresco — stepper
StepperField("RINFRESCO OGNI", value: $refreshIntervalDays, range: 1...30, unit: "giorni")

// Conservazione
SegmentedPicker("CONSERVAZIONE", selection: $storageMode, cases: StorageMode.allCases)
```

**Sezione "Avanzate" (collapsible):**
```
DisclosureGroup("Informazioni aggiuntive") {
    FormField("MIX DI FARINE", placeholder: "Es. 70% farro, 30% integrale", text: $flourMix)
    NumericField("PESO CONTENITORE (g)", value: $containerWeight)
    TextEditorField("NOTE", text: $notes)
}

// Toggle reminder
Toggle("Promemoria rinfresco", isOn: $remindersEnabled)
    .tint(Theme.Color.primary)
```

### 8.3 LogRefreshSheet

Titolo header: "Rinfresca \(starter.name)"
CTA: "Salva rinfresco"

```
// Data/ora rinfresco
DatePickerField("DATA E ORA", selection: $dateTime, displayedComponents: [.date, .hourAndMinute])

// Ratio rapido — 3 campi in riga
HStack(spacing: sm) {
    NumericField("STARTER (g)", value: $starterWeightUsed)
    Text(":").foregroundStyle(textTertiary)
    NumericField("FARINA (g)", value: $flourWeight)
    Text(":").foregroundStyle(textTertiary)
    NumericField("ACQUA (g)", value: $waterWeight)
}
// Sotto i campi: preview del ratio calcolato es. "Ratio: 1 : 2 : 2"
Text("Ratio: \(ratioText)")
    .font(footnote)
    .foregroundStyle(textSecondary)

// Orario messa in frigo (opzionale)
DatePickerField("MESSA IN FRIGO", selection: $putInFridgeAt, isOptional: true)
```

**Sezione "Avanzate" (collapsible):**
```
DisclosureGroup("Dettagli avanzati") {
    NumericField("TEMPERATURA AMBIENTE (°C)", value: $ambientTemp, isOptional: true)
    TextEditorField("NOTE", text: $notes)
}
```

### 8.4 NewFormulaSheet (Phase 3)

Titolo header: "Nuova formula"
CTA: "Crea formula"

> Implementazione rimandata a Phase 3. Struttura definita qui per riferimento.

```
FormField("NOME FORMULA", ...)
SegmentedPicker("TIPO", ...)
NumericField("FARINA TOTALE (g)", ...)
NumericField("IDRATAZIONE %", ...)
NumericField("SALE %", ...)
NumericField("INOCULAZIONE %", ...)
NumericField("PORZIONI", ...)

// Step template list (gestione ordinata)
SectionHeader("Step predefiniti")
ForEach(stepTemplates) { FormulaStepTemplateRow($0) }
Button("+ Aggiungi step") { addStep }
```

---

## 9. Step Detail Sheet

Accessibile da: tap sul corpo di una `StepCard` (CTA "Vedi dettaglio") o da `StepRowCompact`.

Titolo header: nome dello step.

```
ScrollView {
    VStack(spacing: Theme.Spacing.xl) {

        // Header informativo
        StepDetailHeader(step)

        // Esecuzione
        SectionHeader("Esecuzione")
        StepExecutionCard(step)

        // Sposta timeline (solo se step non terminale)
        if !step.isTerminal {
            SectionHeader("Sposta timeline")
            TimelineShiftCard(step)
        }

        // Avanzate (collapsible)
        DisclosureGroup("Dettagli avanzati") {
            AdvancedStepFields(step)
        }
        .padding(md)
        .background(surface)
        .squircle(radius: xl)
    }
    .padding(.horizontal, md)
    .padding(.bottom, xxxl)
}
```

### StepDetailHeader
```
VStack(alignment: .leading, spacing: sm) {
    Text(step.type.title)           // overline, textTertiary
    Text(step.displayName)          // title2, textPrimary
    Text(step.descriptionText)      // body, textSecondary (se non vuoto)

    Divider()

    HStack(spacing: xl) {
        MetricItem("Inizio", oraInizio)
        MetricItem("Durata", durata)
        MetricItem("Fine prevista", oraFine)
    }
}
.padding(md)
.background(surface)
.squircle(radius: xl)
.themeShadow(Shadow.md)
```

### StepExecutionCard
Cambia in base allo stato corrente dello step.

**Stato .pending:**
```
VStack(spacing: sm) {
    PrimaryButton("Avvia step") { step.start() }
    SecondaryButton("Salta step") { step.skip() }
}
```

**Stato .running:**
```
VStack(spacing: sm) {
    // Indicatore in corso
    HStack {
        Circle().fill(primary).frame(8).overlay(pulsating animation)
        Text("Iniziato alle \(actualStart)")    // footnote, textSecondary
    }

    PrimaryButton("Completa step") { step.complete() }
    SecondaryButton("Salta step") { step.skip() }
}
```

**Stato .done o .skipped:**
```
HStack(spacing: sm) {
    Image(systemName: step.status == .done ? "checkmark.circle.fill" : "forward.circle.fill")
        .foregroundStyle(step.status == .done ? primary : textTertiary)
    VStack(alignment: .leading) {
        Text(step.status.title)        // subheadlineSemibold
        Text("alle \(actualEnd)")      // footnote, textTertiary
    }
}
// Nessuna CTA di esecuzione
```

### TimelineShiftCard
```
VStack(alignment: .leading, spacing: sm) {
    Text("Tutti gli step futuri non completati verranno spostati in avanti.")
        .font(footnote)
        .foregroundStyle(textSecondary)

    // Preset buttons in griglia 2x2
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: sm) {
        ShiftPresetButton("+15 min") { shift(15) }
        ShiftPresetButton("+30 min") { shift(30) }
        ShiftPresetButton("+1 ora")  { shift(60) }
        ShiftPresetButton("Personalizzato") { showCustomShift = true }
    }
}
.padding(md)
.background(surface)
.squircle(radius: xl)
```

**ShiftPresetButton:**
```
Text(label)
    .font(subheadlineSemibold)
    .foregroundStyle(primaryDark)
    .frame(maxWidth: .infinity)
    .padding(.vertical, sm)
    .background(primary100)
    .squircle(radius: md)
```

**Custom shift:** sheet secondario (`.medium`) con un `Stepper` o `TextField` numerico per i minuti.

---

## 10. Mappa stati visivi

### Step card — matrice completa

| Stato | Overdue? | BG card | Shadow | Badge | CTA primaria | CTA bg |
|---|---|---|---|---|---|---|
| `.pending` | No | `surface` | `sm` | — | "Avvia" | `primary` |
| `.pending` | Sì | `amber50` | `accent` | "In ritardo" | "Avvia" | `accent` |
| `.running` | No | `primary50` | `primary` | "In corso" | "Completa" | `primary` |
| `.running` | Sì | `primary50` | `primary` | "In corso · ritardo" | "Completa" | `primary` |
| `.done` | — | `surface` 0.6 | — | "Completato" | — | — |
| `.skipped` | — | `surface` 0.5 | — | "Saltato" | — | — |

### Starter card — matrice completa

| Stato | BG card | Icona | Colore icona | CTA |
|---|---|---|---|---|
| `.ok` | `surface` | `checkmark.circle.fill` | `primary` | "Rinfresca" (secondary) |
| `.dueToday` | `amber50` | `clock.badge.exclamationmark` | `accent` | "Rinfresca" (primary amber) |
| `.overdue` | `errorLight` | `exclamationmark.triangle.fill` | `error` | "Rinfresca" (primary error) |

Nota: per `.dueToday` e `.overdue` il PrimaryButton usa rispettivamente `accent` e `error` come
background invece di `primary`.

### Bake status badge

| BakeStatus | BG badge | Testo |
|---|---|---|
| `.planned` | `amber100` | "Pianificato" |
| `.inProgress` | `primary100` | "In corso" |
| `.completed` | `primary50` | "Completato" |
| `.cancelled` | `surface` | "Annullato" |

---

*UX-SPEC v1.0 — Allineato a Theme.swift v0.1 — Riferimento visivo: Planta*
*Aggiornare questo documento ad ogni decisione di design significativa.*
