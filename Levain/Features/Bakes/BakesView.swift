import SwiftData
import SwiftUI

@MainActor
struct BakesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?
    @State private var showingBakeEditor = false
    @State private var preselectedFormula: RecipeFormula?
    @State private var shouldPreselectFirstAvailable = false
    @State private var isArchiveExpanded = false // legacy flag, kept for now
    @State private var showingArchiveSheet = false

    private let metricColumns = [
        GridItem(.adaptive(minimum: 118), spacing: 8)
    ]

    private var activeBakes: [Bake] {
        bakes.filter { $0.derivedStatus != .cancelled && $0.derivedStatus != .completed }
    }

    private var archivedBakes: [Bake] {
        bakes.filter { $0.derivedStatus == .cancelled || $0.derivedStatus == .completed }
    }

    var body: some View {
        List {
            Group {
                SectionCard(emphasis: .tinted) {
                    Text("Impasti")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text("I tuoi bake in corso e in programma.")
                        .foregroundStyle(Theme.muted)
                    HStack(spacing: 12) {
                        if activeBakes.isEmpty == false {
                            StateBadge(text: "\(activeBakes.count) attivi", tone: .count)
                        }
                        if formulas.isEmpty == false {
                            StateBadge(text: "\(formulas.count) ricette", tone: .count)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 24, leading: 20, bottom: 20, trailing: 20))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Bake attivi")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if activeBakes.isEmpty {
                        EmptyStateView(
                            title: "Nessun bake ancora",
                            message: "Scegli una ricetta, imposta l'orario di sfornatura e Levain costruisce la timeline per te.",
                            actionTitle: emptyStateActionTitle
                        ) {
                            preselectedFormula = formulas.first
                            shouldPreselectFirstAvailable = formulas.isEmpty
                            showingBakeEditor = true
                        }
                        .accessibilityIdentifier("BakesEmptyState")
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))

                if activeBakes.isEmpty == false {
                    ForEach(activeBakes) { bake in
                        ZStack {
                            NavigationLink(value: FermentationsRoute.bake(bake.id)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    archive(bake)
                                }
                            } label: {
                                Label("Archivia", systemImage: "archivebox")
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
                    }
                }

                if archivedBakes.isEmpty == false {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            showingArchiveSheet = true
                        } label: {
                            HStack {
                                Text("Archivio")
                                    .font(.headline)
                                    .foregroundStyle(Theme.ink)
                                StateBadge(text: "\(archivedBakes.count)", tone: .count)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 12, trailing: 20))
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ricette")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    SectionCard {
                        ZStack {
                            NavigationLink(value: FermentationsRoute.formulaList) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Le tue ricette")
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    Text("Raccogli ricette, template e tempi di lavoro.")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted)
                                    StateBadge(text: "\(formulas.count) salvate", tone: .count)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 12, trailing: 20))
                
                // Bottom spacing for FAB
                Color.clear.frame(height: 80)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .background(Theme.background.ignoresSafeArea())
        .tint(Theme.Control.primaryFill)
        .accessibilityIdentifier("BakesScrollView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    preselectedFormula = formulas.first
                    shouldPreselectFirstAvailable = formulas.isEmpty
                    showingBakeEditor = true
                } label: {
                    Text("Nuovo bake")
                        .fontWeight(.semibold)
                }
                .accessibilityIdentifier("BakesPrimaryNewBakeButton")
            }
        }
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: editingFormula)
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeCreationView(
                    preselectedFormula: preselectedFormula,
                    shouldPreselectFirstAvailable: shouldPreselectFirstAvailable
                )
            }
        }
        .sheet(isPresented: $showingArchiveSheet) {
            NavigationStack {
                BakesArchiveView(
                    allBakes: bakes,
                    onClose: { showingArchiveSheet = false }
                )
            }
        }
    }

    private func archive(_ bake: Bake) {
        let bakeID = bake.id
        bake.isCancelled = true
        try? modelContext.save()
        
        let ctx = modelContext
        let notificationService = environment.notificationService
        Task { @MainActor in
            await notificationService.syncNotifications(forBake: bakeID, in: ctx)
        }
    }

    private var emptyStateActionTitle: String {
        // Check if there have ever been any bakes (including completed/cancelled)
        let allBakesQuery = FetchDescriptor<Bake>()
        let allBakesCount = (try? modelContext.fetch(allBakesQuery).count) ?? 0
        return allBakesCount == 0 ? "Crea il tuo primo bake" : "Nuovo Bake"
    }
}

