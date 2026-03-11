import Foundation

@MainActor
enum RecipeTemplates {
    static let all: [RecipeFormula] = [
        RecipeFormula(
            id: UUID(uuidString: "8C2A0C02-2C34-4D31-93A3-4B7C75D6502A")!,
            name: "Pane di campagna",
            type: .pane,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20,
            servings: 2,
            notes: "",
            flourMix: "",
            yeastType: .sourdough,
            flours: [],
            defaultSteps: FormulaStepTemplate.defaultBreadSteps
        ),
        RecipeFormula(
            id: UUID(uuidString: "D7B7E2FE-0F5A-4CB2-B5F2-8B2A39456E1C")!,
            name: "Pizza napoletana",
            type: .pizza,
            totalFlourWeight: 1000,
            totalWaterWeight: 650,
            saltWeight: 25,
            inoculationPercent: 0.2,
            servings: 6,
            notes: "",
            flourMix: "",
            yeastType: .dryYeast,
            flours: [],
            defaultSteps: FormulaStepTemplate.defaultPizzaSteps
        ),
        RecipeFormula(
            id: UUID(uuidString: "B29B4B6A-6C7A-4D2B-9B6A-0A2A0A9F2A58")!,
            name: "Focaccia classica",
            type: .focaccia,
            totalFlourWeight: 1000,
            totalWaterWeight: 800,
            saltWeight: 22,
            inoculationPercent: 0.4,
            servings: 1,
            notes: "",
            flourMix: "",
            yeastType: .dryYeast,
            flours: [],
            defaultSteps: FormulaStepTemplate.defaultBreadSteps
        )
    ]
}
