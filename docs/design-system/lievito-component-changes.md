# Levain — Component Rules
> Starter screen · Bake Detail screen · Today · Shared primitives

---

## Principi generali

- Componenti nativi iOS, geometria `continuous` / squircle.
- Layout moderatamente rivisto per migliorare cluster, gerarchia e scansione.
- Niente badge guidati dal testo libero: usare solo varianti semantiche.
- Niente paragrafi operativi lunghi dentro card primarie se i dati possono essere spezzati in chip o sottosezioni.

## Starter screen

### Pulsante "Rinfresca"
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | trasparente | `#1A7D5A` (green-500) |
| Testo | `#C06A2A` (amber) | `#FFFFFF` (white) |
| Bordo | `#C06A2A` (amber) | nessuno |

È la CTA primaria — deve avere lo stesso trattamento del pulsante "Completa" nel Bake Detail.

### Pulsante "Modifica"
| Proprietà | Prima | Dopo |
|---|---|---|
| Bordo | `#C06A2A` (amber) | `#DCDEDD` (neutral-200) |
| Testo | `#C06A2A` (amber) | `#0A3828` (green-800) |
| Sfondo | trasparente | trasparente |

Azione secondaria — nessun colore proprio, solo struttura neutra.

### Pulsante back "‹"
| Proprietà | Prima | Dopo |
|---|---|---|
| Bordo | `#2C1A0E` (marrone) | `#DCDEDD` (neutral-200) |
| Icona / testo | `#2C1A0E` (marrone) | `#0A3828` (green-800) |

### Badge "Ok"
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | verde menta generico | `#E0F4EC` (green-50) |
| Testo | verde scuro generico | `#156349` (green-600) |

Token di riferimento: `badge/done` — stesso usato per le fasi completate nel Bake Detail.

### Badge "ogni 7 gg"
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | `#F5E6D3` (beige amber) | `#EDEEED` (neutral-100) |
| Testo | `#C06A2A` (amber) | `#9CA09E` (neutral-400) |

Token di riferimento: `badge/pending` — è un'informazione, non uno stato urgente.

### Tab bar — tab Starter attivo
| Proprietà | Prima | Dopo |
|---|---|---|
| Icona e label | `#C06A2A` (amber) | `#1A7D5A` (green-500) |
| Sfondo pill attivo | `#F5E6D3` (beige amber) | `#EDEEED` (neutral-100) |

---

## Bake Detail screen

### Badge "in corso" (nell'header)
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | `rgba(0,0,0,0.25)` overlay scuro | `rgba(0,0,0,0.25)` overlay scuro |
| Testo | bianco | bianco |

Invariato — l'overlay scuro su header verde è corretto e leggibile.

### Badge "in corso" (nella card step)
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | verde generico | `#1A7D5A` (green-500) |
| Testo | bianco o scuro | `#FFFFFF` (white) |

Token: `badge/running`.

### Badge "done"
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | verde generico | `#E0F4EC` (green-50) |
| Testo | verde generico | `#156349` (green-600) |

Token: `badge/done`.

### Badge "in attesa"
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | grigio generico | `#EDEEED` (neutral-100) |
| Testo | grigio generico | `#9CA09E` (neutral-400) |

Token: `badge/pending`.

### Bordo card step running
| Proprietà | Prima | Dopo |
|---|---|---|
| Colore bordo | verde generico | `#1A7D5A` (green-500) |
| Spessore | variabile | 2pt fisso |

### Bordo card step done / in attesa
| Proprietà | Prima | Dopo |
|---|---|---|
| Colore bordo | variabile | `#DCDEDD` (neutral-200) |
| Spessore | variabile | 1pt fisso |

### Pulsante "Completa" / "Avvia"
| Proprietà | Prima | Dopo |
|---|---|---|
| Sfondo | verde generico | `#1A7D5A` (green-500) |
| Testo | variabile | `#FFFFFF` (white) |

Token: `cta/primary`.

### Barra progresso
| Proprietà | Prima | Dopo |
|---|---|---|
| Track (sfondo) | grigio o verde chiaro | `#E0F4EC` (green-50) |
| Fill | verde generico | `#1A7D5A` (green-500) |

### Testo nome step (titolo card)
| Proprietà | Prima | Dopo |
|---|---|---|
| Colore | nero o marrone | `#0A3828` (green-800) |

Token: `text/primary`.

### Testo orario e durata (metadati card)
| Proprietà | Prima | Dopo |
|---|---|---|
| Colore | grigio generico | `#737876` (neutral-500) |

Token: `text/secondary`.

---

## Cluster e gerarchia

### Card primarie
- Struttura obbligatoria: titolo, stato, metadati in cluster, poi eventuale contenuto secondario.
- Una sola CTA dominante per card o sezione operativa.

### Chip
- `status/running`: stato operativo forte
- `status/done`: esito positivo / completato
- `status/pending`: attesa / pianificato
- `status/danger`: ritardo o azione distruttiva
- `info`, `count`, `schedule`: informazioni non-stato

### Testo
- Titolo massimo su 1-2 righe
- Sottotitolo breve
- I dettagli lunghi devono andare in una sezione separata o in una griglia di chip metriche

## Nota generale

Colori e ruoli fanno riferimento ai token definiti in `levain-color-rules.md`.
La struttura dei componenti può essere riordinata se serve a migliorare leggibilità, clusterizzazione e priorità dell'azione.
