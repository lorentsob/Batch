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
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: .opacity.combined(with: .scale(scale: 1.08))
                            )
                        )
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.9))
                withAnimation(.easeIn(duration: 0.55)) {
                    showSplash = false
                }
                // Signal views to begin their entrance animation as the
                // splash is finishing its fade (0.55 s transition, fire slightly early).
                try? await Task.sleep(for: .seconds(0.2))
                environment.markLaunchTransitionComplete()
            }
            .preferredColorScheme(.light)
        }
    }
}

// MARK: - Splash

private struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var logoVisible = false
    @State private var titleVisible = false
    @State private var subtitleVisible = false
    @State private var logoPulsing = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Radial gradient — warm glow at the logo centre, deepens toward edges
                RadialGradient(
                    colors: [
                        Color(hex: "#0F4A35"),
                        Theme.Palette.green800
                    ],
                    center: UnitPoint(x: 0.5, y: 0.38),
                    startRadius: 0,
                    endRadius: geo.size.height * 0.68
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.65)
                        // Layered shadow: green glow + depth
                        .shadow(color: Theme.Palette.green500.opacity(0.30), radius: 44, x: 0, y: 0)
                        .shadow(color: Color.black.opacity(0.22), radius: 24, x: 0, y: 14)
                        .opacity(logoVisible ? 1 : 0)
                        .scaleEffect(logoVisible ? (logoPulsing ? 0.984 : 1.0) : 0.76)
                        .offset(y: logoVisible ? 0 : 22)

                    VStack(spacing: 8) {
                        Text("Batch")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Color.white)
                            .kerning(-0.5)
                            .opacity(titleVisible ? 1 : 0)
                            .offset(y: titleVisible ? 0 : 14)

                        Text("Fermenti Vivi")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Color.white.opacity(0.50))
                            .kerning(0.4)
                            .opacity(subtitleVisible ? 1 : 0)
                            .offset(y: subtitleVisible ? 0 : 8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if reduceMotion {
                logoVisible = true
                titleVisible = true
                subtitleVisible = true
            } else {
                // Logo: spring with slight overshoot for energy
                withAnimation(.interpolatingSpring(stiffness: 52, damping: 11)) {
                    logoVisible = true
                }
                // Title slides up after logo settles
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                    withAnimation(Theme.Animation.standard) { titleVisible = true }
                }
                // Subtitle fades in shortly after
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {
                    withAnimation(Theme.Animation.gentle) { subtitleVisible = true }
                }
                // Subtle breathing pulse once logo has landed
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.90) {
                    withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                        logoPulsing = true
                    }
                }
            }
        }
    }
}
