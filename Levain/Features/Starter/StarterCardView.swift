import SwiftUI

struct StarterCardView: View {
    let starter: Starter

    private let metricColumns = [
        GridItem(.adaptive(minimum: 118), spacing: 8)
    ]

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(starter.name)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text("\(starter.type.title) · \(Int(starter.hydration.rounded()))% idratazione")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    StateBadge(dueState: starter.dueState())
                }

                LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                    MetricChip(label: "Rinfreschi", value: "Ogni \(starter.refreshIntervalDays) gg", tone: .info)
                    MetricChip(label: "Prossimo", value: DateFormattingService.dayTime(starter.nextDueDate), tone: reminderTone)
                }

                if starter.selectedFlours.isEmpty == false {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Farine")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Theme.Text.tertiary)
                            .textCase(.uppercase)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(starter.selectedFlours) { flour in
                                    Text(flour.shortDisplayName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Theme.Text.primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Theme.Surface.card)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Theme.Border.emphasis, lineWidth: 1.5)
                                                )
                                        )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var reminderTone: StateBadge.Tone {
        switch starter.dueState() {
        case .ok:
            .info
        case .dueToday:
            .pending
        case .overdue:
            .danger
        }
    }

}
