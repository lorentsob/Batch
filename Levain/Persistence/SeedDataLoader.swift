import Foundation
import SwiftData

enum SeedDataLoader {
    static func ensureSeedData(in context: ModelContext) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        guard settings.didSeedSampleData == false else { return }

        let starter = Starter(
            name: "Starter grano duro",
            type: .semolina,
            hydration: 100,
            flourMix: "100% semola rimacinata",
            containerWeight: 280,
            storageMode: .fridge,
            refreshIntervalDays: 5,
            lastRefresh: .now.adding(minutes: -4 * 24 * 60),
            notes: "Uso principale per pagnotte e focacce."
        )

        let formula = RecipeFormula(
            name: "Pane base",
            type: .countryLoaf,
            totalFlourWeight: 1000,
            totalWaterWeight: 720,
            saltWeight: 22,
            inoculationPercent: 18,
            servings: 2,
            notes: "Formula di riferimento per i test interni.",
            flourMix: "80% tipo 1, 20% semola"
        )
        let bake = BakeScheduler.generateBake(
            name: "Pane base di domani",
            targetBakeDateTime: .now.adding(minutes: 18 * 60),
            formula: formula,
            starter: starter,
            notes: "Controllare temperatura impasto."
        )

        context.insert(starter)
        context.insert(formula)
        context.insert(bake)
        bake.steps.forEach { context.insert($0) }

        let refresh = StarterRefresh(
            flourWeight: 80,
            waterWeight: 80,
            starterWeightUsed: 20,
            ratioText: "1:4:4",
            notes: "Rinfresco standard prima del frigo.",
            starter: starter
        )
        starter.refreshes.append(refresh)
        context.insert(refresh)

        settings.didSeedSampleData = true
        try context.save()
    }
}

