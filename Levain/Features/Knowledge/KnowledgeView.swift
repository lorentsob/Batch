import SwiftUI

struct KnowledgeView: View {
    @EnvironmentObject private var environment: AppEnvironment

    @State private var selectedFilter = "all"

    private let filters = ["all"] + KnowledgeCategory.allCases.map(\.rawValue)

    private var items: [KnowledgeItem] {
        environment.knowledgeLibrary.items.filter { item in
            selectedFilter == "all" || item.category.rawValue == selectedFilter
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Knowledge")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Suggerimenti statici e offline per starter, fermentazione e troubleshooting.")
                        .foregroundStyle(Theme.muted)

                    Picker("Filtro", selection: $selectedFilter) {
                        Text("Tutti").tag("all")
                        ForEach(KnowledgeCategory.allCases) { category in
                            Text(category.title).tag(category.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if items.isEmpty {
                    EmptyStateView(
                        title: "Nessun contenuto",
                        message: "La libreria verra caricata dai contenuti statici inclusi nel bundle.",
                        actionTitle: "Ricarica"
                    ) {
                        environment.knowledgeLibrary.loadIfNeeded()
                    }
                } else {
                    ForEach(items) { item in
                        NavigationLink(value: KnowledgeRoute.article(item.id)) {
                            SectionCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    Text(item.summary)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted)
                                    Text(item.category.title)
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Theme.accent)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Knowledge")
        .task {
            environment.knowledgeLibrary.loadIfNeeded()
        }
    }
}

struct KnowledgeDetailView: View {
    let item: KnowledgeItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text(item.title)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text(item.summary)
                        .foregroundStyle(Theme.muted)
                    StateBadge(text: item.category.title)
                }

                SectionCard {
                    Text(item.content)
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if item.tags.isEmpty == false {
                    SectionCard {
                        Text("Tag")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text(item.tags.joined(separator: " · "))
                            .foregroundStyle(Theme.muted)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Articolo")
    }
}
