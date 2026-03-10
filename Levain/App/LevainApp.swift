import SwiftUI
import SwiftData

@main
struct LevainApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var environment = AppEnvironment()

    private let container = ModelContainerFactory.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(router)
                .environmentObject(environment)
                .modelContainer(container)
        }
    }
}
