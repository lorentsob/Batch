#!/usr/bin/env python3
"""
Content formatter for Levain
Converts Markdown formulas from docs/content/ to JSON for the app bundle
"""

import json
import re
import uuid
import yaml
from pathlib import Path
from typing import Dict, List, Any, Optional


# Step type mapping from markdown to Swift enum rawValue
STEP_TYPE_MAPPING = {
    'starterRefresh': 'starterRefresh',
    'autolyse': 'autolysis',
    'autolysis': 'autolysis',
    'mix': 'mix',
    'bulk': 'bulk',
    'fold': 'fold',
    'preshape': 'preshape',
    'bench-rest': 'benchRest',
    'shape': 'shape',
    'proof': 'proof',
    'cold-retard': 'coldRetard',
    'bake': 'bake',
    'cool': 'cool',
    'custom': 'custom'
}

# Step type to Italian title mapping
STEP_TITLES = {
    'starterRefresh': 'Rinfresco starter',
    'autolysis': 'Autolisi',
    'mix': 'Impasto',
    'bulk': 'Bulk fermentation',
    'fold': 'Pieghe',
    'preshape': 'Preforma',
    'benchRest': 'Bench rest',
    'shape': 'Formatura',
    'proof': 'Appretto',
    'coldRetard': 'Cold retard',
    'bake': 'Cottura',
    'cool': 'Raffreddamento',
    'custom': 'Fase personalizzata'
}

# Category mapping
CATEGORY_MAPPING = {
    'bread': 'pane',
    'pizza': 'pizza',
    'focaccia': 'focaccia',
    'sweet': 'dolci',
    'custom': 'custom'
}

# YeastType defaults
YEAST_TYPE_DEFAULT = 'sourdough'


class ValidationError(Exception):
    """Raised when content validation fails"""
    pass


