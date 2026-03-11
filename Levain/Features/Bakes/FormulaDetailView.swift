import SwiftData
import SwiftUI

struct FormulaDetailView: View {
    let formula: RecipeFormula

    @State private var formulaToEdit: RecipeFormula?
    @State private var showingBakeEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text(formula.name)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text(formula.type.title)
                        .foregroundStyle(Theme.muted)

                    HStack(spacing: 12) {
                        StateBadge(text: "\(Int(formula.hydrationPercent.rounded()))% idratazione")
                        StateBadge(text: "\(Int(formula.inoculationPercent.rounded()))% inoculo")
                    }
                }

                SectionCard {
                    Text("Baker's math")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    FormulaStatRow(label: "Farina totale", value: "\(Int(formula.totalFlourWeight)) g")
                    FormulaStatRow(label: "Acqua totale", value: "\(Int(formula.totalWaterWeight)) g")
                    FormulaStatRow(label: "Sale", value: "\(Int(formula.saltWeight)) g · \(Int(formula.saltPercent.rounded()))%")
                    FormulaStatRow(label: "Peso impasto", value: "\(Int(formula.totalDoughWeight.rounded())) g")
                    FormulaStatRow(label: "Porzioni", value: "\(formula.servings)")
                    if formula.selectedFlours.isEmpty == false {
                        let floursStr = formula.selectedFlours.map { "\($0.displayName) (\(String(format: "%.0f", $0.percentage))%)" }.joined(separator: ", ")
                        FormulaStatRow(label: "Mix farine", value: floursStr)
                    }
                    if formula.notes.isEmpty == false {
                        FormulaStatRow(label: "Note", value: formula.notes)
                    }
                }

                SectionCard {
                    Text("Step di default")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    ForEach(formula.defaultSteps) { step in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(step.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                Text(DateFormattingService.duration(minutes: step.durationMinutes))
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                            }
                            if step.details.isEmpty == false {
                                Text(step.details)
                                    .font(.footnote)
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Formula")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Duplica") {
                    formulaToEdit = formula.duplicate()
                }
                Button("Modifica") {
                    formulaToEdit = formula
                }
                Button("Nuovo bake") {
                    showingBakeEditor = true
                }
            }
        }
        .sheet(item: $formulaToEdit) { formula in
            NavigationStack {
                FormulaEditorView(formula: formula)
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            BakeCreationView(preselectedFormula: formula)
        }
    }
}
