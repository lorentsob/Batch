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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Impasti e formule")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("Qui gestisci le formule riutilizzabili e i bake in corso o pianificati.")
                        .foregroundStyle(Theme.muted)
                    HStack(spacing: 12) {
                        StateBadge(text: "\(bakes.count) bake")
                        StateBadge(text: "\(formulas.count) formule")
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Bake")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            preselectedFormula = formulas.first
                            showingBakeEditor = true
                        } label: {
                            Label("Nuovo bake", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                        .tint(Theme.accent)
                        .disabled(formulas.isEmpty)
                    }

                    if bakes.isEmpty {
                        EmptyStateView(
                            title: "Nessun bake pianificato",
                            message: "Crea prima una formula, poi genera un bake con la schedulazione backward.",
                            actionTitle: "Nuova formula"
                        ) {
                            editingFormula = nil
                            showingFormulaEditor = true
                        }
                    } else {
                        ForEach(bakes) { bake in
                            NavigationLink(value: BakesRoute.bake(bake.id)) {
                                SectionCard {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(bake.name)
                                                .font(.headline)
                                                .foregroundStyle(Theme.ink)
                                            Text("\(bake.type.title) · target \(DateFormattingService.dayTime(bake.targetBakeDateTime))")
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.muted)
                                            if let step = bake.activeStep {
                                                Text("Prossimo step: \(step.displayName)")
                                                    .font(.footnote)
                                                    .foregroundStyle(Theme.muted)
                                            }
                                        }
                                        Spacer()
                                        StateBadge(text: bake.derivedStatus.title)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Formule")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            editingFormula = nil
                            showingFormulaEditor = true
                        } label: {
                            Label("Nuova formula", systemImage: "square.and.pencil")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.accent)
                    }

                    if formulas.isEmpty {
                        EmptyStateView(
                            title: "Nessuna formula salvata",
                            message: "Le formule sono la base riutilizzabile da cui generare i bake.",
                            actionTitle: "Crea formula"
                        ) {
                            editingFormula = nil
                            showingFormulaEditor = true
                        }
                    } else {
                        ForEach(formulas) { formula in
                            NavigationLink(value: BakesRoute.formula(formula.id)) {
                                SectionCard {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(formula.name)
                                                .font(.headline)
                                                .foregroundStyle(Theme.ink)
                                            Text("\(formula.type.title) · \(Int(formula.hydrationPercent.rounded()))% idratazione")
                                                .font(.subheadline)
                                                .foregroundStyle(Theme.muted)
                                            Text("\(formula.defaultSteps.count) step di default")
                                                .font(.footnote)
                                                .foregroundStyle(Theme.muted)
                                        }
                                        Spacer()
                                        StateBadge(text: "\(formula.servings) pezz.")
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Modifica") {
                                    editingFormula = formula
                                    showingFormulaEditor = true
                                }
                                Button("Duplica") {
                                    editingFormula = formula.duplicate()
                                    showingFormulaEditor = true
                                }
                                Button("Nuovo bake") {
                                    preselectedFormula = formula
                                    showingBakeEditor = true
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Impasti")
        .accessibilityIdentifier("BakesScrollView")
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: editingFormula)
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            BakeCreationView(preselectedFormula: preselectedFormula)
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
        TextField(title, value: $value, format: .number)
            .keyboardType(.decimalPad)
    }
}
