import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.ink)
                Text(message)
                    .foregroundStyle(Theme.muted)
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
            }
        }
    }
}
