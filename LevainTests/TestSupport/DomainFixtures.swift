import Foundation
@testable import Levain

enum DomainFixtures {
    static func makeFormula(
        name: String = "Test Formula",
        steps: [FormulaStepTemplate] = FormulaStepTemplate.defaultBreadSteps
    ) -> RecipeFormula {
        RecipeFormula(
            name: name,
            type: .countryLoaf,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20,
            defaultSteps: steps
        )
    }

    static func makeStarter(
        name: String = "Test Starter",
        refreshIntervalDays: Int = 7,
        lastRefresh: Date = .now
    ) -> Starter {
        Starter(
            name: name,
            type: .wheat,
            refreshIntervalDays: refreshIntervalDays,
            lastRefresh: lastRefresh
        )
    }

    static func makeBake(
        name: String = "Test Bake",
        target: Date = Date(timeIntervalSince1970: 100_000),
        formula: RecipeFormula? = nil
    ) -> Bake {
        let actualFormula = formula ?? makeFormula()
        return BakeScheduler.generateBake(
            name: name,
            targetBakeDateTime: target,
            formula: actualFormula
        )
    }
}

extension Date {
    static var fixedNow: Date {
        Date(timeIntervalSince1970: 1_000_000)
    }
}
