---
status: investigating
trigger: "schermo bianco/nero al launch, avvio lento e crash apparenti senza errori console"
created: 2026-03-11T12:40:00+01:00
updated: 2026-03-11T13:07:44+01:00
---

## Current Focus

hypothesis: il blocco avviene nel primo render SwiftUI del root shell piu che nella compilazione o in un crash immediato di processo
test: ridurre il percorso critico di startup e togliere binding root troppo aggressivi verso `@Published` usati da `TabView` e `NavigationStack`
expecting: ottenere almeno il primo frame visibile in modo stabile prima di bootstrap notifiche/knowledge e prima dell'inizializzazione dei tab secondari
next_action: validare la nuova build in un simulatore non tenuto vivo da Xcode/debugserver

## Symptoms

expected: al cold launch deve comparire subito almeno una shell visibile e poi la Home operativa
actual: build verde ma schermata completamente bianca o nera; a volte parte lentamente, a volte sembra crashare; nessun errore utile in console Xcode
errors: `com.apple.runtime-issues:Slow Launch Risk` con messaggio su I/O sul main thread; nessun crash report utente pulito raccolto finora
reproduction: avvio app su iPhone 17 Pro simulator iOS 26.3 da Xcode; UI resta bianca/nera con status bar visibile
started: feedback utente del 2026-03-11 dopo la chiusura della fase 10

## Eliminated

- `INFOPLIST_KEY_UILaunchScreen_Generation = YES` da solo non risolve il launch bianco/nero
- il problema non dipende solo dal JSON knowledge caricato in sync
- il problema non dipende solo dal bootstrap notifiche in `RootTabView`
- i crash report `Levain-2026-03-11-100530/100532.ips` sono run di test (`XCTest`), non il crash utente

## Evidence

- timestamp: 2026-03-11T12:51:03+01:00
  checked: `log show` del processo `Levain`
  found: warning `Slow Launch Risk` e poi creazione della `UIWindow`, ma nessun contenuto app visibile
  implication: il processo parte, ma il primo render non arriva a schermo in modo utile

- timestamp: 2026-03-11T12:54:00+01:00
  checked: screenshot simulatore `/tmp/levain-now.png`
  found: solo status bar, sfondo bianco, nessun contenuto custom
  implication: il problema e nel rendering/layout del root view, non nel semplice boot del processo

- timestamp: 2026-03-11T13:03:25+01:00
  checked: `sample 35944 1 1`
  found: main thread bloccato in `UIApplication _firstCommitBlock` -> `SwiftUICore`/`AttributeGraph` -> `RootTabView.body.getter` -> `TabView.init`/`NavigationStack.init`
  implication: forte sospetto su loop o costo patologico nel root shell SwiftUI, non solo su store/notifiche

- timestamp: 2026-03-11T13:07:44+01:00
  checked: process tree host/simulator
  found: il processo bianco osservato era ancora tenuto vivo da `debugserver` di Xcode; `simctl install/uninstall` dal terminale restano appesi su quel device
  implication: la verifica terminal-side e sporca finche non si chiude il run Xcode o si usa un simulatore pulito

## Resolution

root_cause: ancora in validazione, ma l'evidenza punta al root shell (`RootTabView`) e ai binding/state del launch piu che a un singolo crash funzionale
fix: introdotto bootstrap asincrono del `ModelContainer`, placeholder di launch, `NotificationService` lazy, preload knowledge fuori dal path critico, snapshot locale per `TodayView`, tab secondari lazy e sincronizzazione router<->state locale in `RootTabView`
verification: build `xcodebuild -project Levain.xcodeproj -scheme Levain -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` riuscita dopo le modifiche; validazione visuale finale ancora bloccata da simulatore/Xcode con vecchio processo agganciato
files_changed:
  - Levain/App/LevainApp.swift
  - Levain/App/AppEnvironment.swift
  - Levain/Features/Shared/RootTabView.swift
  - Levain/Services/KnowledgeLoader.swift
  - Levain/Models/KnowledgeItem.swift
  - Levain/Features/Today/TodayView.swift
  - Levain/Services/TodayAgendaBuilder.swift
