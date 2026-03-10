import SwiftUI

struct KnowledgeView: View {
    @EnvironmentObject private var environment: AppEnvironment
    
    @State private var query = ""
    @State private var selectedCategory: KnowledgeCategory? = nil
    
    private var filteredItems: [KnowledgeItem] {
        let items = environment.knowledgeLibrary.items
        return items.filter { item in
            let matchCategory = selectedCategory == nil || item.category == selectedCategory
            let matchQuery = query.isEmpty || item.title.localizedCaseInsensitiveContains(query) || item.content.localizedCaseInsensitiveContains(query) || item.tags.contains(where: { $0.localizedCaseInsensitiveContains(query) })
            return matchCategory && matchQuery
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Filtro categorie (horizontal scroll di pill)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            KnowledgeCategoryPillView(title: "Tutti", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(KnowledgeCategory.allCases) { cat in
                                KnowledgeCategoryPillView(title: cat.title, isSelected: selectedCategory == cat) {
                                    selectedCategory = cat
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Lista articoli
                    VStack(spacing: 12) {
                        if filteredItems.isEmpty {
                            EmptyStateView(
                                title: "Nessun risultato",
                                message: "Modifica la ricerca o il filtro per trovare contenuti.",
                                actionTitle: "Ricarica"
                            ) {
                                environment.knowledgeLibrary.loadIfNeeded()
                            }
                            .padding(.top, 40)
                        } else {
                            ForEach(filteredItems) { item in
                                NavigationLink(value: KnowledgeRoute.article(item.id)) {
                                    KnowledgeRowView(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 64)
                .padding(.top, 16)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Knowledge")
            .searchable(text: $query, prompt: "Cerca articoli e consigli")
            .navigationDestination(for: KnowledgeRoute.self) { route in
                switch route {
                case .article(let id):
                    if let item = environment.knowledgeLibrary.item(id: id) {
                        KnowledgeDetailView(item: item)
                    } else {
                        Text("Articolo non trovato")
                            .foregroundStyle(Theme.muted)
                    }
                }
            }
        }
        .task {
            environment.knowledgeLibrary.loadIfNeeded()
        }
    }
}
