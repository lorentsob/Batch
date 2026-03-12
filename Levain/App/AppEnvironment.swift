import Foundation

struct AppBanner: Identifiable, Equatable {
    let id = UUID()
    let message: String
}

@MainActor
final class AppEnvironment: ObservableObject {
    @Published private(set) var preparedNotificationService: NotificationService?
    @Published private(set) var banner: AppBanner?
    let knowledgeLibrary: KnowledgeLibrary
    private var bannerDismissTask: Task<Void, Never>?

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

    func showBanner(_ message: String, duration: TimeInterval = 3) {
        bannerDismissTask?.cancel()

        let banner = AppBanner(message: message)
        self.banner = banner

        bannerDismissTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard Task.isCancelled == false,
                  let self,
                  self.banner?.id == banner.id else {
                return
            }
            self.banner = nil
        }
    }
}
