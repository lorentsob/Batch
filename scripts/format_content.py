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


# Knowledge category mapping
KNOWLEDGE_CATEGORY_MAPPING = {
    'starter': 'starter',
    'fermentation': 'fermentation',
    'bakerMath': 'bakerMath',
    'troubleshooting': 'troubleshooting'
}


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
        try:
            frontmatter = yaml.safe_load(frontmatter_str)
        except Exception as e:
            raise ValidationError(f"Invalid YAML in {file_path.name}: {e}")

        return frontmatter, body

    def extract_steps_section(self, body: str) -> Optional[str]:
        """Extract ## Steps section from markdown body"""
        steps_match = re.search(r'^## Steps\s*\n(.*?)(?=\n##|\Z)', body, re.MULTILINE | re.DOTALL)
        if steps_match:
            return steps_match.group(1).strip()
        return None

    def extract_ingredients_section(self, body: str) -> list:
        """Extract ## Ingredients section as structured list of {title, items} dicts.
        FIX: use `\n## ` (with space) so `###` sub-headers are NOT treated as section ends."""
        match = re.search(r'^## Ingredients\s*\n(.*?)(?=\n## |\Z)', body, re.MULTILINE | re.DOTALL)
        if not match:
            return []

        sections = []
        current_title = ''
        current_items = []

        for line in match.group(1).strip().splitlines():
            stripped = line.strip()
            if stripped.startswith('###'):
                # Save previous section
                if current_items:
                    sections.append({'title': current_title, 'items': current_items})
                current_title = stripped.lstrip('#').strip()
                current_items = []
            elif stripped.startswith('-'):
                current_items.append(stripped[1:].strip())
            elif stripped and not stripped.startswith('#'):
                # Plain text line (no bullet, no header) — append to current items
                current_items.append(stripped)

        # Don't forget last section
        if current_items:
            sections.append({'title': current_title, 'items': current_items})

        return sections

    def extract_procedure_sections(self, body: str) -> list:
        """Extract all ## and ### sections between Ingredients and Steps using a robust state-based approach."""
        sections = []
        
        # Split by any header at the start of a line
        parts = re.split(r'^(#+ .*)$', body, flags=re.MULTILINE)
        
        # parts will be [preamble, header1, content1, header2, content2, ...]
        skip_top_levels = ['Ingredients', 'Steps', 'Notes', 'Flour mix', 'Flour Mix']
        
        collecting = False
        
        # We start from the first header
        for i in range(1, len(parts), 2):
            header = parts[i].strip()
            content = parts[i+1].strip() if i+1 < len(parts) else ""
            
            # Extract header level and title
            header_match = re.match(r'(#+) (.*)', header)
            if not header_match:
                continue
                
            level = len(header_match.group(1))
            title = header_match.group(2).strip()
            
            # Switch collecting state based on top-level headers
            if level == 2:
                if title in skip_top_levels:
                    collecting = False
                else:
                    collecting = True
            
            # If we are in a procedural section, add it
            if collecting and level in [2, 3]:
                sections.append({
                    'title': title,
                    'level': level,
                    'content': content
                })
        
        return sections

    def extract_bake_section(self, body: str) -> list:
        """Extract ## Bake section as a list of instruction strings.
        FIX: use `\n## ` (with space) to avoid matching `###` sub-headers."""
        match = re.search(r'^## Bake\s*\n(.*?)(?=\n## |\Z)', body, re.MULTILINE | re.DOTALL)
        if not match:
            return []
        steps = []
        for line in match.group(1).strip().splitlines():
            stripped = line.strip()
            if stripped.startswith('-'):
                steps.append(stripped[1:].strip())
            elif stripped:
                steps.append(stripped)
        return steps

    def parse_steps(self, steps_text: str, parent_id: str) -> List[Dict[str, Any]]:
        """Parse steps from markdown format to JSON format"""
        if not steps_text:
            raise ValidationError("Empty steps section")

        steps = []
        # Use a deterministic namespace for steps
        step_namespace = uuid.UUID('57e90000-0000-0000-0000-000000000000')

        for i, line in enumerate(steps_text.split('\n')):
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

            # Generate stable step ID
            step_seed = f"{parent_id}-{step_type_raw}-{i}"
            step_uuid = str(uuid.uuid5(step_namespace, step_seed)).upper()

            step = {
                'id': step_uuid,
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

    def validate_formula_frontmatter(self, frontmatter: Dict[str, Any], file_name: str):
        """Validate required formula frontmatter fields"""
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

    def validate_knowledge_frontmatter(self, frontmatter: Dict[str, Any], file_name: str):
        """Validate required knowledge frontmatter fields"""
        required = ['id', 'type', 'title', 'category', 'summary', 'status']

        for field in required:
            if field not in frontmatter:
                raise ValidationError(f"{file_name}: Missing required field '{field}'")

        if frontmatter['type'] != 'knowledge':
            raise ValidationError(f"{file_name}: Type must be 'knowledge', got '{frontmatter['type']}'")

        # Validate category
        if frontmatter['category'] not in KNOWLEDGE_CATEGORY_MAPPING:
            raise ValidationError(f"{file_name}: Unknown category '{frontmatter['category']}'")

    def convert_formula(self, file_path: Path) -> Dict[str, Any]:
        """Convert a single formula markdown file to JSON format"""
        print(f"Processing formula {file_path.name}...")

        # Parse markdown
        frontmatter, body = self.parse_markdown(file_path)

        # Validate
        self.validate_formula_frontmatter(frontmatter, file_path.name)

        # Use a deterministic UUID based on the 'id' from frontmatter for stability
        # We use a namespace to ensure these UUIDs are unique to Levain formulas
        formula_namespace = uuid.UUID('f00d0000-0000-0000-0000-000000000000')
        formula_uuid = str(uuid.uuid5(formula_namespace, frontmatter['id'])).upper()

        # Extract and parse steps
        steps_text = self.extract_steps_section(body)
        if not steps_text:
            raise ValidationError(f"{file_path.name}: No ## Steps section found")

        steps = self.parse_steps(steps_text, formula_uuid)

        # Calculate salt weight
        total_flour = frontmatter['total_flour_weight']
        salt_percent = frontmatter['salt_percent']
        salt_weight = round(total_flour * salt_percent / 100, 1)

        # Extract ingredients and bake instructions
        ingredients_text = self.extract_ingredients_section(body)
        baking_text = self.extract_bake_section(body)
        procedure_sections = self.extract_procedure_sections(body)

        # Mapping logic: try to fill step details from procedure sections
        for step in steps:
            step_name = step['name'].lower()
            step_type = step['typeRaw'].lower()
            
            # Find matching section
            for section in procedure_sections:
                section_title = section['title'].lower()
                # Use sub-headers (###) as priority for mapping specific technical steps
                if section['level'] == 3:
                     if section_title == step_name or section_title == step_type or section_title in step_name or step_name in section_title:
                         step['details'] = section['content']
                         break
            
            # If no sub-header match, try top-level headers
            if not step['details']:
                for section in procedure_sections:
                    if section['level'] == 2:
                        section_title = section['title'].lower()
                        if section_title == step_name or section_title == step_type or section_title in step_name or step_name in section_title:
                            step['details'] = section['content']
                            break
            
            # Special case mapping for common terms
            if not step['details']:
                special_mapping = {
                    'autolysis': ['autolisi', 'autolyse', 'autolise'],
                    'mix': ['impasto', 'dough mix', 'incorporazione', 'mix'],
                    'bulk': ['lievitazione', 'first rise', 'primeiro crescimento', 'bulk', 'puntata'],
                    'coldretard': ['frigo', 'cold', 'maturazione', 'first rise', 'retard'],
                    'proof': ['appretto', 'second rise', 'formação', 'lievitazione', 'proof'],
                    'cool': ['cooling', 'raffreddamento', 'cool'],
                    'bake': ['cottura', 'bake']
                }
                # Fix step type to handle dash
                st_clean = step_type.replace('-', '')
                lookup_type = st_clean if st_clean in special_mapping else step_type
                
                if lookup_type in special_mapping:
                    for keyword in special_mapping[lookup_type]:
                        for section in procedure_sections:
                            if keyword in section['title'].lower():
                                step['details'] = section['content']
                                break
                        if step['details']: break

            # If still no details and it's a sub-step, maybe the parent section has it
            # E.g. 'Autolisi' might be inside 'Dough mix' text if not a header
            if not step['details']:
                 for section in procedure_sections:
                     if section['level'] == 2 and (step_name in section['content'].lower() or step_type in section['content'].lower()):
                         # Find the relevant paragraph in the content
                         paragraphs = section['content'].split('\n\n')
                         for p in paragraphs:
                             if step_name in p.lower() or step_type in p.lower():
                                 step['details'] = p.strip()
                                 break
                         if step['details']: break

        # Build JSON structure
        formula = {
            'id': formula_uuid,
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
            'ingredients': json.dumps(ingredients_text, ensure_ascii=False) if ingredients_text else '',
            'procedure': json.dumps(procedure_sections, ensure_ascii=False),
            'bakingInstructions': json.dumps(baking_text, ensure_ascii=False) if baking_text else '',
            'defaultSteps': steps
        }

        print(f"  ✓ Converted (ID: {formula_uuid[:8]}...)")
        return formula

    def convert_knowledge(self, file_path: Path) -> Dict[str, Any]:
        """Convert a single knowledge markdown file to JSON format"""
        print(f"Processing knowledge {file_path.name}...")

        # Parse markdown
        frontmatter, body = self.parse_markdown(file_path)

        # Validate
        self.validate_knowledge_frontmatter(frontmatter, file_path.name)

        # Use the id directly as the unique identifier for knowledge items
        # in the app bundle
        item_id = frontmatter['id']

        # Build JSON structure
        knowledge_item = {
            'id': item_id,
            'title': frontmatter['title'],
            'category': KNOWLEDGE_CATEGORY_MAPPING[frontmatter['category']],
            'tags': frontmatter.get('tags', []),
            'summary': frontmatter['summary'],
            'content': body.strip(),
            'relatedStepTypes': frontmatter.get('related_steps', []),
            'relatedStarterStates': frontmatter.get('related_states', [])
        }

        print(f"  ✓ Converted (ID: {item_id})")
        return knowledge_item

    def format_all_formulas(self, content_dir: Path, output_file: Path):
        """Process all formula markdown files and generate JSON"""
        formulas_dir = content_dir / 'formulas'

        if not formulas_dir.exists():
            print(f"Skipping formulas: directory not found: {formulas_dir}")
            return True

        # Find all markdown files
        formula_files = list(formulas_dir.glob('*.md'))
        if not formula_files:
            print(f"No formula files found in {formulas_dir}")
            return True

        print(f"Found {len(formula_files)} formula files\n")

        # Convert
        all_formulas = []
        for formula_file in sorted(formula_files):
            try:
                formula = self.convert_formula(formula_file)
                all_formulas.append(formula)
            except ValidationError as e:
                self.errors.append(str(e))
                print(f"  ✗ ERROR: {e}")
            except Exception as e:
                self.errors.append(f"{formula_file.name}: {e}")
                print(f"  ✗ EXCEPTION: {e}")

        # Write output (Always overwrite since .md is the source of truth)
        with output_file.open('w', encoding='utf-8') as f:
            json.dump(all_formulas, f, ensure_ascii=False, indent=2)

        return len(self.errors) == 0

    def format_all_knowledge(self, content_dir: Path, output_file: Path):
        """Process all knowledge markdown files and generate JSON"""
        knowledge_dir = content_dir / 'knowledge'

        if not knowledge_dir.exists():
            print(f"Skipping knowledge: directory not found: {knowledge_dir}")
            return True

        # Find all markdown files
        knowledge_files = list(knowledge_dir.glob('*.md'))
        if not knowledge_files:
            print(f"No knowledge files found in {knowledge_dir}")
            # Still overwrite/create output so it's fresh
            with output_file.open('w', encoding='utf-8') as f:
                json.dump([], f, ensure_ascii=False, indent=2)
            return True

        print(f"Found {len(knowledge_files)} knowledge files\n")

        # Convert
        all_items = []
        for knowledge_file in sorted(knowledge_files):
            try:
                item = self.convert_knowledge(knowledge_file)
                all_items.append(item)
            except ValidationError as e:
                self.errors.append(str(e))
                print(f"  ✗ ERROR: {e}")
            except Exception as e:
                self.errors.append(f"{knowledge_file.name}: {e}")
                print(f"  ✗ EXCEPTION: {e}")

        # Write output (Always overwrite since .md is the source of truth)
        with output_file.open('w', encoding='utf-8') as f:
            json.dump(all_items, f, ensure_ascii=False, indent=2)

        return len(self.errors) == 0


def main():
    # Paths
    repo_root = Path(__file__).parent.parent
    content_dir = repo_root / 'docs' / 'content'
    formulas_output = repo_root / 'Levain' / 'Resources' / 'system_formulas.json'
    knowledge_output = repo_root / 'Levain' / 'Resources' / 'knowledge.json'

    # Format
    formatter = ContentFormatter()
    
    print("\n--- Processing Formulas ---")
    f_success = formatter.format_all_formulas(content_dir, formulas_output)
    
    print("\n--- Processing Knowledge ---")
    k_success = formatter.format_all_knowledge(content_dir, knowledge_output)

    # Print summary
    print(f"\n{'='*60}")
    print(f"Summary:")
    print(f"  Errors: {len(formatter.errors)}")
    print(f"  Warnings: {len(formatter.warnings)}")

    if formatter.errors:
        print(f"\nErrors:")
        for error in formatter.errors:
            print(f"  ✗ {error}")

    if formatter.warnings:
        print(f"\nWarnings:")
        for warning in formatter.warnings:
            print(f"  ⚠ {warning}")

    exit(0 if (f_success and k_success) else 1)


if __name__ == '__main__':
    main()
