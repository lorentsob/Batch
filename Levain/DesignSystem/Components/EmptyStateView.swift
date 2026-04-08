import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    init(title: String, message: String) {
        self.title = title
        self.message = message
        self.actionTitle = nil
        self.action = nil
    }

    init(title: String, message: String, actionTitle: String, action: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(message)
                    .foregroundStyle(Theme.muted)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(PrimaryActionButtonStyle())
                }
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
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 26, weight: .semibold))
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
                        .buttonStyle(SecondaryActionButtonStyle())
                    }
                }
            }
        }
    }
}
