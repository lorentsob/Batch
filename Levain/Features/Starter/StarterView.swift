import SwiftUI
import SwiftData

struct StarterView: View {
    @Query(sort: \Starter.name) private var starters: [Starter]

    @State private var showingEditor = false
    @State private var editingStarter: Starter?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Starter")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Gestisci routine, stato di salute e cronologia rinfreschi.")
                        .foregroundStyle(Theme.muted)
                    StateBadge(text: "\(starters.count) starter")
                }

                if starters.isEmpty {
                    EmptyStateView(
                        title: "Nessuno starter configurato",
                        message: "Crea il primo starter per far emergere promemoria e log di rinfresco.",
                        actionTitle: "Nuovo starter"
                    ) {
                        editingStarter = nil
                        showingEditor = true
                    }
                } else {
                    ForEach(starters) { starter in
                        NavigationLink(value: StarterRoute.detail(starter.id)) {
                            StarterCardView(starter: starter)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Modifica") {
                                editingStarter = starter
                                showingEditor = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Starter")
        .accessibilityIdentifier("StarterScrollView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingStarter = nil
                    showingEditor = true
                } label: {
                    Label("Nuovo starter", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                StarterEditorView(starter: editingStarter)
            }
        }
    }
}
