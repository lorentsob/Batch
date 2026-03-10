import Foundation

enum RootTab: String, Hashable {
    case today
    case bakes
    case starter
    case knowledge
}

enum BakesRoute: Hashable {
    case bake(UUID)
    case formula(UUID)
}

enum StarterRoute: Hashable {
    case detail(UUID)
}

enum KnowledgeRoute: Hashable {
    case article(String)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: RootTab = .today
    @Published var bakesPath: [BakesRoute] = []
    @Published var starterPath: [StarterRoute] = []
    @Published var knowledgePath: [KnowledgeRoute] = []

    func openBake(_ id: UUID) {
        selectedTab = .bakes
        bakesPath = [.bake(id)]
    }

    func openFormula(_ id: UUID) {
        selectedTab = .bakes
        bakesPath = [.formula(id)]
    }

    func openStarter(_ id: UUID) {
        selectedTab = .starter
        starterPath = [.detail(id)]
    }

    func openKnowledge(_ id: String) {
        selectedTab = .knowledge
        knowledgePath = [.article(id)]
    }

    func open(url: URL) {
        guard url.scheme == "levain" else { return }
        let segments = url.pathComponents.filter { $0 != "/" }
        switch url.host {
        case "bake":
            if let value = segments.first, let id = UUID(uuidString: value) {
                openBake(id)
            }
        case "starter":
            if let value = segments.first, let id = UUID(uuidString: value) {
                openStarter(id)
            }
        case "knowledge":
            if let value = segments.first {
                openKnowledge(value)
            }
        default:
            break
        }
    }
}

