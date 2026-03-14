# Levain Design System Documentation

**Version:** 2.0
**Platform:** iOS Native
**UI Framework:** SwiftUI
**Typography:** SF Pro
**Theme:** Light mode only
**Last updated:** 2026-03-13

---

## Semantic Rule (read this first)

> **Verde = azione + piano** — tutto ciò che richiede o richiederà attenzione.
> **Grigio neutro = passato/archiviato** — solo lo stato `.done` e `.skipped`.
> **Rosso = problema** — ritardo, scaduto, azione distruttiva.

Nessun amber. Tre famiglie, un significato ciascuna.

---

## Table of Contents

1. [Color Palette](#color-palette)
2. [Semantic Tokens](#semantic-tokens)
3. [Typography](#typography)
4. [Spacing & Layout](#spacing--layout)
5. [Radius & Corners](#radius--corners)
6. [Component Library](#component-library)
7. [Button Styles](#button-styles)
8. [Shadow System](#shadow-system)

---

## Color Palette

### Green Scale — Brand, azioni, stati attivi, pianificato

```
green25   #F2FAF7   — Lightest tint, sfondo running card
green50   #E0F4EC   — Running card background
green100  #B8E5D0   — Planned badge bg, emphasis borders
green500  #1A7D5A   — Azioni primarie, running badge, tab tint
green600  #156349   — Primary dark — pressed, nav tint
green800  #0A3828   — Testo primario — heading, body
```

### Neutral Scale — Superfici, bordi, testo secondario, archiviato

```
neutral0    #FFFFFF   — Superfici card, pure white
neutral50   #F7F8F7   — App background
neutral100  #EDEEED   — Done badge bg, superfici sottili
neutral200  #DCDEDC   — Bordi default, done timeline dot
neutral400  #9CA09E   — SOLO elementi decorativi/disabled — NON usare per testo leggibile
neutral500  #737876   — Testo secondario — metadati, descrizioni (4.6:1)
neutral600  #4A4E4C   — Testo terziario — label, timestamp, overline (7.2:1) ← nuovo in v2.0
```

> **Nota v2.0:** `neutral400` era usato come `textTertiary` in v1.0 con ratio 2.9:1 (fail WCAG AA).
> Sostituito da `neutral600` (#4A4E4C) che raggiunge 7.2:1. `neutral400` ora è riservato
> esclusivamente a icone decorative, separatori e placeholder.

### Error Scale — Problemi, ritardi, azioni distruttive

```
error       #E53E3E   — Danger CTA background, bordi danger
errorDark   #9B1C1C   — Testo error su sfondo chiaro (WCAG AA su errorLight)
errorLight  #FEE2E2   — Overdue/danger card background
errorBorder #FECACA   — Overdue/danger card border
```

---

## Semantic Tokens

### Surface Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `Theme.Surface.app` | `neutral50` | Main app background |
| `Theme.Surface.card` | `neutral0` | Card backgrounds default |
| `Theme.Surface.subtle` | `neutral100` | Superfici secondarie |
| `Theme.Surface.tinted` | `green25` | Sfondo tinted section cards |
| `Theme.Surface.running` | `green50` | StepCard in stato .running |
| `Theme.Surface.planned` | `neutral0` | StepCard in stato .pending (badge porta il verde) |
| `Theme.Surface.done` | `neutral50` | StepCard in stato .done, opacity 0.6 |
| `Theme.Surface.danger` | `errorLight` | StepCard/StarterCard in stato overdue |
| `Theme.Surface.header` | `green500` | Header bar backgrounds |

### Text Tokens

| Token | Value | Contrasto | Usage |
|-------|-------|-----------|-------|
| `Theme.Text.primary` | `green800` | 13:1 | Body, heading |
| `Theme.Text.secondary` | `neutral500` | 4.6:1 | Metadati, descrizioni |
| `Theme.Text.tertiary` | `neutral600` | 7.2:1 | Label UPPERCASE, timestamp, context row |
| `Theme.Text.onPrimary` | `neutral0` | — | Testo su verde (bottoni, running badge) |
| `Theme.Text.onDanger` | `errorDark` | 6.5:1 | Testo su errorLight |
| `Theme.Text.onHeaderSubtle` | `neutral0 @ 65%` | — | Testo subdued su header verde |
| `Theme.Text.disabled` | `neutral400` | — | Solo placeholder e elementi non-interattivi |

### Border Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `Theme.Border.defaultColor` | `neutral200` | Bordi standard card |
| `Theme.Border.emphasis` | `green100` | Card pianificate, tinted |
| `Theme.Border.active` | `green500` | Stato focused nei form |
| `Theme.Border.danger` | `errorBorder` | Card overdue |
| `Theme.Border.done` | `neutral200 @ 60%` | Card completate (dimmed) |

### Status Tokens — Badge e stati

| Stato | Background | Foreground | Semantica |
|-------|-----------|------------|-----------|
| `.running` | `green500` | `neutral0` | Verde pieno — accade adesso |
| `.pending` | `green100` | `green800` | Verde tenue — nel piano, arriverà |
| `.done` | `neutral100` | `neutral600` | Grigio — archiviato, nessuna azione |
| `.skipped` | `neutral100` | `neutral500` | Grigio dimmer — saltato |
| `.overdue` | `errorLight` | `errorDark` | Rosso — problema attivo |
| `.danger` | `errorLight` | `errorDark` | Rosso — critico |
| `.info` | `green25` | `green600` | Verde minimo — informativo |
| `.count` | `green50` | `green800` | Verde leggero — metriche |

### Control Tokens — Bottoni

#### Primary Button
- **Fill:** `green500`
- **Foreground:** `neutral0`
- **Usage:** Tutti i CTA principali — Avvia, Completa, Rinfresca, Salva, Crea

#### Secondary Button ← modificato in v2.0
- **Fill:** `transparent` (outline style)
- **Foreground:** `green800`
- **Border:** `green500`, 1.5pt
- **Usage:** CTA secondari su card non-danger — Avvia (pending non-urgente), Rinfresca (starter ok)
- **Motivazione:** Il vecchio `neutral100` bg comunicava neutralità anche per azioni che sono verdi per semantica.

#### Danger Button
- **Fill:** `error` (#E53E3E)
- **Foreground:** `neutral0`
- **Usage:** Azioni distruttive (Annulla impasto, Elimina) e CTA primari su card overdue (Avvia ora, Rinfresca subito)

#### Tab Bar
- **Active Tint:** `green500`
- **Background:** `neutral0`

---

## Typography

**Font Family:** SF Pro (iOS System Font)

| Style | Weight | Size | Line Height | Usage |
|-------|--------|------|-------------|-------|
| Large Title | Regular | 34pt | 41pt | Titoli tab root |
| Title 1 | Bold | 28pt | 34pt | Section headers |
| Title 2 | Bold | 22pt | 28pt | Card headers |
| Title 3 | Semibold | 20pt | 25pt | Step name, label primari |
| Headline | Semibold | 17pt | 22pt | Button text, label prominenti |
| Subheadline | Regular | 15pt | 20pt | Label secondari |
| Subheadline Semibold | Semibold | 15pt | 20pt | Label secondari enfatizzati |
| Body | Regular | 17pt | 22pt | Body text |
| Caption 1 | Regular | 12pt | 16pt | Timestamp, metadata |
| Caption 1 Semibold | Semibold | 12pt | 16pt | Metadata enfatizzati |
| Caption 2 | Regular | 11pt | 13pt | Fine print |
| Footnote | Regular | 13pt | 18pt | Helper text, durata |
| Footnote Semibold | Semibold | 13pt | 18pt | Helper enfatizzati |
| Overline | Semibold | 11pt | 13pt | Section label (UPPERCASE) — usa `textTertiary` |

---

## Spacing & Layout

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 4pt | Inner chip padding, gap minimo |
| `xs` | 8pt | Tra elementi correlati in una riga |
| `sm` | 8pt | Tra card in lista |
| `md` | 16pt | Padding interno card, margini schermata |
| `lg` | 24pt | Tra sezioni major in una card |
| `xl` | 32pt | — |
| `xxl` | 48pt | Tra sezioni nei tab view |
| `xxxl` | 64pt | Bottom padding scroll clearance |

### ScrollView Standard

```swift
.padding(.horizontal, Theme.Spacing.md)   // 16pt
.padding(.top, Theme.Spacing.sm)          // 8pt
.padding(.bottom, Theme.Spacing.xxxl)     // 64pt
```

---

## Radius & Corners

Tutti i corner usano `.continuous` (squircle).

| Token | Value | Usage |
|-------|-------|-------|
| `Theme.Radius.card` | 28pt | StepCard, StarterCard, BakeCard |
| `Theme.Radius.nestedCard` | 22pt | Card annidate dentro card |
| `Theme.Radius.control` | 18pt | Primary buttons |
| `Theme.Radius.compact` | 16pt | Secondary/danger buttons, form fields |
| `Theme.Radius.full` | 9999pt | Pill badge, capsule |

---

## Component Library

### 1. StepCard

**Purpose:** Card principale di esecuzione. TodayView e BakeDetailView.

**Varianti per stato:**

| Stato | Background | Shadow | Badge | CTA label | CTA style |
|-------|-----------|--------|-------|-----------|-----------|
| `.pending` future | `surface.card` | `sm` | `.pending` "Pianificato" | "Avvia" | SecondaryOutline |
| `.pending` overdue | `surface.danger` | `danger` | `.overdue` "In ritardo" | "Avvia ora" | DangerFilled |
| `.running` | `surface.running` | `primary` | `.running` "In corso" | "Completa" | PrimaryFilled |
| `.done` | `surface.done @ 0.6` | none | `.done` "Completato" | — | — |
| `.skipped` | `surface.done @ 0.5` | none | `.skipped` "Saltato" | — | — |

> **Nota:** `.done` usa grigio neutro — non verde — perché comunica "archiviato", non "successo".
> `.pending` usa verde tenue perché è ancora parte del piano attivo.

**Measurements:**
- Padding: `md` (16pt)
- Corner radius: `card` (28pt)
- Row spacing: `sm` (8pt)

---

### 2. StarterCard

**Varianti per stato:**

| Stato | Background | CTA label | CTA style |
|-------|-----------|-----------|-----------|
| `.ok` | `surface.card` | "Rinfresca" | SecondaryOutline |
| `.dueToday` | `surface.card` | "Rinfresca" | PrimaryFilled |
| `.overdue` | `surface.danger` | "Rinfresca subito" | DangerFilled |

> **Nota v2.0:** `.dueToday` usa PrimaryFilled verde (non amber). Il contesto della card
> è sufficiente a distinguere urgenza lieve da critica. `.overdue` usa DangerFilled rosso.

---

### 3. StateBadge

**Spec:**
- Shape: Capsule (`.full` radius)
- Padding: 10pt horizontal, 6pt vertical
- Typography: Caption1 Semibold

**Toni:**

| Tone | Background | Foreground | Testo label |
|------|-----------|------------|-------------|
| `.running` | `green500` | `neutral0` | "In corso" |
| `.pending` | `green100` | `green800` | "Pianificato" |
| `.done` | `neutral100` | `neutral600` | "Completato" |
| `.skipped` | `neutral100` | `neutral500` | "Saltato" |
| `.overdue` | `errorLight` | `errorDark` | "In ritardo" |
| `.danger` | `errorLight` | `errorDark` | "Scaduto" |
| `.info` | `green25` | `green600` | contestuale |
| `.count` | `green50` | `green800` | valore numerico |

---

### 4. StepRowCompact (Timeline)

**Dot colors per stato:**

| Status | Dot | Ring | Semantica |
|--------|-----|------|-----------|
| `.done` | `neutral200` | — | Piatto, passato |
| `.running` | `green500` | `green50` (3pt ring) | Attivo, con alone verde |
| `.pending` future | `green100` | bordo `green500 @ 40%` | Verde tenue, nel piano |
| `.pending` overdue | `error` | — | Rosso, problema |
| `.skipped` | `neutral200` | — | Come done |

---

### 5. MetricChip

- Label: Caption2 Semibold, `textTertiary` (neutral600), UPPERCASE
- Value: Footnote Semibold, `textPrimary`
- Padding: 12pt H, 10pt V
- Corner radius: `compact` (16pt)
- Border: 1.5pt `emphasis` (green100)
- Background: `surface.card`
- Danger tone: `errorLight` bg, `errorDark` value, `errorBorder` border

---

### 6. SectionCard

| Emphasis | Background | Border | Opacity |
|----------|-----------|--------|---------|
| `.surface` | `neutral0` | `neutral200` | 1.0 + shadow |
| `.subtle` | `neutral100` | `neutral200` | 0.72 |
| `.tinted` | `green25` | `green100` 1.25pt | 0.72 |
| `.danger` | `errorLight` | `errorBorder` | 0.72 |

---

### 7. Form Components

- **Label:** Caption1 Semibold, `textTertiary` (neutral600), UPPERCASE
- **Input:** Body, padding 16pt
- **Background:** `surface.card`
- **Border:** 1.5pt `border.defaultColor` / active: `green600`
- **Corner radius:** `compact` (16pt)
- **Accent color** (slider, segmented): `green500`

---

## Button Styles

### 1. PrimaryActionButtonStyle

```
Font:           Headline Semibold (17pt)
Foreground:     neutral0
Background:     green500
Corner Radius:  18pt (.continuous)
Padding:        15pt vertical
Width:          .infinity
Press:          scale 0.985, 0.15s easeOut
```

**Variante Danger** (overdue CTA):
```
Background:     error (#E53E3E)
Foreground:     neutral0
```

---

### 2. SecondaryActionButtonStyle ← aggiornato in v2.0

```
Font:           Subheadline Semibold (15pt)
Foreground:     green800
Background:     clear (outline)
Border:         green500, 1.5pt
Corner Radius:  16pt (.continuous)
Padding:        13pt vertical
Width:          .infinity
Press:          scale 0.99, 0.15s easeOut
```

> **Motivazione:** La versione v1.0 usava `neutral100` background. Essendo i secondary button
> sempre azioni verdi (Avvia, Rinfresca, Vedi dettaglio), il background neutro creava
> incoerenza semantica. L'outline verde è visivamente distinto dal primary filled ma mantiene
> la famiglia colore corretta.

---

### 3. DangerActionButtonStyle

```
Font:           Subheadline Semibold (15pt)
Foreground:     neutral0
Background:     error (#E53E3E)
Corner Radius:  16pt (.continuous)
Padding:        13pt vertical
Width:          .infinity
Press:          scale 0.99, 0.15s easeOut
```

---

## Shadow System

```swift
// Card standard
.shadow(color: Theme.Shadow.card, radius: 18, y: 8)
// green800 @ 6%

// Running card (green tinted)
.shadow(color: Theme.Shadow.primary, radius: 18, y: 8)
// green500 @ 12%

// Overdue/danger card (red tinted)
.shadow(color: Theme.Shadow.danger, radius: 18, y: 8)
// error @ 10%

// Done / Skipped — nessuna shadow
```

---

## Changelog v1.0 → v2.0

| Cosa | v1.0 | v2.0 | Motivazione |
|------|------|------|-------------|
| `textTertiary` | `neutral400` (2.9:1) | `neutral600` (7.2:1) | WCAG AA compliance |
| Badge `.done` | `green50` bg + `green600` fg | `neutral100` bg + `neutral600` fg | Done = archiviato, non success |
| Badge `.pending` | `neutral100` bg + `neutral400` fg | `green100` bg + `green800` fg | Pending = nel piano, verde |
| Badge `.overdue` | assente (era inline amber) | `errorLight` bg + `errorDark` fg | Problema = rosso, no amber |
| SecondaryButton bg | `neutral100` | `clear` (outline verde) | Azioni secondarie sono azioni verdi |
| SecondaryButton border | `neutral200` | `green500` | Coerenza semantica |
| PrimaryButton amber variant | presente | rimossa | Amber eliminato dal sistema |
| Timeline dot `.done` | `green600` | `neutral200` | Done = passato, non attivo |
| Timeline dot `.pending` | `neutral200` | `green100` + bordo verde | Pending = nel piano |
| Amber scale | parzialmente usata | rimossa | Tre famiglie bastano: verde/grigio/rosso |

---

## Design Principles

1. **Action-First:** ogni schermata risponde a "cosa devo fare adesso?"
2. **One Primary Action:** ogni card ha un solo CTA dominante
3. **Generous Whitespace:** 48pt tra sezioni major
4. **Progressive Disclosure:** opzioni avanzate nascoste di default
5. **Squircle Everything:** continuous corner style ovunque
6. **Green Means Active:** verde solo per azione presente o piano futuro — mai per il passato
7. **Status-Driven UI:** lo stato visivo riflette lo stato dei dati

---

**Source of Truth:** `/Levain/DesignSystem/Theme.swift`
