import SwiftUI

struct KnowledgeRowView: View {
    let item: KnowledgeItem

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.category.title.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.muted)
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
