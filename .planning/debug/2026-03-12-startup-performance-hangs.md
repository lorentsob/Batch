---
status: resolved
trigger: "l'app e lenta al lancio e tende a bloccarsi dopo il fix simulator"
created: 2026-03-12T12:02:00+01:00
updated: 2026-03-12T12:02:00+01:00
---

## Current Focus

hypothesis: il primo frame e l'interazione iniziale vengono rallentati dal bootstrap notifiche eseguito su `@MainActor`, con resync completo a ogni launch e possibile assenza del record `AppSettings`
test: leggere bootstrap root, stato `AppSettings` e `NotificationService`, poi spostare l'I/O notifiche fuori dal main actor e rendere il launch sync one-shot
expecting: ridurre sensibilmente il lavoro startup-time e togliere i blocchi percepiti senza cambiare routing o modello dati
next_action: verificare il comportamento su device/simulator quando CoreSimulator torna stabile

## Symptoms

expected: l'app deve mostrare Home rapidamente e restare responsiva durante launch e prime azioni operative
actual: l'app appare lenta, vischiosa e in alcuni casi sembra bloccarsi
errors: nessun crash affidabile; il sospetto principale e lavoro bootstrap eccessivo su main actor
reproduction: aprire l'app dopo la fase 11, osservare lentezza al primo frame e dopo azioni che salvano bake/starter
started: riportato il 2026-03-12 in UAT manuale post-fix simulator

## Evidence

- timestamp: 2026-03-12T12:02:00+01:00
  checked: `Levain/Features/Shared/RootTabView.swift`
  found: il bootstrap faceva `requestAuthorizationIfNeeded` e `resyncAll(using:)` inline nel `.task` della root
  implication: il lancio eseguiva side effects non essenziali immediatamente, aumentando la probabilita di jank o hang percepito

- timestamp: 2026-03-12T12:02:00+01:00
  checked: `Levain/Services/NotificationService.swift`
  found: l'intero service e `@MainActor` e il resync iterava bake/starter chiamando `UNUserNotificationCenter.add` in loop dal main actor
  implication: scheduling notifiche e XPC verso il notification center potevano rubare tempo al rendering e alle interazioni

- timestamp: 2026-03-12T12:02:00+01:00
  checked: `RootTabView.loadAppSettings`
  found: il codice precedente leggeva `AppSettings` ma non lo garantiva; se assente, il bootstrap notifiche si comportava come primo launch ogni volta
  implication: il cold sync poteva ripetersi inutilmente a ogni apertura

## Resolution

root_cause: bootstrap notifiche troppo aggressivo e non idempotente, con lavoro di scheduling fatto su `@MainActor` e assenza di garanzia sul record `AppSettings`
fix: garantita la creazione di `AppSettings`, reso il notification bootstrap non bloccante e one-shot al launch, e spostata la fase di remove/add notification requests fuori dal main actor tramite payload plain-data
verification: verifica statica del flusso aggiornata; conferma runtime completa dipendente da CoreSimulator stabile o device reale
files_changed:
  - Levain/Features/Shared/RootTabView.swift
  - Levain/Services/NotificationService.swift
  - .planning/debug/2026-03-12-startup-performance-hangs.md
