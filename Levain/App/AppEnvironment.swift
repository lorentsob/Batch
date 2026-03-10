import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let notificationService: NotificationService
    let knowledgeLibrary: KnowledgeLibrary

    init(
        notificationService: NotificationService = NotificationService(),
        knowledgeLibrary: KnowledgeLibrary = KnowledgeLibrary()
    ) {
        self.notificationService = notificationService
        self.knowledgeLibrary = knowledgeLibrary
    }
}

