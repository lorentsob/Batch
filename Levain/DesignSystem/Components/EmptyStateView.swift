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
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text(title)
                    .font(Theme.Typography.title3)
                    .foregroundStyle(Theme.Text.primary)
                Text(message)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Text.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(PrimaryActionButtonStyle())
                        .frame(maxWidth: 240, alignment: .leading)
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
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text(title)
                    .font(Theme.Typography.title3)
                    .foregroundStyle(Theme.Text.primary)
                Text(message)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Text.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
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
