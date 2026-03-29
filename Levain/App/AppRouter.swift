import Foundation
import SwiftData

enum RootTab: String, Hashable {
    case oggi
    case preparazioni
    case knowledge
}

enum PreparationsRoute: Hashable {
    case breadHub
    case kefirHub
    case bakesList
    case formulaList
    case starterList
    case bake(UUID)
    case formula(UUID)
    case starter(UUID)
    case kefirBatch(UUID)  // Phase 19 — wired to real batch detail when kefir models land
}

enum KnowledgeRoute: Hashable {
    case article(String)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: RootTab = .oggi
    @Published var preparationsPath: [PreparationsRoute] = []
    @Published var knowledgePath: [KnowledgeRoute] = []
    var bannerPresenter: ((String, TimeInterval) -> Void)?

    // MARK: - Navigation helpers (direct-object routing rule)
    // Operational taps and deep links navigate directly to the object
    // without forcing Preparazioni → hub traversal.

    func openBake(_ id: UUID) {
        selectedTab = .preparazioni
        preparationsPath = [.bake(id)]
    }

    func openFormula(_ id: UUID) {
        selectedTab = .preparazioni
        preparationsPath = [.formula(id)]
    }

    func openStarter(_ id: UUID) {
        selectedTab = .preparazioni
        preparationsPath = [.starter(id)]
    }

    // Phase 19 hook — kefir batch detail route. Wires into KefirHubView when batch CRUD lands.
    func openKefirBatch(_ id: UUID) {
        selectedTab = .preparazioni
        preparationsPath = [.kefirBatch(id)]
    }

    func openKnowledge(_ id: String?) {
        selectedTab = .knowledge
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
        case "kefir":
            // Phase 19 — kefir batch deep link; no-ops safely until batch detail view exists
            if let value = segments.first, let id = UUID(uuidString: value) {
                openKefirBatch(id)
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
            selectedTab = .preparazioni
            preparationsPath = []
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
            selectedTab = .preparazioni
            preparationsPath = []
            presentBanner("Starter non trovato", duration: 8)
            return
        }

        openStarter(starter.id)
    }

    func showNotificationsDisabledBanner() {
        selectedTab = .oggi
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
        bannerPresenter?(message, duration)
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

        // Phase 19 — kefir batch deep link
        static func kefirBatch(id: UUID) -> String {
            "\(scheme)://kefir/\(id.uuidString)"
        }
    }
}
