import Testing
@testable import Levain

@Suite("SystemFormulaLoader Tests")
struct SystemFormulaLoaderTests {
    @Test("Bundled system formulas decode and keep the expected defaults")
    func testBundledSystemFormulasLoad() {
        let formulas = SystemFormulaLoader.loadSystemFormulas()

        #expect(formulas.count == 5)
        #expect(formulas.contains(where: { $0.name == "Bagel" }))
        #expect(formulas.contains(where: { $0.name == "Focaccia Tiktok" }))
        #expect(formulas.contains(where: { $0.name == "Pan Brioche" }))
        #expect(formulas.contains(where: { $0.name == "Pizza in giornata" }))
        #expect(formulas.contains(where: { $0.name == "Potato Buns" }))
        #expect(formulas.allSatisfy { $0.defaultSteps.isEmpty == false })
    }

    @Test("Transient formula conversion keeps bundled templates read-only")
    func testSystemFormulaCreatesTransientRecipeFormula() throws {
        let formula = try #require(SystemFormulaLoader.loadSystemFormulas().first)
        let transient = formula.makeTransientFormula()

        #expect(transient.id == formula.id)
        #expect(transient.name == formula.name)
        #expect(transient.defaultSteps == formula.defaultSteps)
    }
}
