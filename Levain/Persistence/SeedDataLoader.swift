import Foundation
import SwiftData

/// Manages the insertion of representative sample content used for internal
/// testing and demos.
enum SeedDataLoader {
    enum Scenario: String {
        case operational
        case futureOnly
        case allClear

        static func current() -> Scenario {
            Scenario(rawValue: AppLaunchOptions.seedScenario) ?? .operational
        }
    }

    static func ensureSeedData(in context: ModelContext, scenario: Scenario = .operational) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        guard settings.didSeedSampleData == false else { return }
        try insertSampleContent(in: context, settings: settings, scenario: scenario)
    }

    static func resetAndSeed(in context: ModelContext, scenario: Scenario = .operational) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        settings.didSeedSampleData = false
        try insertSampleContent(in: context, settings: settings, scenario: scenario)
    }

    private static func insertSampleContent(in context: ModelContext, settings: AppSettings, scenario: Scenario) throws {
        switch scenario {
        case .operational:
            try insertOperationalScenario(in: context)
        case .futureOnly:
            try insertFutureOnlyScenario(in: context)
        case .allClear:
            try insertAllClearScenario(in: context)
        }

        settings.didSeedSampleData = true
        try context.save()
    }

    private static func insertOperationalScenario(in context: ModelContext) throws {
        let starter = Starter(
            name: "Lievito Madre (Semola)",
            type: .semolina,
            hydration: 100,
            flourMix: "100% semola rimacinata",
            containerWeight: 280,
            storageMode: .fridge,
            refreshIntervalDays: 5,
            lastRefresh: .now.adding(minutes: -5 * 24 * 60),
            notes: "Vigoroso, ottimo per pane e focacce."
        )
        context.insert(starter)

        let refresh1 = StarterRefresh(
            dateTime: .now.adding(minutes: -7 * 24 * 60),
            flourWeight: 100,
            waterWeight: 100,
            starterWeightUsed: 50,
            ratioText: "1:2:2",
            notes: "Rinfresco di mantenimento.",
            starter: starter
        )
        let refresh2 = StarterRefresh(
            dateTime: .now.adding(minutes: -5 * 24 * 60),
            flourWeight: 80,
            waterWeight: 80,
            starterWeightUsed: 20,
            ratioText: "1:4:4",
            notes: "Rinfresco pre-bake.",
            starter: starter
        )
        context.insert(refresh1)
        context.insert(refresh2)

        let formulaPane = RecipeFormula(
            name: "Pane di Campagna",
            type: .pane,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20,
            servings: 2,
            notes: "La formula classica per ogni giorno.",
            flourMix: "70% Tipo 1, 30% Integrale"
        )

        let formulaFocaccia = RecipeFormula(
            name: "Focaccia Idratata",
            type: .focaccia,
            totalFlourWeight: 500,
            totalWaterWeight: 400,
            saltWeight: 12,
            inoculationPercent: 15,
            servings: 1,
            notes: "Molto soffice, richiede teglia ben oliata.",
            flourMix: "100% Farina 0"
        )
        context.insert(formulaPane)
        context.insert(formulaFocaccia)

        let bake = BakeScheduler.generateBake(
            name: "Infornata del weekend",
            targetBakeDateTime: .now.adding(minutes: 120),
            formula: formulaPane,
            starter: starter,
            notes: "Provare pieghe più delicate."
        )
        context.insert(bake)

        if let first = bake.sortedSteps.first {
            first.complete(at: .now.adding(minutes: -360))
        }
        if bake.sortedSteps.count > 1 {
            bake.sortedSteps[1].complete(at: .now.adding(minutes: -300))
        }

        bake.steps.forEach { context.insert($0) }
    }

    private static func insertFutureOnlyScenario(in context: ModelContext) throws {
        let starter = Starter(
            name: "Starter programma weekend",
            type: .wheat,
            hydration: 100,
            refreshIntervalDays: 7,
            lastRefresh: .now,
            notes: "Da rinfrescare più avanti."
        )
        let formula = RecipeFormula(
            name: "Pane weekend",
            type: .pane,
            totalFlourWeight: 900,
            totalWaterWeight: 680,
            saltWeight: 18,
            inoculationPercent: 18,
            servings: 2
        )
        context.insert(starter)
        context.insert(formula)
    }

    private static func insertAllClearScenario(in context: ModelContext) throws {
        let formula = RecipeFormula(
            name: "Base neutra",
            type: .pane,
            totalFlourWeight: 1000,
            totalWaterWeight: 720,
            saltWeight: 20,
            inoculationPercent: 20,
            servings: 2,
            notes: "Solo ricetta salvata, nessun lavoro in agenda."
        )
        context.insert(formula)
    }
}
