import SwiftUI
import SwiftData
import AVFoundation
import UIKit

@main
struct LevainApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var environment = AppEnvironment()

    @State private var showSplash = !AppLaunchOptions.shouldSkipSplash

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
                guard showSplash else {
                    environment.markLaunchTransitionComplete()
                    return
                }
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
            let logoSize = min(geo.size.width * 0.58, 260)

            ZStack {
                Color(hex: "#155D4D")
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    SplashLogoAnimationView(reduceMotion: reduceMotion)
                        .frame(width: logoSize, height: logoSize)
                        .shadow(color: Theme.Palette.green800.opacity(0.28), radius: 30, x: 0, y: 18)
                        .opacity(logoVisible ? 1 : 0)
                        .scaleEffect(logoVisible ? (logoPulsing ? 0.984 : 1.0) : 0.76)
                        .offset(y: logoVisible ? 0 : 22)

                    VStack(spacing: 8) {
                        Text("Batch")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(Theme.Palette.neutral0)
                            .kerning(-0.5)
                            .opacity(titleVisible ? 1 : 0)
                            .offset(y: titleVisible ? 0 : 14)

                        Text("Fermenti Vivi")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Theme.Palette.neutral0.opacity(0.72))
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

private struct SplashLogoAnimationView: View {
    let reduceMotion: Bool

    // Created once in onAppear: a default-value expression here would run on every
    // re-init of this view (the splash re-renders while it animates).
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if reduceMotion || player == nil {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
            }

            if let player, reduceMotion == false {
                SplashLogoPlayerView(player: player)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .accessibilityHidden(true)
        .onAppear {
            if player == nil {
                player = SplashLogoAnimationAsset.makePlayer()
            }
            guard reduceMotion == false else { return }
            player?.seek(to: .zero)
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
        .onChange(of: reduceMotion) { _, shouldReduceMotion in
            if shouldReduceMotion {
                player?.pause()
                player?.seek(to: .zero)
            } else {
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }
}

private struct SplashLogoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.configure(with: player)
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.configure(with: player)
    }

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: ()) {
        uiView.playerLayer.player = nil
    }
}

private final class PlayerContainerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with player: AVPlayer) {
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.isOpaque = false
    }
}

private enum SplashLogoAnimationAsset {
    /// Copies the bundled video to a temporary file once per install and reuses it,
    /// so the file is never rewritten while a player is reading it.
    @MainActor
    private static let fileURL: URL? = {
        guard let dataAsset = NSDataAsset(name: "BatchLogoLoading") else {
            return nil
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("batch-logo-loading")
            .appendingPathExtension("mov")

        let existingSize = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.size] as? Int
        if existingSize == dataAsset.data.count {
            return url
        }

        do {
            try dataAsset.data.write(to: url, options: [.atomic])
            return url
        } catch {
            return nil
        }
    }()

    @MainActor
    static func makePlayer() -> AVPlayer? {
        guard let fileURL else { return nil }
        let player = AVPlayer(url: fileURL)
        player.isMuted = true
        player.actionAtItemEnd = .pause
        return player
    }
}
