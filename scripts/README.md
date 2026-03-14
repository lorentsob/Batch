# Scripts — Levain Content Formatter

## Overview

This folder contains the content formatting pipeline for Levain.

## `format_content.py`

Converts formula Markdown files from `docs/content/formulas/` into the bundled JSON format used by the app.

### Usage

```bash
python3 scripts/format_content.py
```

### What it does

1. Reads all `.md` files from `docs/content/formulas/`
2. Parses YAML frontmatter and Markdown body
3. Validates required fields and step types
4. Converts `## Steps` section to JSON step array
5. Generates UUIDs for formulas and steps
6. Appends new formulas to existing `Levain/Resources/system_formulas.json`
7. Reports validation errors and warnings

### Input format

Each formula file must have:

- **Frontmatter** with required fields:
  - `id`, `type: formula`, `title`, `category`
  - `hydration`, `salt_percent`, `inoculation_percent`, `servings`
  - `total_flour_weight`, `total_water_weight`
  - `flour_mix`, `status`

- **`## Steps` section** with format:
  ```markdown
  ## Steps
  - mix | 30
  - bulk | 480
  - shape | 120
  - bake | 12
  ```

### Output format

Generates JSON compatible with `SystemFormula` Swift model:

```json
{
  "id": "UUID",
  "name": "Formula Name",
  "type": "pane",
  "yeastType": "sourdough",
  "totalFlourWeight": 1000,
  "totalWaterWeight": 750,
  "saltWeight": 20,
  "servings": 2,
  "inoculationPercent": 20,
  "flourMix": "100% farina 00",
  "flours": [],
  "notes": "",
  "defaultSteps": [...]
}
```

### Step types

Valid step types (mapped from markdown to Swift enum):

- `autolyse` / `autolysis` → `autolysis`
- `mix` → `mix`
- `bulk` → `bulk`
- `fold` → `fold`
- `shape` → `shape`
- `proof` → `proof`
- `cold-retard` → `coldRetard`
- `bake` → `bake`
- `cool` → `cool`
- `custom` → `custom`

### Categories

Valid categories (mapped to `RecipeCategory` enum):

- `bread` → `pane`
- `pizza` → `pizza`
- `focaccia` → `focaccia`
- `sweet` → `dolci`
- `custom` → `custom`

### Workflow

When adding new formulas:

1. Write `.md` file in `docs/content/formulas/`
2. Follow the format specified in `docs/adding-contents/guida_completa_workflow_contenuti_levain.md`
3. Run `python3 scripts/format_content.py`
4. Review validation report
5. Fix any errors in the `.md` files
6. Re-run formatter
7. Commit both `.md` source and generated `.json`
8. Update tests if formula count changed

### Tests

After adding formulas, update:

- `LevainTests/SystemFormulaLoaderTests.swift` — formula count expectations

### Error handling

The formatter will:

- **Error** on missing frontmatter, invalid step types, or missing `## Steps`
- **Warn** on non-critical issues
- Exit with code 1 if any errors occurred
- Keep existing formulas and append new ones

## Dependencies

- Python 3.x
- PyYAML (`pip3 install pyyaml`)
