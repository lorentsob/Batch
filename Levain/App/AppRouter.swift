import Foundation
import SwiftData

enum RootTab: String, Hashable {
    case today
    case bakes
    case starter
    case knowledge
}

enum BakesRoute: Hashable {
    case bake(UUID)
    case formula(UUID)
    case formulaList
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
    @Published var showingKnowledge: Bool = false
    var bannerPresenter: ((String, TimeInterval) -> Void)?

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

    func openKnowledge(_ id: String?) {
        showingKnowledge = true
        if let id = id {
            knowledgePath = [.article(id)]
        } else {
            knowledgePath = []
        }
    }

    func open(url: URL) {
        guard url.scheme == DeepLink.scheme else { return }
        let segments = url.pathComponents.filter { $0 != "/" }
        switch url.host {
        case "bake":
            if let value = segments.first, let id = UUID(uuidString: value) {
                openBake(id)
            }
        case "formula":
            if let value = segments.first, let id = UUID(uuidString: value) {
                openFormula(id)
            }
        case "starter":
            if let value = segments.first, let id = UUID(uuidString: value) {
                openStarter(id)
            }
        case "knowledge":
            if let value = segments.first {
                openKnowledge(value)
            } else {
                openKnowledge(nil)
            }
        default:
            break
        }
    }

    func open(url: URL, modelContext: ModelContext) {
        guard url.scheme == DeepLink.scheme else { return }
        let segments = url.pathComponents.filter { $0 != "/" }

        switch url.host {
        case "bake":
            guard let value = segments.first, let id = UUID(uuidString: value) else { return }
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let stepID = components?.queryItems?.first(where: { $0.name == "step" })?.value.flatMap(UUID.init)
            navigateFromNotificationPayload(bakeId: id, stepId: stepID, modelContext: modelContext)
        case "starter":
            guard let value = segments.first, let id = UUID(uuidString: value) else { return }
            navigateFromNotificationPayload(starterId: id, modelContext: modelContext)
        default:
            open(url: url)
        }
    }

    func navigateFromNotificationPayload(bakeId: UUID, stepId: UUID?, modelContext: ModelContext) {
        guard let bake = fetchBake(id: bakeId, modelContext: modelContext) else {
            selectedTab = .bakes
            bakesPath = []
            presentBanner("Questo bake non è più disponibile", duration: 8)
            return
        }

        if bake.derivedStatus == .cancelled {
            openBake(bake.id)
            presentBanner("Questo bake è stato annullato", duration: 5)
            return
        }

        if bake.derivedStatus == .completed {
            openBake(bake.id)
            presentBanner("Questo bake è già completato", duration: 5)
            return
        }

        if let stepId, bake.steps.contains(where: { $0.id == stepId }) == false {
            openBake(bake.id)
            presentBanner("Questa fase non è più disponibile", duration: 5)
            return
        }

        openBake(bake.id)
    }

    func navigateFromNotificationPayload(starterId: UUID, modelContext: ModelContext) {
        guard let starter = fetchStarter(id: starterId, modelContext: modelContext) else {
            selectedTab = .starter
            starterPath = []
            presentBanner("Starter non trovato", duration: 8)
            return
        }

        openStarter(starter.id)
    }

    func showNotificationsDisabledBanner() {
        selectedTab = .today
        presentBanner("Attiva le notifiche per ricevere i promemoria", duration: 8)
    }

    private func fetchBake(id: UUID, modelContext: ModelContext) -> Bake? {
        let descriptor = FetchDescriptor<Bake>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchStarter(id: UUID, modelContext: ModelContext) -> Starter? {
        let descriptor = FetchDescriptor<Starter>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    private func presentBanner(_ message: String, duration: TimeInterval = 3) {
        Task { @MainActor in
            bannerPresenter?(message, duration)
        }
    }
}

extension AppRouter {
    enum DeepLink {
        static let scheme = "levain"
        
        static func bake(id: UUID, stepID: UUID? = nil) -> String {
            guard let stepID else {
                return "\(scheme)://bake/\(id.uuidString)"
            }
            return "\(scheme)://bake/\(id.uuidString)?step=\(stepID.uuidString)"
        }
        
        static func formula(id: UUID) -> String {
            "\(scheme)://formula/\(id.uuidString)"
        }
        
        static func starter(id: UUID) -> String {
            "\(scheme)://starter/\(id.uuidString)"
        }
        
        static func knowledge(id: String) -> String {
            "\(scheme)://knowledge/\(id)"
        }
    }
}
