import Foundation

/// Lightweight launch harness consumed exclusively by the app bootstrap.
/// UI test targets pass these keys via `XCUIApplication.launchEnvironment`
/// so the app boots into a known, deterministic state without depending on
/// stale simulator persistence, implicit seeding, or permission prompts.
///
/// This type is intentionally internal and not exposed as a user-facing
/// configuration surface.
enum AppLaunchOptions {

    // MARK: - Environment Keys

    /// `"1"` → use an in-memory store, discarding any persistent data.
    static let keyResetStore = "LEVAIN_RESET_STORE"

    /// `"1"` → insert sample data after the store is ready (must combine
    /// with `keyResetStore` to start truly fresh).
    static let keySeedSampleData = "LEVAIN_SEED_SAMPLE_DATA"

    /// Controls which deterministic seed scenario should be inserted when
    /// `keySeedSampleData` is enabled.
    static let keySeedScenario = "LEVAIN_SEED_SCENARIO"

    /// `"1"` → skip `requestAuthorizationIfNeeded` and `resyncAll` so
    /// the notification-permission sheet never appears during automation.
    static let keySuppressNotifications = "LEVAIN_SUPPRESS_NOTIFICATIONS"

    /// `"1"` → bypass OS notification APIs and behave as if authorization
    /// status were `.denied`. Used only by automation.
    static let keyForceNotificationsDenied = "LEVAIN_FORCE_NOTIFICATIONS_DENIED"

    /// When present, simulates a cold launch opened from a notification route.
    static let keyPendingNotificationRoute = "LEVAIN_PENDING_NOTIFICATION_ROUTE"

    // MARK: - Resolved Values

    /// Whether the current process was launched with an isolated in-memory store.
    static var shouldResetStore: Bool {
        ProcessInfo.processInfo.environment[keyResetStore] == "1"
    }

    /// Whether the current process should insert sample data on first boot.
    static var shouldSeedSampleData: Bool {
        ProcessInfo.processInfo.environment[keySeedSampleData] == "1"
    }

    static var seedScenario: String {
        ProcessInfo.processInfo.environment[keySeedScenario] ?? "operational"
    }

    /// Whether notification side-effects should be suppressed.
    static var shouldSuppressNotifications: Bool {
        ProcessInfo.processInfo.environment[keySuppressNotifications] == "1"
    }

    static var shouldForceNotificationsDenied: Bool {
        ProcessInfo.processInfo.environment[keyForceNotificationsDenied] == "1"
    }

    static var pendingNotificationRoute: String? {
        ProcessInfo.processInfo.environment[keyPendingNotificationRoute]
    }
}