private struct BakesArchiveView: View {
    enum ArchiveFilter: String, CaseIterable, Identifiable {
        case all = "Tutti"
        case completed = "Completati"
        case cancelled = "Annullati"

        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var modelContext

    let allBakes: [Bake]
    let onClose: () -> Void

    @State private var filter: ArchiveFilter = .all
    @State private var selectedIDs: Set<UUID> = []

    private var hasAnyArchived: Bool {
        allBakes.contains { bake in
            switch bake.derivedStatus {
            case .completed, .cancelled:
                return true
            default:
                return false
            }
        }
    }

    private var archivedBakes: [Bake] {
        allBakes.filter { bake in
            switch bake.derivedStatus {
            case .completed:
                return filter == .all || filter == .completed
            case .cancelled:
                return filter == .all || filter == .cancelled
            default:
                return false
            }
        }
        .sorted { $0.targetBakeDateTime > $1.targetBakeDateTime }
    }

    var body: some View {
        List {
            if hasAnyArchived == false {
                Section {
                    EmptyStateView(
                        title: "Nessun bake in archivio",
                        message: "Qui trovi gli impasti completati o annullati. Archivia un bake dalla lista principale per vederlo qui.",
                        actionTitle: "Chiudi",
                        action: onClose
                    )
                }
            } else {
                Section {
                    Picker("Filtro", selection: $filter) {
                        ForEach(ArchiveFilter.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if archivedBakes.isEmpty {
                    Section {
                        Text("Nessun bake per questo filtro.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                } else {
                    Section {
                        ForEach(archivedBakes) { bake in
                        let isSelected = selectedIDs.contains(bake.id)

                        SectionCard(emphasis: .subtle) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(bake.name)
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    Text(DateFormattingService.dayTime(bake.targetBakeDateTime))
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted)
                                }
                                Spacer()

                                VStack(alignment: .trailing, spacing: 6) {
                                    let isCompleted = bake.derivedStatus == .completed
                                    let badgeText = isCompleted ? "Completato" : "Annullato"
                                    // In archivio vogliamo un verde evidente per i completati,
                                    // quindi usiamo il tono .running al posto di .done (che è neutro).
                                    let badgeTone: StateBadge.Tone = isCompleted ? .running : .danger

                                    StateBadge(text: badgeText, tone: badgeTone)

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.Status.doneForeground)
                                    }
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                selectedIDs.remove(bake.id)
                            } else {
                                selectedIDs.insert(bake.id)
                            }
                        }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        delete(bakes: [bake])
                                    }
                                } label: {
                                    Label("Elimina", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Archivio impasti")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let visibleIDs = Set(archivedBakes.map(\.id))
                let allVisibleSelected = !visibleIDs.isEmpty && visibleIDs.isSubset(of: selectedIDs)

                Button(allVisibleSelected ? "Deseleziona" : "Seleziona") {

                    if allVisibleSelected {
                        // Se tutto ciò che vedi è già selezionato, deseleziona tutto
                        selectedIDs.subtract(visibleIDs)
                    } else {
                        // Altrimenti seleziona tutto ciò che è in questa vista (rispettando il filtro)
                        selectedIDs.formUnion(visibleIDs)
                    }
                }

                Spacer()

                Button(role: .destructive) {
                    let toDelete = archivedBakes.filter { selectedIDs.contains($0.id) }
                    guard toDelete.isEmpty == false else { return }

                    withAnimation {
                        delete(bakes: toDelete)
                        selectedIDs.removeAll()
                    }
                } label: {
                    Text("Elimina selezionati")
                }
                .disabled(selectedIDs.isEmpty)
            }
        }
    }

    private func delete(bakes: [Bake]) {
        for bake in bakes {
            modelContext.delete(bake)
        }
        try? modelContext.save()
    }
}


struct FormulaStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(Theme.muted)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct NumericField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        LabeledContent(title) {
            TextField("", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview("Bakes") {
    NavigationStack {
        BakesView()
    }
    .environmentObject(AppRouter())
    .modelContainer(ModelContainerFactory.makePreviewContainer())
}
