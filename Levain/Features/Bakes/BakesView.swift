import SwiftData
import SwiftUI

struct BakesView: View {
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?
    @State private var showingBakeEditor = false
    @State private var preselectedFormula: RecipeFormula?
    @State private var isRicetteExpanded = false

    private let metricColumns = [
        GridItem(.adaptive(minimum: 118), spacing: 8)
    ]

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
                        if bakes.isEmpty == false {
                            StateBadge(text: "\(bakes.count) bake", tone: .count)
                        }
                        if formulas.isEmpty == false {
                            StateBadge(text: "\(formulas.count) ricette", tone: .info)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Bake")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    if bakes.isEmpty {
                        EmptyStateView(
                            title: "Nessun bake ancora",
                            message: "Scegli una ricetta, imposta l'orario di sfornatura e Levain costruisce la timeline per te.",
                            actionTitle: "Crea il tuo primo bake"
                        ) {
                            preselectedFormula = formulas.first
                            showingBakeEditor = true
                        }
                        .accessibilityIdentifier("BakesEmptyState")
                    } else {
                        ForEach(bakes) { bake in
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
                BakeCreationView(preselectedFormula: preselectedFormula)
            }
        }
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
