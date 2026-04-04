---
created: 2026-04-04T00:00
title: Aggiungi supporto lievito di birra (commerciale)
area: ui
files:
  - Levain/Features/Bakes/FormulaDetailView.swift
  - Levain/Features/Bakes/FormulaListView.swift
  - Levain/Features/Bakes/FormulaEditorView.swift
  - Levain/Features/Bakes/BakeCreationView.swift
  - Levain/Resources/system_formulas.json
  - Levain/Models/DomainEnums.swift (YeastType)
---

## Problem

L'infrastruttura dati esiste già (YeastType enum con .sourdough/.dryYeast/.freshYeast/.none, campo yeastType su RecipeFormula, picker nel FormulaEditorView), ma:
1. I template di sistema (system_formulas.json) sono TUTTI sourdough — nessun template con lievito di birra
2. FormulaDetailView non mostra il badge tipo lievito nelle statistiche (vede solo tipo ricetta, idratazione, inoculo %)
3. FormulaListView non mostra il tipo lievito nelle card formula
4. L'etichetta "Inoculo/Lievito (%)" nel FormulaEditorView non è contestuale al tipo di lievito scelto
5. L'utente non può facilmente capire o scegliere se una ricetta usa lievito madre o di birra

## Solution

- Aggiungere badge yeastType.title in FormulaDetailView (accanto agli altri badge: tipo, idratazione, inoculo)
- Aggiungere chip yeastType nel LazyVGrid delle card FormulaListView
- Rendere label inoculationPercent dinamica: "Inoculo starter (%)" per sourdough, "Lievito (%)" per commercial
- Aggiungere 2 template system_formulas.json con dryYeast: "Pizza veloce" e "Pane semplice" con lievito di birra
- Il BakeCreationView già nasconde la sezione Starter per non-sourdough — comportamento corretto
