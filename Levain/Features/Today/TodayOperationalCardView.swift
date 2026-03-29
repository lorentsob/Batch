import SwiftUI

// MARK: - Domain Display Helpers

extension TodayAgendaItem.Domain {
    var systemImage: String {
        switch self {
        case .pane:    return "flame.fill"
        case .starter: return "drop.fill"
        case .kefir:   return "drop.halffull"
        }
    }

    var displayName: String {
        switch self {
        case .pane:    return "Pane"
        case .starter: return "Starter"
        case .kefir:   return "Kefir"
        }
    }

    var tintColor: Color {
        switch self {
        case .pane:    return Theme.accent
        case .starter: return Color(hex: "#5AC8C8")  // teal — distinct from bread amber
        case .kefir:   return Theme.muted
        }
    }
}

// MARK: - TodayOperationalCardView

/// Shared wrapper that adds a domain cue strip above any Oggi feed card.
/// Gives bread, starter, and kefir items the same operational grammar so the feed
/// reads as one coherent cross-domain surface rather than separate section boards.
struct TodayOperationalCardView<Content: View>: View {
    let domain: TodayAgendaItem.Domain
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: domain.systemImage)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(domain.tintColor)
                Text(domain.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(domain.tintColor)
            }
            .padding(.leading, 2)
            .accessibilityLabel("Dominio: \(domain.displayName)")

            content()
        }
    }
}
