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
                    Text("Tutte le ricette disponibili")
                        .foregroundStyle(Theme.muted)
                    HStack(spacing: 8) {
                        StateBadge(text: "\(formulas.count) ricette", tone: .count)
                        let userCount = formulas.filter { !$0.isSystemFormula }.count
                        if userCount > 0 {
                            StateBadge(text: "\(userCount) personali", tone: .schedule)
                        }
                    }
                }

                if formulas.isEmpty {
                    EmptyStateView(
                        title: "Nessuna ricetta",
                        message: "Le ricette di sistema appariranno qui al prossimo avvio.",
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
                                            HStack(spacing: 6) {
                                                Text(formula.name)
                                                    .font(.headline)
                                                    .foregroundStyle(Theme.ink)
                                                if !formula.isSystemFormula {
                                                    Text("Mia ricetta")
                                                        .font(.caption2.weight(.semibold))
                                                        .foregroundStyle(Theme.Control.primaryFill)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(
                                                            Capsule()
                                                                .fill(Theme.Control.primaryFill.opacity(0.12))
                                                        )
                                                } else if formula.isModifiedFromDefault {
                                                    Text("Modificata")
                                                        .font(.caption2.weight(.semibold))
                                                        .foregroundStyle(Theme.muted)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(
                                                            Capsule()
                                                                .fill(Theme.muted.opacity(0.10))
                                                        )
                                                }
                                            }
                                            Text(formula.type.title)
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.muted)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Theme.muted)
                                    }

                                    LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                                        MetricChip(label: "Lievito", value: formula.yeastType.shortTitle, tone: .info)
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
                FormulaEditorView(formula: editingFormula)
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
