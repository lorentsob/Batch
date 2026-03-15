import SwiftUI

struct RefreshHistoryRow: View {
    let refresh: StarterRefresh

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(DateFormattingService.dayTime(refresh.dateTime))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                if !refresh.ratioText.isEmpty {
                    Text("Rapporto \(refresh.ratioText)")
                        .font(.caption)
                        .foregroundStyle(Theme.muted)
                }
            }
            Spacer()
            if refresh.putInFridgeAt != nil {
                Image(systemName: "snowflake")
                    .font(.footnote)
                    .foregroundStyle(Theme.accent)
            }
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.muted)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Theme.panel.cornerRadius(Theme.Radius.compact))
    }
}
