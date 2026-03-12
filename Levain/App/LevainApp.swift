import SwiftUI
import SwiftData

@main
struct LevainApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var environment = AppEnvironment()

    @State private var showSplash = true

    let container: ModelContainer

    init() {
        container = ModelContainerFactory.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .environmentObject(router)
                    .environmentObject(environment)
                    .modelContainer(container)

                if showSplash {
                    SplashView()
                        .transition(AnyTransition.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.3))
                withAnimation(.easeOut(duration: 0.45)) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - Splash

private struct SplashView: View {
    var body: some View {
        ZStack {
            Theme.Palette.green500
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 88, height: 88)

                        Image(systemName: "drop.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(Color.white)
                    }

                    VStack(spacing: 8) {
                        Text("Levain")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(Color.white)
                            .kerning(-0.5)

                        Text("La lievitazione al tuo ritmo")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.70))
                    }
                }

                Spacer()

                Text("Fatto in casa, con cura")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.45))
                    .padding(.bottom, 48)
            }
        }
    }
}
