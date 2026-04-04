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
    var yeastTypeRaw: String?
    var floursPayload: Data?
    var ingredients: String?
    var procedure: String?
    var bakingInstructions: String?
    private var defaultStepsPayload: Data
    var isSystemFormula: Bool = false
    var isModifiedFromDefault: Bool = false

    @Relationship(inverse: \Bake.formula)
    var bakes: [Bake]

    init(
        id: UUID = UUID(),
        name: String,
        type: RecipeCategory,
        totalFlourWeight: Double,
        totalWaterWeight: Double,
        saltWeight: Double,
        inoculationPercent: Double,
        servings: Int = 1,
        notes: String = "",
        flourMix: String = "",
        yeastType: YeastType = .sourdough,
        flours: [FlourSelection] = [],
        defaultSteps: [FormulaStepTemplate] = FormulaStepTemplate.defaultBreadSteps,
        ingredients: String = "",
        procedure: String = "",
        bakingInstructions: String = "",
        isSystemFormula: Bool = false,
        isModifiedFromDefault: Bool = false
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
        self.yeastTypeRaw = yeastType.rawValue
        self.floursPayload = RecipeFormula.encode(flours: flours)
        self.defaultStepsPayload = RecipeFormula.encode(defaultSteps: defaultSteps)
        self.ingredients = ingredients
        self.procedure = procedure
        self.bakingInstructions = bakingInstructions
        self.isSystemFormula = isSystemFormula
        self.isModifiedFromDefault = isModifiedFromDefault
        self.bakes = []
    }

    var type: RecipeCategory {
        get { RecipeCategory(rawValue: typeRaw) ?? .custom }
        set { typeRaw = newValue.rawValue }
    }

    var defaultSteps: [FormulaStepTemplate] {
        get { RecipeFormula.decode(defaultSteps: defaultStepsPayload) }
        set { defaultStepsPayload = RecipeFormula.encode(defaultSteps: newValue) }
    }

    var yeastType: YeastType {
        get { YeastType(rawValue: yeastTypeRaw ?? "") ?? .sourdough }
        set { yeastTypeRaw = newValue.rawValue }
    }

    var selectedFlours: [FlourSelection] {
        get { RecipeFormula.decode(flours: floursPayload) }
        set { floursPayload = RecipeFormula.encode(flours: newValue) }
    }

    var totalDoughWeight: Double {
        totalFlourWeight + totalWaterWeight + saltWeight + (totalFlourWeight * inoculationPercent / 100)
    }
    
    func duplicate(newName: String? = nil) -> RecipeFormula {
        RecipeFormula(
            name: newName ?? "\(name) (copia)",
            type: type,
            totalFlourWeight: totalFlourWeight,
            totalWaterWeight: totalWaterWeight,
            saltWeight: saltWeight,
            inoculationPercent: inoculationPercent,
            servings: servings,
            notes: notes,
            flourMix: flourMix,
            yeastType: yeastType,
            flours: selectedFlours,
            defaultSteps: defaultSteps.map { FormulaStepTemplate(id: UUID(), type: $0.type, name: $0.name, details: $0.details, durationMinutes: $0.durationMinutes, reminderOffsetMinutes: $0.reminderOffsetMinutes, temperatureRange: $0.temperatureRange, volumeTarget: $0.volumeTarget, notes: $0.notes, ingredients: $0.ingredients) },
            ingredients: ingredients ?? "",
            procedure: procedure ?? "",
            bakingInstructions: bakingInstructions ?? "",
            isSystemFormula: false,
            isModifiedFromDefault: false
        )
    }

    func recalculateDerivedValues() {
        hydrationPercent = RecipeFormula.computeRatio(part: totalWaterWeight, total: totalFlourWeight)
        saltPercent = RecipeFormula.computeRatio(part: saltWeight, total: totalFlourWeight)
    }

    private static func computeRatio(part: Double, total: Double) -> Double {
        guard total > 0 else { return 0 }
        return (part / total) * 100
    }

    private static func encode(defaultSteps: [FormulaStepTemplate]) -> Data {
        guard let data = try? JSONEncoder().encode(defaultSteps) else {
            return Data()
        }
        return data
    }

    private static func decode(defaultSteps payload: Data) -> [FormulaStepTemplate] {
        guard 
            payload.isEmpty == false,
            let steps = try? JSONDecoder().decode([FormulaStepTemplate].self, from: payload) 
        else {
            return FormulaStepTemplate.defaultBreadSteps
        }
        return steps
    }

    private static func encode(flours: [FlourSelection]) -> Data {
        guard let data = try? JSONEncoder().encode(flours) else { return Data() }
        return data
    }

    private static func decode(flours payload: Data?) -> [FlourSelection] {
        guard let payload = payload, !payload.isEmpty,
              let flours = try? JSONDecoder().decode([FlourSelection].self, from: payload) else {
            return []
        }
        return flours
    }
}

