import Foundation

struct SystemFormula: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var type: RecipeCategory
    var totalFlourWeight: Double
    var totalWaterWeight: Double
    var saltWeight: Double
    var inoculationPercent: Double
    var servings: Int
    var notes: String
    var flourMix: String
    var yeastType: YeastType
    var flours: [FlourSelection]
    var defaultSteps: [FormulaStepTemplate]

    var hydrationPercent: Double {
        guard totalFlourWeight > 0 else { return 0 }
        return (totalWaterWeight / totalFlourWeight) * 100
    }

    func makeTransientFormula() -> RecipeFormula {
        RecipeFormula(
            id: id,
            name: name,
            type: type,
            totalFlourWeight: totalFlourWeight,
            totalWaterWeight: totalWaterWeight,
            saltWeight: saltWeight,
            inoculationPercent: inoculationPercent,
            servings: servings,
            notes: notes,
            flourMix: flourMix,
            yeastType: yeastType,
            flours: flours,
            defaultSteps: defaultSteps
        )
    }
}
