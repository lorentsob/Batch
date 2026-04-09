import Foundation

enum SystemFormulaLoader {
    static func loadSystemFormulas(bundle: Bundle = Bundle(for: Anchor.self)) -> [SystemFormula] {
        guard
            let url = bundle.url(forResource: "system_formulas", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let formulas = try? JSONDecoder().decode([SystemFormula].self, from: data)
        else {
            return []
        }
        return formulas
    }

    static func formula(id: UUID, bundle: Bundle = Bundle(for: Anchor.self)) -> SystemFormula? {
        loadSystemFormulas(bundle: bundle).first(where: { $0.id == id })
    }
}

private final class Anchor {}
