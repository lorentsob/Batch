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

    /// `"1"` → skip `requestAuthorizationIfNeeded` and `resyncAll` so
    /// the notification-permission sheet never appears during automation.
    static let keySuppressNotifications = "LEVAIN_SUPPRESS_NOTIFICATIONS"

    // MARK: - Resolved Values

    /// Whether the current process was launched with an isolated in-memory store.
    static var shouldResetStore: Bool {
        ProcessInfo.processInfo.environment[keyResetStore] == "1"
    }

    /// Whether the current process should insert sample data on first boot.
    static var shouldSeedSampleData: Bool {
        ProcessInfo.processInfo.environment[keySeedSampleData] == "1"
    }

    /// Whether notification side-effects should be suppressed.
    static var shouldSuppressNotifications: Bool {
        ProcessInfo.processInfo.environment[keySuppressNotifications] == "1"
    }
}
