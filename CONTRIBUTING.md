# Contribuire a Batch

Grazie per l’interesse nel repository. Per mantenere il flusso chiaro su un repo pubblico:

## Branch base per le pull request

- **`develop`** — apri qui le pull request per funzionalità, fix e revisioni. È il branch dove avviene lo sviluppo attivo.
- **`main`** — branch di default sul clone e stato “release”; **non aprire PR verso `main`** se non sei il maintainer del repository. Le PR di altri utenti verso `main` vengono chiuse automaticamente con un messaggio che spiega come procedere.

Il maintainer (@lorentsob) integra su `develop` e, quando appropriato, allinea o mergia verso `main`.

## Prima di aprire una PR

1. Parti da `develop` aggiornato (`git fetch origin && git checkout develop && git pull`).
2. Crea un branch feature (`feature/…` o `fix/…`).
3. Apri la PR con **base `develop`**.

## Build e CI

La CI usa un runner self-hosted; le fork esterne potrebbero non avere build verdi senza ambiente equivalente. Vedi [docs/ci-cd.md](docs/ci-cd.md).
