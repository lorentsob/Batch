import SwiftData
import SwiftUI

struct FormulaListView: View {
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Ricette")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Template e formule disponibili per creare nuovi bake.")
                        .foregroundStyle(Theme.muted)
                    StateBadge(text: "\(formulas.count) ricette")
                }

                if formulas.isEmpty {
                    EmptyStateView(
                        title: "Nessuna ricetta",
                        message: "Crea una formula per iniziare i tuoi impasti.",
                        actionTitle: "Nuova ricetta"
                    ) {
                        editingFormula = nil
                        showingFormulaEditor = true
                    }
                } else {
                    ForEach(formulas) { formula in
                        NavigationLink(value: BakesRoute.formula(formula.id)) {
                            SectionCard {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(formula.name)
                                            .font(.headline)
                                            .foregroundStyle(Theme.ink)
                                        Text(formula.type.title)
                                            .font(.subheadline)
                                            .foregroundStyle(Theme.muted)
                                        Text("\(Int(formula.hydrationPercent.rounded()))% idratazione · \(formula.servings) porzioni")
                                            .font(.footnote)
                                            .foregroundStyle(Theme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Theme.muted)
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
