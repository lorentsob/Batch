import SwiftData
import SwiftUI

struct FormulaListView: View {
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?

    private let metricColumns = [
        GridItem(.adaptive(minimum: 118), spacing: 8)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard(emphasis: .tinted) {
                    Text("Ricette")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text("Le tue ricette salvate")
                        .foregroundStyle(Theme.muted)
                    StateBadge(text: "\(formulas.count) ricette", tone: .count)
                }

                if formulas.isEmpty {
                    EmptyStateView(
                        title: "Nessuna ricetta",
                        message: "Crea una ricetta per iniziare i tuoi impasti.",
                        actionTitle: "Nuova ricetta"
                    ) {
                        editingFormula = nil
                        showingFormulaEditor = true
                    }
                } else {
                    ForEach(formulas) { formula in
                        NavigationLink(value: FermentationsRoute.formula(formula.id)) {
                            SectionCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(formula.name)
                                                .font(.headline)
                                                .foregroundStyle(Theme.ink)
                                            Text(formula.type.title)
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.muted)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Theme.muted)
                                    }

                                    LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                                        MetricChip(label: "Idratazione", value: "\(Int(formula.hydrationPercent.rounded()))%", tone: .info)
                                        MetricChip(label: "Porzioni", value: "\(formula.servings)", tone: .count)
                                    }
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
        .navigationTitle("Ricette")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Nuova") {
                    editingFormula = nil
                    showingFormulaEditor = true
                }
            }
        }
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: editingFormula, onSaved: {})
            }
        }
    }
}

#Preview("Formula List") {
    NavigationStack {
        FormulaListView()
    }
    .environmentObject(AppRouter())
    .modelContainer(ModelContainerFactory.makePreviewContainer())
}
