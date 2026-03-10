import SwiftUI

struct RefreshHistoryRow: View {
    let refresh: StarterRefresh

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(DateFormattingService.dayTime(refresh.dateTime))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.ink)
            Text("\(Int(refresh.starterWeightUsed)) g starter · \(Int(refresh.flourWeight)) g farina · \(Int(refresh.waterWeight)) g acqua")
                .font(.footnote)
                .foregroundStyle(Theme.muted)
            if refresh.ratioText.isEmpty == false {
                Text("Rapporto \(refresh.ratioText)")
                    .font(.footnote)
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(.vertical, 6)
    }
}
