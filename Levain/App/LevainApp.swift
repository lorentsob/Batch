import SwiftUI
import SwiftData

@main
struct LevainApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var environment = AppEnvironment()
    @StateObject private var bootstrap = AppBootstrapCoordinator()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = bootstrap.container {
                    RootTabView()
                        .environmentObject(router)
                        .environmentObject(environment)
                        .modelContainer(container)
                } else {
                    AppLaunchView()
                }
            }
            .task {
                bootstrap.loadIfNeeded()
            }
        }
    }
}

@MainActor
private final class AppBootstrapCoordinator: ObservableObject {
    @Published private(set) var container: ModelContainer?

    private var loadTask: Task<Void, Never>?

    func loadIfNeeded() {
        guard container == nil, loadTask == nil else { return }

        loadTask = Task {
            let loaded = await Task.detached(priority: .userInitiated) {
                LoadedContainer(container: ModelContainerFactory.makeContainer())
            }.value

            container = loaded.container
            loadTask = nil
        }
    }
}

private struct LoadedContainer: @unchecked Sendable {
    let container: ModelContainer
}

private struct AppLaunchView: View {
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Levain")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.ink)

                ProgressView("Carico i dati")
                    .tint(Theme.accent)
                    .foregroundStyle(Theme.muted)
            }
            .padding(32)
        }
        .accessibilityIdentifier("AppLaunchView")
    }
}
