import SwiftUI

struct StateBadge: View {
    let text: String

    private var colors: (Color, Color) {
        switch text.lowercased() {
        case "running", "in corso":
            (Theme.warning.opacity(0.16), Theme.warning)
        case "late", "overdue", "in ritardo":
            (Theme.danger.opacity(0.14), Theme.danger)
        case "done", "completato", "ok":
            (Theme.success.opacity(0.14), Theme.success)
        default:
            (Theme.accentSoft.opacity(0.4), Theme.accent)
        }
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(colors.1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(colors.0)
            )
    }
}

