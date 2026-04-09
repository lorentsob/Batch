import SwiftData
import SwiftUI

@MainActor
struct BreadHubView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \Starter.name) private var starters: [Starter]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]
    @Query private var appSettingsList: [AppSettings]

    @State private var showingBakeEditor = false
    @State private var showingStarterEditor = false
    @State private var showingFormulaEditor = false
    @State private var editingStarter: Starter?

    private let metricColumns = [GridItem(.adaptive(minimum: 118), spacing: 8)]

    private var appSettings: AppSettings? { appSettingsList.first }
    private var isBakeEnabled: Bool { appSettings?.isBakeEnabled ?? true }
    private var isStarterEnabled: Bool { appSettings?.isStarterEnabled ?? true }

    private var activeBakes: [Bake] {
        bakes.filter { $0.derivedStatus != .cancelled && $0.derivedStatus != .completed }
    }

    var body: some View {
        List {
            headerCard

            if isBakeEnabled {
                impastiSection
            }

            if isStarterEnabled {
                starterSection
            }

            ricetteRow
        }
        .listStyle(.plain)
        .background(Theme.Surface.app)
        .navigationTitle("Pane e lievito madre")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if isBakeEnabled {
                        Button {
                            showingBakeEditor = true
                        } label: {
                            Label("Nuovo impasto", image: "navbar-bake")
                        }
                    }
                    if isStarterEnabled {
                        Button {
                            showingStarterEditor = true
                        } label: {
                            Label("Nuovo starter", image: "navbar-starter")
                        }
                    }
                    Button("Nuova ricetta", systemImage: "doc.text") {
                        showingFormulaEditor = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeCreationView(preselectedFormula: nil)
            }
        }
        .sheet(isPresented: $showingStarterEditor) {
            NavigationStack {
                StarterEditorView(starter: editingStarter)
            }
            .onDisappear { editingStarter = nil }
        }
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: nil)
            }
        }
        .accessibilityIdentifier("BreadHubView")
    }

    // MARK: - Header

    private var headerCard: some View {
        SectionCard(emphasis: .tinted) {
            Text("Pane e lievito madre")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.ink)
            Text("Impasti attivi e i tuoi starter.")
                .foregroundStyle(Theme.muted)
            if activeBakes.isEmpty == false || starters.isEmpty == false {
                HStack(spacing: 8) {
                    if activeBakes.isEmpty == false {
                        StateBadge(text: "\(activeBakes.count) impast\(activeBakes.count == 1 ? "o" : "i") attiv\(activeBakes.count == 1 ? "o" : "i")", tone: .count)
                    }
                    if starters.isEmpty == false {
                        StateBadge(text: "\(starters.count) starter", tone: .count)
                    }
                }
            }
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Impasti section

    private var impastiSection: some View {
        Group {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Impasti attivi")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                }
                .padding(.bottom, 4)

                if activeBakes.isEmpty {
                    EmptyStateView(
                        title: "Nessun impasto attivo",
                        message: "Scegli una ricetta, imposta l'orario di sfornatura e Levain costruisce la timeline.",
                        actionTitle: "Nuovo impasto"
                    ) {
                        showingBakeEditor = true
                    }
                    .accessibilityIdentifier("BreadHubBakesEmptyState")
                }
            }
            .listRowInsets(.init(top: 0, leading: 20, bottom: 8, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            ForEach(activeBakes) { bake in
                Button {
                    router.fermentationsPath.append(.bake(bake.id))
                } label: {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(bake.name)
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    Text(bake.type.title)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted)
                                }
                                Spacer()
                                StateBadge(bakeStatus: bake.derivedStatus)
                            }

                            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                                MetricChip(
                                    label: "Utilizzo",
                                    value: DateFormattingService.dayTime(bake.targetBakeDateTime),
                                    tone: .schedule
                                )
                                if let step = bake.activeStep {
                                    MetricChip(label: "Prossima fase", value: step.displayName, tone: .info)
                                }
                            }

                            if let step = bake.activeStep {
                                Text(step.descriptionText.isEmpty ? "La fase attiva è pronta da seguire." : step.descriptionText)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("BreadHubBakeCard_\(bake.id)")
                .listRowInsets(.init(top: 0, leading: 20, bottom: 12, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteBakes)
        }
    }

    // MARK: - Starter section

    private var starterSection: some View {
        Group {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Starter")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                }
                .padding(.bottom, 4)

                if starters.isEmpty {
                    EmptyStateView(
                        title: "Nessuno starter ancora",
                        message: "Aggiungi il tuo lievito madre per tracciare i rinfreschi e ricevere promemoria.",
                        actionTitle: "Aggiungi starter"
                    ) {
                        editingStarter = nil
                        showingStarterEditor = true
                    }
                    .accessibilityIdentifier("BreadHubStartersEmptyState")
                }
            }
            .listRowInsets(.init(top: 0, leading: 20, bottom: 8, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            ForEach(starters) { starter in
                Button {
                    router.fermentationsPath.append(.starter(starter.id))
                } label: {
                    StarterCardView(starter: starter)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("Modifica") {
                        editingStarter = starter
                        showingStarterEditor = true
                    }
                }
                .accessibilityIdentifier("BreadHubStarterCard_\(starter.id)")
                .listRowInsets(.init(top: 0, leading: 20, bottom: 12, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteStarters)
        }
    }

    // MARK: - Ricette row

    private var ricetteRow: some View {
        Section {
            Button {
                router.fermentationsPath.append(.formulaList)
            } label: {
                SectionCard {
                    HStack(spacing: 14) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ricette")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            Text(formulas.isEmpty ? "Nessuna ricetta salvata." : "\(formulas.count) formula\(formulas.count == 1 ? "" : "e")")
                                .font(.subheadline)
                                .foregroundStyle(Theme.muted)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.muted)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("BreadHubFormuleRow")
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 24, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func deleteBakes(at offsets: IndexSet) {
        for index in offsets {
            let bake = activeBakes[index]
            modelContext.delete(bake)
        }
    }

    private func deleteStarters(at offsets: IndexSet) {
        for index in offsets {
            let starter = starters[index]
            modelContext.delete(starter)
        }
    }
}
