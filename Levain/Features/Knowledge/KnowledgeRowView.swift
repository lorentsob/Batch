import SwiftUI

struct KnowledgeRowView: View {
    let item: KnowledgeItem

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    StateBadge(text: item.category.title, tone: .schedule)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.muted)
                }
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(item.summary)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                    .lineLimit(2)
            }
        }
    }
}
