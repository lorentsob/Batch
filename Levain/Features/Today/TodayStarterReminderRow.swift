import SwiftUI

struct TodayStarterReminderRow: View {
    let item: TodayAgendaItem
    let action: () -> Void
    
    var body: some View {
        SectionCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                }
                
                Spacer()
                StateBadge(text: item.state)
            }
            
            Button(item.actionTitle) {
                action()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
    }
}
