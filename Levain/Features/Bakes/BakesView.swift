import SwiftData
import SwiftUI

struct BakesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?
    @State private var showingBakeEditor = false
    @State private var preselectedFormula: RecipeFormula?
    @State private var shouldPreselectFirstAvailable = false
    @State private var isArchiveExpanded = false

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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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

                VStack(alignment: .leading, spacing: 12) {
                    Text("Bake attivi")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if activeBakes.isEmpty {
                        EmptyStateView(
                            title: "Nessun bake attivo",
                            message: "Scegli una ricetta, imposta l'orario di sfornatura e Levain costruisce la timeline per te.",
                            actionTitle: emptyStateActionTitle
                        ) {
                            preselectedFormula = formulas.first
                            shouldPreselectFirstAvailable = formulas.isEmpty
                            showingBakeEditor = true
                        }
                        .accessibilityIdentifier("BakesEmptyState")
                    } else {
                        ForEach(activeBakes) { bake in
                            NavigationLink(value: BakesRoute.bake(bake.id)) {
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
                        }
                    }
                }

                if archivedBakes.isEmpty == false {
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            withAnimation(Theme.Animation.standard) {
                                isArchiveExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Archivio")
                                    .font(.headline)
                                    .foregroundStyle(Theme.ink)
                                StateBadge(text: "\(archivedBakes.count)", tone: .count)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(isArchiveExpanded ? 90 : 0))
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        .buttonStyle(.plain)

                        if isArchiveExpanded {
                            ForEach(archivedBakes) { bake in
                                NavigationLink(value: BakesRoute.bake(bake.id)) {
                                    SectionCard(emphasis: .subtle) {
                                        HStack(alignment: .top) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(bake.name)
                                                    .font(.headline)
                                                    .foregroundStyle(Theme.ink)
                                                Text(DateFormattingService.dayTime(bake.targetBakeDateTime))
                                                    .font(.subheadline)
                                                    .foregroundStyle(Theme.muted)
                                            }
                                            Spacer()
                                            StateBadge(bakeStatus: bake.derivedStatus)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Ricette")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    SectionCard {
                        NavigationLink(value: BakesRoute.formulaList) {
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
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
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
    }

    private var emptyStateActionTitle: String {
        // Check if there have ever been any bakes (including completed/cancelled)
        let allBakesQuery = FetchDescriptor<Bake>()
        let allBakesCount = (try? modelContext.fetch(allBakesQuery).count) ?? 0
        return allBakesCount == 0 ? "Crea il tuo primo bake" : "Nuovo Bake"
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
