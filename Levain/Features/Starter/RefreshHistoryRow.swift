import SwiftUI

struct RefreshHistoryRow: View {
    let refresh: StarterRefresh

    private let columns = [
        GridItem(.adaptive(minimum: 94), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DateFormattingService.dayTime(refresh.dateTime))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                MetricChip(label: "Starter", value: "\(Int(refresh.starterWeightUsed)) g", tone: .info)
                MetricChip(label: "Farina", value: "\(Int(refresh.flourWeight)) g", tone: .schedule)
                MetricChip(label: "Acqua", value: "\(Int(refresh.waterWeight)) g", tone: .schedule)
            }
            if refresh.ratioText.isEmpty == false {
                StateBadge(text: "Rapporto \(refresh.ratioText)", tone: .info)
            }
        }
        .padding(.vertical, 6)
    }
}
