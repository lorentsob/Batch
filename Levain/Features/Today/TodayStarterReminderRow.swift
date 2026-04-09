import SwiftUI

struct TodayStarterReminderRow: View {
    let item: TodayAgendaItem
    let urgency: TodayAgendaItem.Urgency
    let action: () -> Void

    private var isUrgent: Bool { urgency == .overdue }

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(item.title)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Text.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)

                        Text(item.subtitle)
                            .font(Theme.Typography.caption1Semibold)
                            .foregroundStyle(isUrgent ? Theme.Text.onDanger : Theme.Control.secondaryForeground)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: Theme.Spacing.xs)

                    StateBadge(text: item.state, tone: badgeTone)
                }

                actionButton
            }
        }
        .overlay(overdueOutline)
    }

    private var badgeTone: StateBadge.Tone {
        isUrgent ? .overdue : .pending
    }

    private var overdueOutline: some View {
        RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
            .stroke(Theme.Border.danger, lineWidth: isUrgent ? 1.5 : 0)
    }

    @ViewBuilder
    private var actionButton: some View {
        if isUrgent {
            Button(item.actionTitle) {
                action()
            }
            .buttonStyle(DangerActionButtonStyle())
        } else {
            Button(item.actionTitle) {
                action()
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
    }
}
