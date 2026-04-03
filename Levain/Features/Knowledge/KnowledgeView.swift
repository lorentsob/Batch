import SwiftUI

struct KnowledgeView: View {
    @ObservedObject var library: KnowledgeLibrary

    @State private var query = ""
    @State private var selectedCategory: KnowledgeCategory? = nil

    private var filteredItems: [KnowledgeItem] {
        library.items.filter { item in
            let matchCategory = selectedCategory == nil || item.category == selectedCategory
            let matchQuery =
                query.isEmpty ||
                item.title.localizedCaseInsensitiveContains(query) ||
                item.content.localizedCaseInsensitiveContains(query) ||
                item.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) })
            return matchCategory && matchQuery
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SectionCard(emphasis: .tinted) {
                    Text("Guide")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text("Consigli rapidi, fermentazione e baker's math raccolti in blocchi leggibili.")
                        .foregroundStyle(Theme.muted)
                    StateBadge(text: "\(filteredItems.count) risultati", tone: .count)
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        KnowledgeCategoryPillView(title: "Tutti", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(KnowledgeCategory.allCases) { category in
                            KnowledgeCategoryPillView(title: category.title, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    if filteredItems.isEmpty {
                        EmptyStateView(
                            title: "Nessun risultato",
                            message: "Prova a modificare la ricerca o rimuovere il filtro per categoria.",
                            actionTitle: "Mostra tutte le guide"
                        ) {
                            query = ""
                            selectedCategory = nil
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredItems) { item in
                            NavigationLink(value: KnowledgeRoute.article(item.id)) {
                                KnowledgeRowView(item: item)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("KnowledgeArticleRow-\(item.id)")
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 64)
            .padding(.top, 8)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Guide")
        .tint(Theme.Control.primaryFill)
        .searchable(text: $query, prompt: "Cerca guide e consigli")
        .accessibilityIdentifier("KnowledgeScrollView")
        .task {
            library.loadIfNeeded()
        }
    }
}

#Preview("Knowledge") {
    NavigationStack {
        KnowledgeView(library: KnowledgeLibrary())
    }
}
