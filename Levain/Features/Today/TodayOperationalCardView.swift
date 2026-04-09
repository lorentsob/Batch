import SwiftUI

// MARK: - Domain Display Helpers

extension TodayAgendaItem.Domain {
    var displayName: String {
        switch self {
        case .pane:    return "Lievitati"
        case .starter: return "Starter"
        case .kefir:   return "Kefir"
        }
    }
}

// MARK: - TodayOperationalCardView

/// Shared wrapper that adds a domain cue strip above any Oggi feed card.
/// Gives bread, starter, and kefir items the same operational grammar so the feed
/// reads as one coherent cross-domain surface rather than separate section boards.
///
/// - Parameter showHeader: Pass `false` when the domain label was already shown
///   by a preceding item in the same section group. Defaults to `true`.
struct TodayOperationalCardView<Content: View>: View {
    let domain: TodayAgendaItem.Domain
    let showHeader: Bool
    @ViewBuilder let content: () -> Content

    init(
        domain: TodayAgendaItem.Domain,
        showHeader: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.domain = domain
        self.showHeader = showHeader
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showHeader {
                HStack(spacing: 5) {
                    domainIcon
                    Text(domain.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                }
                .padding(.leading, 2)
                .accessibilityLabel("Dominio: \(domain.displayName)")
            }
            content()
        }
    }

    @ViewBuilder
    private var domainIcon: some View {
        switch domain {
        case .starter:
            // Jar/container shape — the starter.svg asset
            Image("navbar-starter")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Theme.accent)
                .frame(width: 12, height: 12)
        case .pane:
            // Bread loaf shape — the bake.svg asset
            Image("navbar-bake")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Theme.accent)
                .frame(width: 12, height: 12)
        case .kefir:
            Image(systemName: "drop.fill")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.accent)
        }
    }
}
