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

/// Multi-action empty state used by Today on first launch.
/// Presents up to three quick-action buttons aligned with the PRD first-launch guidance.
struct MultiActionEmptyStateView: View {
    struct Action: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let handler: () -> Void
    }

    let title: String
    let message: String
    let actions: [Action]

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.ink)
                Text(message)
                    .foregroundStyle(Theme.muted)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(actions) { action in
                        Button {
                            action.handler()
                        } label: {
                            Label(action.title, systemImage: action.systemImage)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.accent)
                    }
                }
            }
        }
    }
}
