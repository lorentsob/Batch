#!/usr/bin/env python3
"""Export the runtime knowledge base to Markdown in docs/knowledge-export/.

Usage:
    python3 scripts/export_knowledge.py [--json PATH] [--out DIR]

Sources:
    - Levain/Resources/knowledge.json (runtime articles)
    - docs/levain-knowledge.md (editorial source, copied verbatim)

The output is fully regenerated: README.md, knowledge-base-completa.md,
source-editoriale-completa.md and one file per article in items/.
Text and fields are copied from the JSON without editorial changes.
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
JSON_SOURCE = "Levain/Resources/knowledge.json"
EDITORIAL_SOURCE = "docs/levain-knowledge.md"

CATEGORY_TITLES = {
    "bakerMath": "Baker's math",
    "fermentation": "Fermentazione",
    "starter": "Starter",
    "troubleshooting": "Troubleshooting",
}


def inline_codes(values: list[str]) -> str:
    return ", ".join(f"`{v}`" for v in values) if values else "nessuno"


def yaml_list(values: list[str]) -> str:
    return json.dumps(values, ensure_ascii=False, separators=(", ", ": "))


def article_body(item: dict) -> list[str]:
    """Body shared by the single-article files and the full export."""
    lines = [
        f"**ID:** `{item['id']}`  ",
        f"**Categoria:** `{item['category']}`",
        "",
        f"**Tag:** {inline_codes(item.get('tags') or [])}",
    ]
    aliases = item.get("aliases") or []
    if aliases:
        lines.append("")
        lines.append(f"**Alias:** {inline_codes(aliases)}")
    lines += [
        "",
        "## Sintesi",
        "",
        item["summary"],
        "",
        "## Contenuto",
        "",
        item["content"],
        "",
        "## Collegamenti app",
        "",
        f"- Step collegati: {inline_codes(item.get('relatedStepTypes') or [])}",
        f"- Stati starter collegati: {inline_codes(item.get('relatedStarterStates') or [])}",
        "",
        "---",
    ]
    return lines


def item_file(item: dict) -> str:
    front = [
        "---",
        f"id: {json.dumps(item['id'], ensure_ascii=False)}",
        f"title: {json.dumps(item['title'], ensure_ascii=False)}",
        f"category: {json.dumps(item['category'], ensure_ascii=False)}",
        f"tags: {yaml_list(item.get('tags') or [])}",
        f"aliases: {yaml_list(item.get('aliases') or [])}",
        f"relatedStepTypes: {yaml_list(item.get('relatedStepTypes') or [])}",
        f"relatedStarterStates: {yaml_list(item.get('relatedStarterStates') or [])}",
        f"source: {json.dumps(JSON_SOURCE)}",
        "---",
        "",
        f"# {item['title']}",
        "",
    ]
    return "\n".join(front + article_body(item) + ["", "[Torna all'indice](../README.md)", ""])


def full_export(items: list[dict]) -> str:
    lines = [
        "# Batch Knowledge Base completa",
        "",
        f"Export Markdown della knowledge base caricata dall'app da `{JSON_SOURCE}`.",
        "",
        f"- Articoli esportati: {len(items)}",
        "- Formato: un articolo per sezione, con metadati app preservati",
        "- Nota: il testo e i campi sono copiati dal JSON runtime senza correzioni editoriali",
        "",
        "---",
        "",
    ]
    for n, item in enumerate(items, 1):
        lines += [f"## {n}. {item['title']}", "", "", ""]
        lines += article_body(item)
        lines.append("")
    return "\n".join(lines)


def readme(items: list[dict]) -> str:
    lines = [
        "# Batch Knowledge Export",
        "",
        "Questa cartella contiene una copia Markdown esterna della knowledge base usata dall'app Batch.",
        "",
        "## File principali",
        "",
        "- [Knowledge base completa](knowledge-base-completa.md)",
        "- [Sorgente editoriale completa](source-editoriale-completa.md)",
        "- [Articoli singoli](items/)",
        "",
        "## Origine",
        "",
        f"- App runtime: `{JSON_SOURCE}`",
        f"- Sorgente editoriale: `{EDITORIAL_SOURCE}`",
        "- Rigenerazione: `python3 scripts/export_knowledge.py`",
        "",
        f"Articoli runtime esportati: **{len(items)}**.",
        "",
        "## Articoli per categoria",
    ]
    categories = sorted({i["category"] for i in items}, key=lambda c: CATEGORY_TITLES.get(c, c))
    for cat in categories:
        lines += ["", f"### {CATEGORY_TITLES.get(cat, cat)}", ""]
        for item in items:
            if item["category"] == cat:
                lines.append(f"- [{item['title']}](items/{item['id']}.md) — `{item['id']}`")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--json", type=Path, default=REPO_ROOT / JSON_SOURCE)
    parser.add_argument("--out", type=Path, default=REPO_ROOT / "docs/knowledge-export")
    args = parser.parse_args()

    items = json.loads(args.json.read_text(encoding="utf-8"))
    out: Path = args.out
    items_dir = out / "items"
    if items_dir.exists():
        shutil.rmtree(items_dir)
    items_dir.mkdir(parents=True)

    for item in items:
        (items_dir / f"{item['id']}.md").write_text(item_file(item), encoding="utf-8")
    (out / "knowledge-base-completa.md").write_text(full_export(items), encoding="utf-8")
    (out / "README.md").write_text(readme(items), encoding="utf-8")
    shutil.copyfile(REPO_ROOT / EDITORIAL_SOURCE, out / "source-editoriale-completa.md")
    print(f"Esportati {len(items)} articoli in {out}")


if __name__ == "__main__":
    main()
