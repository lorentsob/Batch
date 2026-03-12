import SwiftUI
import SwiftData

struct StarterView: View {
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Starter.name) private var starters: [Starter]

    @State private var showingEditor = false
    @State private var editingStarter: Starter?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard(emphasis: .tinted) {
                    Text("Starter")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text("Rinfreschi, ritmo e stato del tuo lievito madre.")
                        .foregroundStyle(Theme.muted)
                    if starters.isEmpty == false {
                        StateBadge(text: "\(starters.count) starter", tone: .count)
                    }
                }

                if starters.isEmpty {
                    EmptyStateView(
                        title: "Nessuno starter ancora",
                        message: "Aggiungi il tuo lievito madre per tracciare i rinfreschi, calcolare il prossimo e ricevere promemoria al momento giusto.",
                        actionTitle: "Aggiungi il tuo starter"
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
        .tint(Theme.Control.primaryFill)
        .accessibilityIdentifier("StarterScrollView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editingStarter = nil
                    showingEditor = true
                } label: {
                    Text("Nuovo starter")
                        .fontWeight(.semibold)
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
