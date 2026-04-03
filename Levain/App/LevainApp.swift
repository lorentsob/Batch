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
                withAnimation(.easeOut(duration: 0.8)) {
                    showSplash = false
                }
            }
            .preferredColorScheme(.light)
        }
    }
}

// MARK: - Splash

private struct SplashView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Theme.Palette.green800
                    .ignoresSafeArea()

                VStack(spacing: 28) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.72)
                        .shadow(color: Color.black.opacity(0.18), radius: 32, x: 0, y: 12)

                    VStack(spacing: 10) {
                        Text("Batch")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.white)
                            .kerning(-0.3)

                        Text("Fermenti vivi")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.55))
                            .kerning(0.3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea()
    }
}
