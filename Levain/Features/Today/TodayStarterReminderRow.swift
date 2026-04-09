import SwiftUI

struct TodayStarterReminderRow: View {
    let item: TodayAgendaItem
    let urgency: TodayAgendaItem.Urgency
    let action: () -> Void

    private var isUrgent: Bool { urgency == .overdue || urgency == .warning }

    var body: some View {
        Group {
            if isUrgent {
                SectionCard {
                    content(titleFont: .headline, subtitleFont: .subheadline, badgeTone: .danger)
                    Button(item.actionTitle) {
                        action()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
            } else {
                HStack(alignment: .center, spacing: 14) {
                    content(titleFont: .subheadline.weight(.semibold), subtitleFont: .footnote, badgeTone: .schedule)
                    Button(item.actionTitle) {
                        action()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                        .fill(Theme.Surface.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.nestedCard, style: .continuous)
                        .stroke(Theme.Border.defaultColor, lineWidth: 1)
                )
            }
        }
    }

    @ViewBuilder
    private func content(titleFont: Font, subtitleFont: Font, badgeTone: StateBadge.Tone) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(titleFont)
                    .foregroundStyle(Theme.ink)
                Text(item.subtitle)
                    .font(subtitleFont)
                    .foregroundStyle(Theme.muted)
            }

            Spacer()
            StateBadge(text: item.state, tone: badgeTone)
        }
    }
}
