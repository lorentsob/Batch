---
status: resolved
trigger: "Xcode Run fallisce su simulator con `Application failed preflight checks` per `com.lorentso.levain`"
created: 2026-03-12T11:36:18+01:00
updated: 2026-03-12T11:36:18+01:00
---

## Current Focus

hypothesis: il launch viene rifiutato da SpringBoard perche il bundle simulatore generato da XcodeGen/Xcode non contiene piu gli asset applicativi attesi, in particolare App Icon
test: ricostruire il bundle simulatore, ispezionare i file prodotti, reinstallare l'app con `simctl` sullo stesso device del report e confrontare install/launch prima e dopo il fix
expecting: trovare un difetto concreto nel prodotto buildato, non un problema generico del simulatore
next_action: mantenere il fix minimo nel project configuration e lasciare la compatibilita launch-screen invariata finche non diventa un problema reale

## Symptoms

expected: Xcode deve installare e aprire `com.lorentso.levain` sul simulatore senza errori di preflight
actual: SpringBoard rifiuta l'apertura con `FBSOpenApplicationServiceErrorDomain` e `Application failed preflight checks`
errors: `Simulator device failed to launch com.lorentso.levain`, `Busy`, `Application failed preflight checks`
reproduction: buildare e lanciare la app sul simulatore `160822F6-E593-4DBD-A297-1FA4B98AB3A6`
started: riportato il 2026-03-12 durante Run da Xcode 26.3

## Eliminated

- Un crash runtime SwiftUI o SwiftData: il processo non arrivava al launch dell'app
- Un problema generale del simulatore: `simctl install` funzionava e il device era booted
- Il plist launch screen come causa primaria: il plist generato resta annidato, ma il bundle corretto ora parte comunque

## Evidence

- timestamp: 2026-03-12T11:36:18+01:00
  checked: `/tmp/LevainDerived/Build/Products/Debug-iphonesimulator/Levain.app`
  found: il bundle iniziale non conteneva `Assets.car` ne file icona emplaced; erano presenti solo eseguibile, plist e risorse non-catalog
  implication: il target non stava compilando davvero `Assets.xcassets`, quindi il bundle installato era incompleto

- timestamp: 2026-03-12T11:36:18+01:00
  checked: log di install/launch simulator e `Info.plist` prodotto
  found: il simulatore riportava `No icon found for bundle com.lorentso.levain` e `Bundle ... has no icon`
  implication: il preflight falliva per mancanza dell'App Icon nel bundle installato

- timestamp: 2026-03-12T11:36:18+01:00
  checked: `project.yml` e `Levain.xcodeproj/project.pbxproj`
  found: `Levain/Assets.xcassets` era escluso da `sources` e la build phase Resources conteneva solo `knowledge.json`
  implication: XcodeGen stava generando un target che ignorava l'asset catalog, quindi nessun `Assets.car` finiva nel prodotto

- timestamp: 2026-03-12T11:36:18+01:00
  checked: rebuild dopo fix con `xcodegen generate` e `xcodebuild`
  found: la build esegue `actool` e produce `Assets.car`, `AppIcon60x60@2x.png` e `CFBundleIcons` nel plist
  implication: la pipeline asset e tornata coerente con le aspettative del simulatore

- timestamp: 2026-03-12T11:36:18+01:00
  checked: `xcrun simctl install` + `xcrun simctl launch` sul device `160822F6-E593-4DBD-A297-1FA4B98AB3A6`
  found: install ok e launch ok con PID `11372`
  implication: il problema di preflight e risolto

- timestamp: 2026-03-12T11:40:04+01:00
  checked: shutdown/boot del simulatore, relaunch dell'app e screenshot runtime sullo stesso device
  found: dopo reboot del simulator la UI mostra correttamente `Forno operativo`, empty state e tab bar; il bianco pieno non si ripresenta con il bundle corrente
  implication: la schermata bianca osservata dopo il fix di preflight e coerente con stato simulatore/app installata sporco, non con una root SwiftUI persistentemente rotta

## Resolution

root_cause: configurazione XcodeGen incoerente; `Assets.xcassets` era escluso dalle sorgenti del target e non entrava nella build phase Resources, producendo un bundle senza app icon e quindi non avviabile dal simulatore. Dopo la correzione, il simulatore ha anche richiesto un reboot pulito per smaltire lo stato sporco lasciato dai tentativi precedenti.
fix: rimosso l'exclude di `Assets.xcassets` da `project.yml`, eliminata la risorsa top-level inefficace, rigenerato `Levain.xcodeproj`, mantenuto `Levain/Info.plist` minimale, quindi eseguiti shutdown/boot e relaunch puliti del simulatore
verification: build simulatore riuscita, bundle contenente `Assets.car` e icone, reinstallazione pulita riuscita, launch riuscito sullo stesso UDID del report e UI runtime visibile con Home/tab bar nello screenshot successivo al reboot
files_changed:
  - project.yml
  - Levain/Info.plist
  - Levain.xcodeproj/project.pbxproj
  - .planning/debug/2026-03-12-simulator-preflight-app-icon.md
