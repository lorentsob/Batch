# Levain — Color Rules
> Versione 0.2 · Light mode only · Componenti nativi iOS

Questo documento definisce **solo l'applicazione dei colori**. Non descrive forma, layout o comportamento dei componenti — quelli sono nativi iOS (SwiftUI).
Da Phase 13 in poi questi token sono la base del design system condiviso (`Theme`, chip semantiche, card, CTA).

---

## Palette base

### Verde (Primary)
| Token | Hex | Uso |
|---|---|---|
| `green-25` | `#F2FAF7` | Tint box informativi |
| `green-50` | `#E0F4EC` | Badge done bg · progress track · tint leggero |
| `green-100` | `#B8E5D0` | Bordi tint box |
| `green-500` | `#1A7D5A` | **Colore funzionale primario** — header, CTA, bordi attivi, badge running, progress fill |
| `green-600` | `#156349` | Badge done text · ghost button text |
| `green-800` | `#0A3828` | **Testo primario** su card bianche |

### Neutral (Struttura)
| Token | Hex | Uso |
|---|---|---|
| `neutral-0` | `#FFFFFF` | Sfondo card · testo su verde |
| `neutral-50` | `#F7F8F7` | Sfondo app · sfondo liste |
| `neutral-100` | `#EDEEED` | Badge pending bg · CTA secondario bg |
| `neutral-200` | `#DCDEDD` | Bordi card neutri |
| `neutral-400` | `#9CA09E` | Badge pending text · testo terziario |
| `neutral-500` | `#737876` | **Testo secondario** — orari, durate, metadati |

### Sistema
| Token | Hex | Uso |
|---|---|---|
| `error` | `#E53E3E` | Step scaduti · CTA danger text |
| `error-light` | `#FEE2E2` | CTA danger bg · tint errore |

---

## Regole di applicazione

### 01 · Header e navigazione
| Elemento | Colore | Hex |
|---|---|---|
| Sfondo header | `green-500` | `#1A7D5A` |
| Titolo pagina | `neutral-0` | `#FFFFFF` |
| Back link, label nav | `neutral-0` a 60% opacità | `rgba(255,255,255,0.60)` |
| Testo secondario in header (data, info) | `neutral-0` a 65% opacità | `rgba(255,255,255,0.65)` |
| Badge in header ("in corso") | bg `rgba(0,0,0,0.25)` · testo `neutral-0` | overlay scuro |

### 02 · Sfondi e layout
| Elemento | Colore | Hex |
|---|---|---|
| Sfondo generale app | `neutral-50` | `#F7F8F7` |
| Sfondo card step (tutti gli stati) | `neutral-0` | `#FFFFFF` |

### 03 · Testi su card (sfondo bianco)
| Elemento | Colore | Hex |
|---|---|---|
| Nome step — titolo card | `green-800` | `#0A3828` |
| Orario, durata, metadati | `neutral-500` | `#737876` |
| Label sezione, overline, placeholder | `neutral-400` | `#9CA09E` |

### 04 · Bordi card
| Stato card | Colore | Hex | Spessore |
|---|---|---|---|
| Done | `neutral-200` | `#DCDEDD` | 1pt |
| In attesa (pending) | `neutral-200` | `#DCDEDD` | 1pt |
| Running (step attivo) | `green-500` | `#1A7D5A` | 2pt |

### 05 · Badge status
| Badge | Sfondo | Testo |
|---|---|---|
| "in corso" | `green-500` `#1A7D5A` | `neutral-0` `#FFFFFF` |
| "done" | `green-50` `#E0F4EC` | `green-600` `#156349` |
| "in attesa" | `neutral-100` `#EDEEED` | `neutral-400` `#9CA09E` |
| "scaduto" | `error-light` `#FEE2E2` | `error` `#E53E3E` |

### 06 · Barra progresso
| Elemento | Colore | Hex |
|---|---|---|
| Track (sfondo) | `green-50` | `#E0F4EC` |
| Fill (riempimento) | `green-500` | `#1A7D5A` |

### 07 · CTA e pulsanti
| Pulsante | Sfondo | Testo |
|---|---|---|
| Primario (Completa, Avvia) | `green-500` `#1A7D5A` | `neutral-0` `#FFFFFF` |
| Secondario | `neutral-100` `#EDEEED` | `green-800` `#0A3828` |
| Ghost / link | trasparente | `green-600` `#156349` |
| Danger (Annulla, Elimina) | `error-light` `#FEE2E2` | `error` `#E53E3E` |

---

## Regola generale

`green-500` è l'**unico colore funzionale** dell'app. Compare in esattamente 5 ruoli:
1. Sfondo header / navigazione
2. Bordo card step running (2pt)
3. Badge "in corso" — fill
4. Barra progresso — fill
5. Pulsante primario — fill

`green-800` è il testo primario su tutte le superfici bianche.  
`neutral-500` è il testo secondario. Nessun testo usa il nero puro.  
`neutral-0` (bianco) è il testo su qualsiasi superficie verde.  
Il rosso errore compare solo per step scaduti e azioni distruttive.

---

## Convenzioni Xcode

- Tutti i token vanno definiti come **Color Assets** in `Assets.xcassets`
- Naming convention: `Primary500`, `Neutral50`, `ErrorBase`, ecc.
- Nessun colore hardcoded nel codice — sempre via `Color("TokenName")` o `Theme.Color.*`
- Light mode only: nessuna variante dark da definire per ora

---

## Gerarchia visiva collegata ai token

I colori non vanno applicati in modo decorativo. Ogni schermata deve rispettare questa gerarchia:

1. **Titolo / contenuto primario**: `green-800`
2. **Metadati e testi di supporto**: `neutral-500`
3. **Chip di stato**: solo semantiche esplicite (`running`, `done`, `pending`, `danger`)
4. **Chip informativi / count / schedule**: mai derivati dal testo libero
5. **CTA primaria**: sempre `green-500` con testo bianco

### Regole di leggibilità

- Nessun blocco lungo di testo operativo dentro card primarie: spezzare in chip metriche, sottotitoli brevi, righe secondarie o sezioni dedicate.
- Mix farine, baker's math e metadati starter devono usare cluster o righe brevi, mai una stringa lunga separata da virgole se esiste un'alternativa strutturata.
- `green-500` resta il segnale funzionale forte; le informazioni non urgenti devono restare neutrali.
