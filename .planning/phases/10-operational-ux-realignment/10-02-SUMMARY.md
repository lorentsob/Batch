# 10-02 Summary: Recipe and starter authoring realignment

## Overview
This phase successfully evolved the generic "formula" authoring model into a more robust, categorized "recipe" system, and established a consistent ingredient and yeast configuration logic between recipes and starters. These changes ensure the app's foundational objects are ready for real-world bread-making operations.

## Key Changes
1. **Promoted Formulas to Recipes**
   - Transformed the `BakeType` model into `RecipeCategory` (Pane, Pizza, Focaccia, Grandi lievitati, Dolci, Altro).
   - Ensured direct usability by decoupling presets from a mandatory copying flow.
   - Refactored language throughout the app from "formula" and "dough type" to "ricetta" and specific categories.

2. **Replaced Free-text Ingredients with Structured Forms**
   - Introduced `FlourCategory` and `FlourSelection` to rigorously model the exact mix of flours per recipe and starter.
   - Built a dedicated `FlourSelectionEditorView`, replacing `flourMix: String` fields in `FormulaEditorView` and `StarterEditorView` with robust multi-select lists tracking precise percentages.
   - Swapped placeholders for permanent labels and clearer descriptions (e.g. changing "Pezzi" to "Porzioni" for clarity).

3. **Explicit Yeast Configuration in Bake Creation**
   - Added `YeastType` to `RecipeFormula` (Sourdough, Dry, Fresh, None).
   - Updated `BakeCreationView` to make the recipe’s yeast expectations visually explicit.
   - Conditionally surfaced the Sourdough Starter selection in `BakeCreationView` only when the selected recipe explicitly dictates `YeastType.sourdough`.

## Files Modified
*   **Models**: `DomainEnums.swift`, `RecipeFormula.swift`, `Starter.swift`
*   **Features/Shared**: `FlourSelectionEditorView.swift` (New)
*   **Features/Bakes**: `FormulaEditorView.swift`, `BakeCreationView.swift`, `FormulaDetailView.swift`
*   **Features/Starter**: `StarterEditorView.swift`, `StarterDetailHeaderView.swift`
*   **Persistence**: `SeedDataLoader.swift`
*   **Tests**: `RecipeFormulaTests.swift`, `StarterTests.swift`

## Verification
- ✅ `xcodebuild -project Levain.xcodeproj -scheme Levain -derivedDataPath /tmp/LevainDerived CODE_SIGNING_ALLOWED=NO build` executed successfully.
- ✅ Unit tests `LevainTests/RecipeFormulaTests` and `LevainTests/StarterTests` ran and passed in the platform simulator.
- ✅ Xcode project successfully generated and resynced using `xcodegen`.

## Next Steps
The app shell and foundational data models have now been realigned for an operational planner. Subsequent phases should finalize the active-bake progression and real-time execution UI.
