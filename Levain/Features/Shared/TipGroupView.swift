import SwiftUI

/// Shows a compact list of related knowledge tips, positioned as secondary/supportive content.
/// Opening a tip navigates to the shared article detail used by the Knowledge tab, ensuring
/// one consistent article destination across browse and contextual entry points.
struct TipGroupView: View {
    let title: String
    let items: [KnowledgeItem]
    let onOpen: (String) -> Void

    init(
        title: String = "Tips utili",
        items: [KnowledgeItem],
        onOpen: @escaping (String) -> Void
    ) {
        self.title = title
        self.items = Array(items.prefix(3))
        self.onOpen = onOpen
    }

    var body: some View {
        if !items.isEmpty {
            SectionCard {
                HStack {
                    Image(systemName: "lightbulb")
                        .font(.footnote)
                        .foregroundStyle(Theme.accent)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.muted)
                    Spacer()
                }

                ForEach(items) { item in
                    Button {
                        onOpen(item.id)
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.ink)
                                Text(item.summary)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.muted)
                                .padding(.top, 3)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.background.opacity(0.7))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
