import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    @Published private(set) var preparedNotificationService: NotificationService?
    let knowledgeLibrary: KnowledgeLibrary

    var notificationService: NotificationService {
        if let preparedNotificationService {
            return preparedNotificationService
        }

        let service = NotificationService()
        preparedNotificationService = service
        return service
    }

    init(
        notificationService: NotificationService? = nil,
        knowledgeLibrary: KnowledgeLibrary = KnowledgeLibrary()
    ) {
        self.preparedNotificationService = notificationService
        self.knowledgeLibrary = knowledgeLibrary
    }

    func prepareNotificationServiceIfNeeded() -> NotificationService {
        notificationService
    }
}
