import SwiftUI
import SwiftData

struct StarterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Starter.name) private var starters: [Starter]

    @State private var showingEditor = false
    @State private var editingStarter: Starter?
    @State private var isArchiveExpanded = false
    @State private var rowsVisible = false

    private var activeStarters: [Starter] { starters.filter { !$0.isArchived } }
    private var archivedStarters: [Starter] { starters.filter { $0.isArchived } }

    var body: some View {
        List {
            SectionCard(emphasis: .tinted) {
                ScreenTitleBlock(
                    title: "Starter",
                    subtitle: "I tuoi starter"
                )
                
                if !activeStarters.isEmpty {
                    StateBadge(text: "\(activeStarters.count) starter", tone: .count)
                }

                Button {
                    editingStarter = nil
                    showingEditor = true
                } label: {
                    Label("Aggiungi starter", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.top, Theme.Spacing.xxs)
            }
            .listRowInsets(.levainListRow(top: Theme.Spacing.sm, bottom: Theme.Spacing.md))



            if activeStarters.isEmpty {
                EmptyStateView(
                    title: "Nessuno starter ancora",
                    message: "Aggiungi il tuo lievito madre per tracciare i rinfreschi, calcolare il prossimo e ricevere promemoria al momento giusto."
                )
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.levainListRow(bottom: Theme.Spacing.xs))
                .animation(Theme.Animation.standard, value: activeStarters.isEmpty)
            } else {
                ForEach(Array(activeStarters.enumerated()), id: \.element.id) { index, starter in
                    starterRow(starter)
                        .opacity(rowsVisible ? 1 : 0)
                        .offset(y: rowsVisible ? 0 : 8)
                        .animation(
                            Theme.Animation.standard.delay(Double(min(index, 5)) * 0.05),
                            value: rowsVisible
                        )
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
                .onAppear {
                    if reduceMotion {
                        rowsVisible = true
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            rowsVisible = true
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
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Text.primary)
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
                .listRowInsets(.levainListRow(top: Theme.Spacing.md, bottom: Theme.Spacing.xs))

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
        .levainListSurface()
        .tint(Theme.Control.primaryFill)
        .accessibilityIdentifier("StarterScrollView")
        .accessibilityIdentifier("StarterScrollView")
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
        .listRowInsets(.levainListRow(bottom: Theme.Spacing.xs))
    }
}

#Preview("Starter") {
    NavigationStack {
        StarterView()
    }
    .environmentObject(AppRouter())
    .modelContainer(ModelContainerFactory.makePreviewContainer())
}
