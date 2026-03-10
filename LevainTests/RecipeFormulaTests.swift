import XCTest
@testable import Levain

final class RecipeFormulaTests: XCTestCase {
    
    func testDerivedValuesCalculation() {
        let formula = RecipeFormula(
            name: "Test",
            type: .countryLoaf,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20
        )
        
        XCTAssertEqual(formula.hydrationPercent, 75.0, accuracy: 0.1)
        XCTAssertEqual(formula.saltPercent, 2.0, accuracy: 0.1)
        XCTAssertEqual(formula.totalDoughWeight, 1000 + 750 + 20 + 200)
    }
    
    func testRecalculateDerivedValues() {
        let formula = RecipeFormula(
            name: "Test",
            type: .countryLoaf,
            totalFlourWeight: 1000,
            totalWaterWeight: 750,
            saltWeight: 20,
            inoculationPercent: 20
        )
        
        formula.totalFlourWeight = 500
        formula.totalWaterWeight = 400
        formula.saltWeight = 10
        formula.recalculateDerivedValues()
        
        XCTAssertEqual(formula.hydrationPercent, 80.0, accuracy: 0.1)
        XCTAssertEqual(formula.saltPercent, 2.0, accuracy: 0.1)
        XCTAssertEqual(formula.totalDoughWeight, 500 + 400 + 10 + 100)
    }
    
    func testDuplication() {
        let formula = RecipeFormula(
            name: "Country Loaf",
            type: .countryLoaf,
            totalFlourWeight: 1000,
            totalWaterWeight: 800,
            saltWeight: 22,
            inoculationPercent: 18,
            defaultSteps: [
                FormulaStepTemplate(type: .autolysis, name: "Autolisi", durationMinutes: 60)
            ]
        )
        
        let duplicate = formula.duplicate()
        
        XCTAssertEqual(duplicate.name, "Country Loaf (copia)")
        XCTAssertEqual(duplicate.totalWaterWeight, 800)
        XCTAssertEqual(duplicate.defaultSteps.count, 1)
        
        // Assert deep copy of steps (different IDs)
        XCTAssertNotEqual(duplicate.defaultSteps.first?.id, formula.defaultSteps.first?.id)
    }
}
