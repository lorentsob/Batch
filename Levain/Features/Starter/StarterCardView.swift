import SwiftUI

struct StarterCardView: View {
    let starter: Starter

    var body: some View {
        SectionCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(starter.name)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text("\(starter.type.title) · \(Int(starter.hydration.rounded()))% idratazione")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    Text("Prossimo rinfresco: \(DateFormattingService.dayTime(starter.nextDueDate))")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                StateBadge(text: starter.dueState().title)
            }
        }
    }
}
