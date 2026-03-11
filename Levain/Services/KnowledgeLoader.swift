import Foundation

enum KnowledgeLoader {
    static func loadKnowledgeItems(bundle: Bundle = Bundle(for: KnowledgeLoaderClass.self)) -> [KnowledgeItem] {
        guard
            let url = bundle.url(forResource: "knowledge", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let items = try? JSONDecoder().decode([KnowledgeItem].self, from: data)
        else {
            return []
        }
        return items
    }
}

/// Anchor class used by KnowledgeLoader to locate the correct bundle at runtime.
/// This resolves the bundle whether called from the main app or from a test host that
/// links against the Levain target (where Bundle.main would be the XCTest runner bundle).
private final class KnowledgeLoaderClass {}



@MainActor
final class KnowledgeLibrary: ObservableObject {
    @Published private(set) var items: [KnowledgeItem] = []
    private var preloadTask: Task<Void, Never>?

    func loadIfNeeded() {
        guard items.isEmpty, preloadTask == nil else { return }
        items = KnowledgeLoader.loadKnowledgeItems()
    }

    func preloadIfNeeded() {
        guard items.isEmpty, preloadTask == nil else { return }

        preloadTask = Task {
            let loadedItems = await Task.detached(priority: .utility) {
                KnowledgeLoader.loadKnowledgeItems()
            }.value

            items = loadedItems
            preloadTask = nil
        }
    }

    func item(id: String) -> KnowledgeItem? {
        items.first(where: { $0.id == id })
    }

    func tips(for stepType: BakeStepType) -> [KnowledgeItem] {
        items.filter { $0.relatedStepTypes.contains(stepType.rawValue) }
    }

    func tips(for starterState: StarterDueState) -> [KnowledgeItem] {
        items.filter { $0.relatedStarterStates.contains(starterState.rawValue) }
    }
}
