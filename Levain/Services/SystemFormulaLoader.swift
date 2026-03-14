import Foundation

enum SystemFormulaLoader {
    static func loadSystemFormulas(bundle: Bundle = Bundle(for: SystemFormulaLoaderClass.self)) -> [SystemFormula] {
        guard
            let url = bundle.url(forResource: "system_formulas", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode([SystemFormula].self, from: data)
        else {
            assertionFailure("Unable to load bundled system formulas")
            return []
        }

        return items
    }
}

private final class SystemFormulaLoaderClass {}
