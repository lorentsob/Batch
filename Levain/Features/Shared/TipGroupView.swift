import SwiftUI

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
        if items.isEmpty == false {
            SectionCard {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                ForEach(items) { item in
                    Button {
                        onOpen(item.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.ink)
                            Text(item.summary)
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Theme.background.opacity(0.8))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
