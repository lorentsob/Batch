---
status: investigating
trigger: "sessione debug e miglioramento della ux... feedback UAT su home, impasti/ricette, starter, navigazione, leggibilità, colori, cancellazione bake, eliminazione bake e App Icon non riconosciuta"
created: 2026-03-11T09:34:07+01:00
updated: 2026-03-11T09:40:00+01:00
---

## Current Focus

hypothesis: i problemi emersi non sono isolati ma ricadono in quattro cluster collegati: agenda operativa, architettura informativa, form/data model ricette-starter e coerenza visuale/build assets
test: confrontare feedback UAT, UX spec, roadmap e implementazione SwiftUI/SwiftData per trasformare i gap in una fase 10 eseguibile
expecting: confermare i punti di rottura reali nel codice e raccogliere abbastanza evidenza per pianificare fix strutturali invece di patch cosmetiche
next_action: eseguire 10-01 iniziando da home clusterizzata, filtro bake annullati e nuova IA primaria/secondaria

## Symptoms

expected: la home deve mostrare cosa fare raggruppato per bake, gli impasti devono essere il centro operativo, ricette e starter devono usare campi chiari e strutturati, gli stati annullati devono sparire dal flusso operativo e l'App Icon deve essere riconosciuta dal progetto
actual: la home elenca step pending uno dopo l'altro, i bake annullati lasciano step visibili, Impasti mescola bake e formule, i form usano placeholder al posto di label e campi testo liberi dove servono selezioni strutturate, vari token visuali e colori sono incoerenti, l'App Icon non viene recepita correttamente
errors: nessun crash raccolto; problemi principalmente di stato derivato, IA, copy, contrasto e asset recognition
reproduction: creare un bake, annullarlo e tornare in home; aprire Impasti e Nuova formula/Nuovo bake/Starter; verificare tab, chip stato, campi ingredienti e App Icon nel progetto buildato
started: emerso durante UAT manuale del 2026-03-11

## Eliminated

## Evidence

- timestamp: 2026-03-11T09:34:07+01:00
  checked: `Levain/Services/TodayAgendaBuilder.swift`
  found: l'agenda itera tutti gli step non terminali di ogni bake senza escludere i bake annullati e produce item per step, non per bake
  implication: spiega sia i pending residui dopo annullamento sia la home troppo frammentata

- timestamp: 2026-03-11T09:34:07+01:00
  checked: `Levain/Features/Today/TodayView.swift`
  found: la root usa titolo "Oggi", metriche generiche e una lista piatta di card step/starter
  implication: la home non riflette piu l'obiettivo operativo richiesto dall'UAT

- timestamp: 2026-03-11T09:34:07+01:00
  checked: `Levain/Features/Bakes/BakesView.swift` e `Levain/Features/Shared/RootTabView.swift`
  found: Impasti combina bake e formule nello stesso root e il tab usa `birthday.cake.fill`; Knowledge occupa un tab primario
  implication: l'architettura informativa attuale non segue il posizionamento bake-first richiesto

- timestamp: 2026-03-11T09:34:07+01:00
  checked: `Levain/Features/Bakes/FormulaEditorView.swift` e `Levain/Features/Starter/StarterEditorView.swift`
  found: mix farine e note usano campi testuali liberi, molte voci si affidano al placeholder e manca una tassonomia strutturata per farine e lieviti
  implication: servono insieme modifica del modello dati e riallineamento form UX

- timestamp: 2026-03-11T09:34:07+01:00
  checked: `docs/UX-SPEC.md` vs `Levain/DesignSystem/Theme.swift`, `StateBadge.swift`, schermate correnti
  found: il design system documentato e la UX spec non corrispondono piu all'implementazione reale; colori di stato e leggibilita non sono coerenti
  implication: la fase deve includere un pass di compliance visuale, non solo bugfix funzionali

- timestamp: 2026-03-11T09:34:07+01:00
  checked: `Levain/Assets.xcassets/AppIcon.appiconset/Contents.json`, `project.yml`, `Levain.xcodeproj/project.pbxproj`, dimensioni PNG
  found: `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` e le dimensioni PNG sono corrette, ma `Contents.json` punta a `Icon-1024.png` mentre il file presente e `icon-1024.png`
  implication: il problema App Icon va trattato come debug tecnico specifico su asset naming/build cache/validazione bundle, non come semplice mancanza di configurazione

## Resolution

root_cause: da confermare; l'evidenza punta a una combinazione di IA non piu coerente col prodotto, modello dati troppo minimale per ricette/starter e assenza di un pass finale di compliance visuale/asset
fix: creata la fase 10 con contesto, tre piani eseguibili, requisiti dedicati e tracciamento del bug App Icon dentro il debug log e nel plan 10-03
verification: da eseguire nella fase 10 con build, test e UAT manuale mirata
files_changed:
  - .planning/debug/2026-03-11-uat-ux-realignment.md
  - .planning/phases/10-operational-ux-realignment/10-CONTEXT.md
  - .planning/phases/10-operational-ux-realignment/10-01-PLAN.md
  - .planning/phases/10-operational-ux-realignment/10-02-PLAN.md
  - .planning/phases/10-operational-ux-realignment/10-03-PLAN.md
  - .planning/ROADMAP.md
  - .planning/STATE.md
  - .planning/PROJECT.md
  - .planning/REQUIREMENTS.md