class ContentFormatter:
    def __init__(self):
        self.errors = []
        self.warnings = []

    def parse_markdown(self, file_path: Path) -> tuple[Dict[str, Any], str]:
        """Parse markdown file and extract frontmatter and body"""
        content = file_path.read_text(encoding='utf-8')

        # Extract frontmatter
        frontmatter_match = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)$', content, re.DOTALL)
        if not frontmatter_match:
            raise ValidationError(f"No frontmatter found in {file_path.name}")

        frontmatter_str, body = frontmatter_match.groups()
        frontmatter = yaml.safe_load(frontmatter_str)

        return frontmatter, body

    def extract_steps_section(self, body: str) -> Optional[str]:
        """Extract ## Steps section from markdown body"""
        steps_match = re.search(r'^## Steps\s*\n(.*?)(?=\n##|\Z)', body, re.MULTILINE | re.DOTALL)
        if steps_match:
            return steps_match.group(1).strip()
        return None

    def parse_steps(self, steps_text: str) -> List[Dict[str, Any]]:
        """Parse steps from markdown format to JSON format"""
        if not steps_text:
            raise ValidationError("Empty steps section")

        steps = []
        for line in steps_text.split('\n'):
            line = line.strip()
            if not line or not line.startswith('-'):
                continue

            # Parse format: - step_type | duration
            match = re.match(r'-\s*(\S+)\s*\|\s*(\d+)', line)
            if not match:
                self.warnings.append(f"Could not parse step line: {line}")
                continue

            step_type_md, duration_str = match.groups()

            # Map to Swift enum rawValue
            if step_type_md not in STEP_TYPE_MAPPING:
                raise ValidationError(f"Unknown step type: {step_type_md}")

            step_type_raw = STEP_TYPE_MAPPING[step_type_md]
            duration = int(duration_str)

            step = {
                'id': str(uuid.uuid4()).upper(),
                'name': STEP_TITLES.get(step_type_raw, 'Fase personalizzata'),
                'typeRaw': step_type_raw,
                'durationMinutes': duration,
                'details': '',
                'notes': '',
                'reminderOffsetMinutes': 0,
                'temperatureRange': '',
                'volumeTarget': ''
            }
            steps.append(step)

        if not steps:
            raise ValidationError("No valid steps found")

        return steps

    def validate_frontmatter(self, frontmatter: Dict[str, Any], file_name: str):
        """Validate required frontmatter fields"""
        required = ['id', 'type', 'title', 'category', 'hydration', 'salt_percent',
                   'inoculation_percent', 'servings', 'total_flour_weight',
                   'total_water_weight', 'status']

        for field in required:
            if field not in frontmatter:
                raise ValidationError(f"{file_name}: Missing required field '{field}'")

        if frontmatter['type'] != 'formula':
            raise ValidationError(f"{file_name}: Type must be 'formula', got '{frontmatter['type']}'")

        # Validate category
        if frontmatter['category'] not in CATEGORY_MAPPING:
            raise ValidationError(f"{file_name}: Unknown category '{frontmatter['category']}'")

    def convert_formula(self, file_path: Path) -> Dict[str, Any]:
        """Convert a single formula markdown file to JSON format"""
        print(f"Processing {file_path.name}...")

        # Parse markdown
        frontmatter, body = self.parse_markdown(file_path)

        # Validate
        self.validate_frontmatter(frontmatter, file_path.name)

        # Extract and parse steps
        steps_text = self.extract_steps_section(body)
        if not steps_text:
            raise ValidationError(f"{file_path.name}: No ## Steps section found")

        steps = self.parse_steps(steps_text)

        # Calculate salt weight
        total_flour = frontmatter['total_flour_weight']
        salt_percent = frontmatter['salt_percent']
        salt_weight = round(total_flour * salt_percent / 100, 1)

        # Build JSON structure
        formula = {
            'id': str(uuid.uuid4()).upper(),
            'name': frontmatter['title'],
            'type': CATEGORY_MAPPING[frontmatter['category']],
            'yeastType': YEAST_TYPE_DEFAULT,
            'totalFlourWeight': frontmatter['total_flour_weight'],
            'totalWaterWeight': frontmatter['total_water_weight'],
            'saltWeight': salt_weight,
            'servings': frontmatter['servings'],
            'inoculationPercent': frontmatter['inoculation_percent'],
            'flourMix': frontmatter.get('flour_mix', ''),
            'flours': [],
            'notes': '',
            'defaultSteps': steps
        }

        print(f"  ✓ Converted with {len(steps)} steps")
        return formula

    def format_all_formulas(self, content_dir: Path, output_file: Path):
        """Process all formula markdown files and generate JSON"""
        formulas_dir = content_dir / 'formulas'

        if not formulas_dir.exists():
            raise ValidationError(f"Formulas directory not found: {formulas_dir}")

        # Find all markdown files
        formula_files = list(formulas_dir.glob('*.md'))
        if not formula_files:
            raise ValidationError(f"No formula files found in {formulas_dir}")

        print(f"Found {len(formula_files)} formula files\n")

        # Load existing formulas
        existing_formulas = []
        if output_file.exists():
            with output_file.open('r', encoding='utf-8') as f:
                existing_formulas = json.load(f)
            print(f"Loaded {len(existing_formulas)} existing formulas\n")

        # Convert new formulas
        new_formulas = []
        for formula_file in sorted(formula_files):
            try:
                formula = self.convert_formula(formula_file)
                new_formulas.append(formula)
            except ValidationError as e:
                self.errors.append(str(e))
                print(f"  ✗ ERROR: {e}")
            except Exception as e:
                self.errors.append(f"{formula_file.name}: {e}")
                print(f"  ✗ EXCEPTION: {e}")

        # Combine with existing (existing first, then new)
        all_formulas = existing_formulas + new_formulas

        # Write output
        with output_file.open('w', encoding='utf-8') as f:
            json.dump(all_formulas, f, ensure_ascii=False, indent=2)

        # Print summary
        print(f"\n{'='*60}")
        print(f"Summary:")
        print(f"  Total formulas in output: {len(all_formulas)}")
        print(f"  Existing formulas kept: {len(existing_formulas)}")
        print(f"  New formulas added: {len(new_formulas)}")
        print(f"  Errors: {len(self.errors)}")
        print(f"  Warnings: {len(self.warnings)}")

        if self.warnings:
            print(f"\nWarnings:")
            for warning in self.warnings:
                print(f"  ⚠ {warning}")

        if self.errors:
            print(f"\nErrors:")
            for error in self.errors:
                print(f"  ✗ {error}")
            return False

        print(f"\n✓ Output written to: {output_file}")
        return True


def main():
    # Paths
    repo_root = Path(__file__).parent.parent
    content_dir = repo_root / 'docs' / 'content'
    output_file = repo_root / 'Levain' / 'Resources' / 'system_formulas.json'

    # Format
    formatter = ContentFormatter()
    success = formatter.format_all_formulas(content_dir, output_file)

    exit(0 if success else 1)


if __name__ == '__main__':
    main()
