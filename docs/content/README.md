# Batch Content — Editorial Source

Questa cartella contiene i **contenuti editoriali sorgente** per l'app Levain.

## Struttura

```
docs/content/
├── formulas/           # Formule strutturate (ricette)
│   ├── pizza-in-giornata.md
│   ├── focaccia-tiktok.md
│   ├── pan-brioche-lievito-madre.md
│   ├── bagel-levain.md
│   └── potato-buns.md
├── knowledge/          # Contenuti informativi (placeholder futuro)
├── categories.md       # Vocabolario categorie
└── step-types.md       # Vocabolario step types
```

## Workflow completo

Vedere: `docs/adding-contents/guida_completa_workflow_contenuti_levain.md`

## Formule attuali

### Incluse nel bundle (8 totali)

**Formule originali (3):**
1. Pane di campagna
2. Pizza napoletana
3. Focaccia classica

**Nuove formule aggiunte (5):**
1. Pizza in giornata — Pizza tonda da fare in giornata con lievito madre
2. Focaccia Tiktok — Focaccia ad alta idratazione con maturazione in frigo
3. Pan Brioche — Dolce lievitato con lievito madre e burro
4. Bagel — Bagel con levain e bollitura pre-cottura
5. Potato Buns — Panini dolci con patate e levain liquido

## Aggiungere nuove formule

1. Scrivi il file `.md` in `docs/content/formulas/`
2. Segui il formato specificato nella guida completa
3. Usa solo categorie e step types definiti in `categories.md` e `step-types.md`
4. Esegui il formatter: `python3 scripts/format_content.py`
5. Verifica il report di validazione
6. Correggi eventuali errori nei file `.md`
7. Aggiorna i test se hai cambiato il numero totale di formule
8. Commit sia dei `.md` che del `system_formulas.json` generato

## Output tecnico

Il formatter converte i Markdown in:

```
Levain/Resources/system_formulas.json
```

Questo file viene caricato dall'app tramite `SystemFormulaLoader.swift`.

## Regole fondamentali

1. **I file `.md` sono la sorgente di verità** — non modificare mai il JSON a mano
2. **Usa solo vocabolari ufficiali** — categorie e step types definiti nei file dedicati
3. **Spiega i compromessi** — se usi valori conservativi o `custom` step, documentalo in `## Notes`
4. **Valida sempre** — esegui il formatter e controlla errori e warning prima di committare
5. **Status `draft` o `ready`** — usa `status: draft` se la formula ha ancora limitazioni non risolte

## Prossimi passi

- Contenuti `knowledge/` (guide, articoli, troubleshooting)
- Formatter per knowledge (simile al formatter formule)
- Gestione immagini e media (placeholder)
