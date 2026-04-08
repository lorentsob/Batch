import SwiftUI

struct StarterDetailHeaderView: View {
    let starter: Starter
    let onRefresh: () -> Void

    private let metricColumns = [
        GridItem(.adaptive(minimum: 120), spacing: 8)
    ]

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(starter.name)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Theme.ink)
                        Text("Gestione starter")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }

                    Spacer()

                    StateBadge(dueState: starter.dueState())
                }

                LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                    MetricChip(label: "Tipo", value: starter.type.title, tone: .info)
                    MetricChip(label: "Conservazione", value: starter.storageMode.title, tone: .info)
                    MetricChip(label: "Cadenza", value: "Ogni \(starter.refreshIntervalDays) gg", tone: .schedule)
                    MetricChip(label: "Ultimo rinfresco", value: DateFormattingService.dayTime(starter.lastRefresh), tone: .schedule)
                }

                if starter.selectedFlours.isEmpty == false {
                    VStack(alignment: .leading, spacing: 8) {
                        StateBadge(text: "Mix farine", tone: .schedule)
                        LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                            ForEach(starter.selectedFlours) { flour in
                                MetricChip(
                                    label: flour.shortDisplayName,
                                    value: "\(Int(flour.percentage.rounded()))%",
                                    tone: .schedule
                                )
                            }
                        }
                    }
                }

                if starter.notes.isEmpty == false {
                    VStack(alignment: .leading, spacing: 6) {
                        StateBadge(text: "Note", tone: .info)
                        Text(starter.notes)
                            .foregroundStyle(Theme.muted)
                    }
                }

                Button(action: onRefresh) {
                    Label("Rinfresca", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.top, 4)
            }
        }
    }
}
