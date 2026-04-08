import SwiftUI

enum SectionCardEmphasis {
    case surface
    case subtle
    case tinted
    case danger
}

struct SectionCard<Content: View>: View {
    let emphasis: SectionCardEmphasis
    let padding: CGFloat
    let content: Content

    init(
        emphasis: SectionCardEmphasis = .surface,
        padding: CGFloat = Theme.Spacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.emphasis = emphasis
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .fill(fillColor)
                .shadow(color: Theme.Shadow.card.opacity(emphasis == .surface ? 1 : 0.72), radius: 18, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .stroke(borderColor, lineWidth: emphasis == .tinted ? 1.25 : 1)
        )
    }

    private var fillColor: Color {
        switch emphasis {
        case .surface:
            Theme.Surface.card
        case .subtle:
            Theme.Surface.subtle
        case .tinted:
            Theme.Surface.tinted
        case .danger:
            Theme.Surface.danger
        }
    }

    private var borderColor: Color {
        switch emphasis {
        case .surface, .subtle:
            Theme.Border.defaultColor
        case .tinted:
            Theme.Border.emphasis
        case .danger:
            Theme.Border.danger
        }
    }
}
