import SwiftUI
import SwiftData

struct StarterView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Starter.name) private var starters: [Starter]

    @State private var showingEditor = false
    @State private var editingStarter: Starter?
    @State private var isArchiveExpanded = false

    private var activeStarters: [Starter] { starters.filter { !$0.isArchived } }
    private var archivedStarters: [Starter] { starters.filter { $0.isArchived } }

    var body: some View {
        List {
            SectionCard(emphasis: .tinted) {
                Text("Starter")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("Rinfreschi e stato del tuo lievito madre.")
                    .foregroundStyle(Theme.muted)
                if activeStarters.isEmpty == false {
                    StateBadge(text: "\(activeStarters.count) starter", tone: .count)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 24, leading: 20, bottom: 20, trailing: 20))

            if activeStarters.isEmpty {
                EmptyStateView(
                    title: "Nessuno starter ancora",
                    message: "Aggiungi il tuo lievito madre per tracciare i rinfreschi, calcolare il prossimo e ricevere promemoria al momento giusto.",
                    actionTitle: "Aggiungi il tuo starter"
                ) {
                    editingStarter = nil
                    showingEditor = true
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
            } else {
                ForEach(activeStarters) { starter in
                    starterRow(starter)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation { starter.archive() }
                            } label: {
                                Label("Archivia", systemImage: "archivebox")
                            }
                        }
                        .contextMenu {
                            Button("Modifica") {
                                editingStarter = starter
                                showingEditor = true
                            }
                            Button("Archivia", role: .destructive) {
                                withAnimation { starter.archive() }
                            }
                        }
                }
            }

            if archivedStarters.isEmpty == false {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isArchiveExpanded.toggle() }
                } label: {
                    HStack {
                        Text("Archiviati")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        StateBadge(text: "\(archivedStarters.count)", tone: .count)
                        Image(systemName: isArchiveExpanded ? "chevron.up" : "chevron.down")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.muted)
                    }
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 8, trailing: 20))

                if isArchiveExpanded {
                    ForEach(archivedStarters) { starter in
                        starterRow(starter)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    withAnimation { starter.unarchive() }
                                } label: {
                                    Label("Ripristina", systemImage: "arrow.uturn.left")
                                }
                                .tint(Theme.Control.primaryFill)
                            }
                            .contextMenu {
                                Button("Ripristina") {
                                    withAnimation { starter.unarchive() }
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.plain)
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

    @ViewBuilder
    private func starterRow(_ starter: Starter) -> some View {
        ZStack {
            NavigationLink(value: FermentationsRoute.starter(starter.id)) {
                EmptyView()
            }
            .opacity(0)

            StarterCardView(starter: starter)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
    }
}

#Preview("Starter") {
    NavigationStack {
        StarterView()
    }
    .environmentObject(AppRouter())
    .modelContainer(ModelContainerFactory.makePreviewContainer())
}
