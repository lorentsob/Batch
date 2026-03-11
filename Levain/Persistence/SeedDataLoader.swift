import Foundation
import SwiftData

/// Manages the insertion of representative sample content used for internal
/// testing and demos.
///
/// **Contract:**
/// - `ensureSeedData(in:)` is idempotent: calling it multiple times on the
///   same persistent store inserts content only once (guarded by `didSeedSampleData`).
/// - Normal first launch must NOT call this function unconditionally. Seeding
///   is an explicit, deliberate action restricted to internal-testing paths.
/// - `resetAndSeed(in:)` is available for in-memory test contexts where the
///   idempotency flag needs to be bypassed (the store is ephemeral anyway).
enum SeedDataLoader {

    /// Inserts sample data if it has not been inserted into this store before.
    /// Safe to call multiple times; subsequent calls are no-ops.
    static func ensureSeedData(in context: ModelContext) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        guard settings.didSeedSampleData == false else { return }

        try insertSampleContent(in: context, settings: settings)
    }

    /// Unconditionally inserts sample data, bypassing the idempotency guard.
    /// Intended exclusively for in-memory test contexts where the store
    /// is discarded after the test run.
    static func resetAndSeed(in context: ModelContext) throws {
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settings = try context.fetch(settingsDescriptor).first ?? {
            let value = AppSettings()
            context.insert(value)
            return value
        }()

        // Reset idempotency flag so re-seeding is allowed.
        settings.didSeedSampleData = false
        try insertSampleContent(in: context, settings: settings)
    }

    // MARK: - Private

    private static func insertSampleContent(in context: ModelContext, settings: AppSettings) throws {
        // 1. Starter & Refreshes
        let starter = Starter(
            name: "Lievito Madre (Semola)",
            type: .semolina,
            hydration: 100,
            flourMix: "100% semola rimacinata",
            containerWeight: 280,
            storageMode: .fridge,
            refreshIntervalDays: 5,
            lastRefresh: .now.adding(minutes: -2 * 24 * 60),
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
            dateTime: .now.adding(minutes: -2 * 24 * 60),
            flourWeight: 80,
            waterWeight: 80,
            starterWeightUsed: 20,
            ratioText: "1:4:4",
            notes: "Rinfresco pre-bake.",
            starter: starter
        )
        context.insert(refresh1)
        context.insert(refresh2)

        // 2. Formulas
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

        // 3. Active Bake
        let bake = BakeScheduler.generateBake(
            name: "Infornata del weekend",
            targetBakeDateTime: .now.adding(minutes: 120), // Due soon
            formula: formulaPane,
            starter: starter,
            notes: "Provare pieghe più delicate."
        )
        context.insert(bake)

        // Simulate progress: first two steps completed
        if let first = bake.sortedSteps.first {
            first.complete(at: .now.adding(minutes: -360))
        }
        if bake.sortedSteps.count > 1 {
            bake.sortedSteps[1].complete(at: .now.adding(minutes: -300))
        }

        bake.steps.forEach { context.insert($0) }

        settings.didSeedSampleData = true
        try context.save()
    }
}
