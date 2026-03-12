# Levain

[![iOS CI](https://github.com/lorentso/lievito-app/actions/workflows/ios-ci.yml/badge.svg)](https://github.com/lorentso/lievito-app/actions/workflows/ios-ci.yml)
[![iOS Release](https://github.com/lorentso/lievito-app/actions/workflows/ios-release.yml/badge.svg)](https://github.com/lorentso/lievito-app/actions/workflows/ios-release.yml)

**Levain** è un'applicazione nativa per iPhone progettata per la gestione del lievito madre e la pianificazione operativa delle panificazioni domestiche. 

A differenza dei comuni ricettari, Levain è uno strumento **planner-first**: il suo obiettivo primario non è archiviare ricette, ma rispondere istantaneamente alla domanda: *"Cosa devo fare ora?"*.

## 🍞 Valore Core

L'app rende ovvia la prossima azione da compiere nel processo di panificazione, eliminando attriti di setup o complessità infrastrutturali. È uno strumento minimalista, offline-first e focalizzato sull'esecuzione reale in cucina.

## ✨ Funzionalità Principali

### 🗓️ Home (Oggi)
Il centro operativo dell'app. Mostra in ordine di priorità tutto ciò che richiede attenzione nelle prossime ore:
- Step di impasti in corso (imminenti o in ritardo).
- Rinfreschi del lievito madre dovuti per la giornata.
- Prossime azioni pianificate per il futuro immediato.

### 🥖 Impasti (Bakes)
Gestione completa del ciclo di vita di ogni panificazione:
- Generazione automatica di timeline basata su "Target Usage Time" (backward scheduling).
- Monitoraggio in tempo reale degli step con timer integrati.
- **Adaptive Timeline**: possibilità di slittare l'intera programmazione futura in caso di ritardi nella lievitazione reale.
- Distinzione tra tempi pianificati ed esecuzione effettiva.

### 🧪 Starter (lievito madre)
Un registro semplificato per la salute del tuo lievito:
- Log rapido dei rinfreschi con calcolo automatico della prossima scadenza.
- Gestione di parametri specifici (idratazione, mix di farine, peso del contenitore).
- Promemoria locali per non dimenticare mai un rinfresco.

### 📖 Ricette (Ricette)
Archivio di formule riutilizzabili e calcolabili:
- Definizione di parametri base (idratazione, sale, inoculo).
- Template di step predefiniti che permettono di generare un nuovo impasto in pochi secondi.
- Gestione strutturata delle farine e del tipo di lievito.

### 💡 Conoscenza (Knowledge)
Una base di conoscenza integrata e offline:
- Tips contestuali che appaiono proprio quando servono (es. durante la bulk fermentation).
- Guida alla risoluzione dei problemi comuni (troppo denso, sovralievitato, ecc.).

## 🛠️ Stack Tecnologico

L'applicazione è costruita seguendo rigorosamente i principi nativi di Apple per garantire performance e semplicità:

- **Linguaggio**: Swift 6 (Strict Concurrency).
- **UI**: SwiftUI.
- **Persistenza**: SwiftData (Modelli nativi e performanti senza database esterni).
- **Notifiche**: UserNotifications (Locali, per la massima privacy e affidabilità offline).
- **Gestione Progetto**: [XcodeGen](https://github.com/yonaskolb/XcodeGen) per una gestione trasparente del file `.xcodeproj`.

## 🚀 Sviluppo e Build

### Prerequisiti
- macOS con Xcode 16.3+ (Target iOS 26.0).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) installato (`brew install xcodegen`).

### Setup Locale
Per generare il progetto Xcode ed eseguire l'app:

```bash
# Genera il file .xcodeproj
xcodegen generate

# Apri il progetto
open Levain.xcodeproj
```

### CI/CD
Il progetto utilizza GitHub Actions per:
- **CI**: Validazione build e test unitari ad ogni push.
- **Release**: Generazione automatica di Release Candidate (manual trigger).

## 📈 Stato del Progetto

Attualmente l'app è in stato di **MVP v1 completato**. È stata sottoposta a un audit di UAT (User Acceptance Testing) che ha portato alla rifinitura della UX operativa (Fase 10).

- **Piattaforma**: Solo iPhone (ottimizzata per uso mobile in cucina).
- **Backend**: Nessuno (Single-user, Offline-first).

---
*Progettato per chi ama il pane, programmato per chi ama la semplicità.*
