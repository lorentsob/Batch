import SwiftUI

struct StarterDetailHeaderView: View {
    let starter: Starter

    var body: some View {
        SectionCard {
            Text(starter.name)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(Theme.ink)
            Text("\(starter.type.title) · \(starter.storageMode.title)")
                .foregroundStyle(Theme.muted)

            HStack(spacing: 12) {
                StateBadge(text: starter.dueState().title)
                StateBadge(text: "ogni \(starter.refreshIntervalDays) gg")
            }

            if starter.flourMix.isEmpty == false {
                Text("Farina: \(starter.flourMix)")
                    .foregroundStyle(Theme.muted)
            }
            if starter.notes.isEmpty == false {
                Text(starter.notes)
                    .foregroundStyle(Theme.muted)
            }
        }
    }
}
