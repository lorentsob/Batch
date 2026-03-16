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
    var ingredients: String
    var procedure: String
    var bakingInstructions: String

    var hydrationPercent: Double {
        guard totalFlourWeight > 0 else { return 0 }
        return (totalWaterWeight / totalFlourWeight) * 100
    }

    // MARK: - Decodable with default fallback
    private enum CodingKeys: String, CodingKey {
        case id, name, type, totalFlourWeight, totalWaterWeight, saltWeight
        case inoculationPercent, servings, notes, flourMix, yeastType, flours
        case defaultSteps, ingredients, procedure, bakingInstructions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                   = try c.decode(UUID.self,                    forKey: .id)
        name                 = try c.decode(String.self,                  forKey: .name)
        type                 = try c.decode(RecipeCategory.self,          forKey: .type)
        totalFlourWeight     = try c.decode(Double.self,                  forKey: .totalFlourWeight)
        totalWaterWeight     = try c.decode(Double.self,                  forKey: .totalWaterWeight)
        saltWeight           = try c.decode(Double.self,                  forKey: .saltWeight)
        inoculationPercent   = try c.decode(Double.self,                  forKey: .inoculationPercent)
        servings             = try c.decode(Int.self,                     forKey: .servings)
        notes                = try c.decodeIfPresent(String.self,         forKey: .notes) ?? ""
        flourMix             = try c.decodeIfPresent(String.self,         forKey: .flourMix) ?? ""
        yeastType            = try c.decodeIfPresent(YeastType.self,      forKey: .yeastType) ?? .sourdough
        flours               = try c.decodeIfPresent([FlourSelection].self, forKey: .flours) ?? []
        defaultSteps         = try c.decodeIfPresent([FormulaStepTemplate].self, forKey: .defaultSteps) ?? []
        ingredients          = try c.decodeIfPresent(String.self,         forKey: .ingredients) ?? ""
        procedure            = try c.decodeIfPresent(String.self,         forKey: .procedure) ?? ""
        bakingInstructions   = try c.decodeIfPresent(String.self,         forKey: .bakingInstructions) ?? ""
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
            defaultSteps: defaultSteps,
            ingredients: ingredients,
            procedure: procedure,
            bakingInstructions: bakingInstructions
        )
    }
}
