import Foundation
import SwiftData

@Model
final class RecipeFormula {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    var totalFlourWeight: Double
    var totalWaterWeight: Double
    var hydrationPercent: Double
    var saltWeight: Double
    var saltPercent: Double
    var inoculationPercent: Double
    var servings: Int
    var notes: String
    var flourMix: String
    private var defaultStepsPayload: String

    @Relationship(inverse: \Bake.formula)
    var bakes: [Bake]

    init(
        id: UUID = UUID(),
        name: String,
        type: BakeType,
        totalFlourWeight: Double,
        totalWaterWeight: Double,
        saltWeight: Double,
        inoculationPercent: Double,
        servings: Int = 1,
        notes: String = "",
        flourMix: String = "",
        defaultSteps: [FormulaStepTemplate] = FormulaStepTemplate.defaultBreadSteps
    ) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.totalFlourWeight = totalFlourWeight
        self.totalWaterWeight = totalWaterWeight
        self.hydrationPercent = RecipeFormula.computeRatio(part: totalWaterWeight, total: totalFlourWeight)
        self.saltWeight = saltWeight
        self.saltPercent = RecipeFormula.computeRatio(part: saltWeight, total: totalFlourWeight)
        self.inoculationPercent = inoculationPercent
        self.servings = servings
        self.notes = notes
        self.flourMix = flourMix
        self.defaultStepsPayload = RecipeFormula.encode(defaultSteps: defaultSteps)
        self.bakes = []
    }

    var type: BakeType {
        get { BakeType(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var defaultSteps: [FormulaStepTemplate] {
        get { RecipeFormula.decode(defaultSteps: defaultStepsPayload) }
        set { defaultStepsPayload = RecipeFormula.encode(defaultSteps: newValue) }
    }

    var totalDoughWeight: Double {
        totalFlourWeight + totalWaterWeight + saltWeight + (totalFlourWeight * inoculationPercent / 100)
    }

    func recalculateDerivedValues() {
        hydrationPercent = RecipeFormula.computeRatio(part: totalWaterWeight, total: totalFlourWeight)
        saltPercent = RecipeFormula.computeRatio(part: saltWeight, total: totalFlourWeight)
    }

    private static func computeRatio(part: Double, total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (part / total) * 100
    }

    private static func encode(defaultSteps: [FormulaStepTemplate]) -> String {
        guard
            let data = try? JSONEncoder().encode(defaultSteps),
            let string = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return string
    }

    private static func decode(defaultSteps payload: String) -> [FormulaStepTemplate] {
        guard
            let data = payload.data(using: .utf8),
            let steps = try? JSONDecoder().decode([FormulaStepTemplate].self, from: data)
        else {
            return FormulaStepTemplate.defaultBreadSteps
        }
        return steps
    }
}

