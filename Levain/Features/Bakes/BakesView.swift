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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard {
                    Text("Impasti")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(Theme.ink)
                    Text("L'hub operativo per i tuoi bake in corso o pianificati.")
                        .foregroundStyle(Theme.muted)
                    HStack(spacing: 12) {
                        StateBadge(text: "\(bakes.count) bake")
                        StateBadge(text: "\(formulas.count) ricette")
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
                    }

                    if bakes.isEmpty {
                        EmptyStateView(
                            title: "Nessun impasto",
                            message: "Crea prima una ricetta, poi genera un bake.",
                            actionTitle: "Nuova ricetta"
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
                        Text("Ricette")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        NavigationLink(value: BakesRoute.formulaList) {
                            Text("Vedi tutte")
                                .font(.subheadline)
                                .foregroundStyle(Theme.accent)
                        }
                    }

                    SectionCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gestione Ricette")
                                    .font(.headline)
                                Text("Configura i tuoi template e basi.")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Theme.muted)
                        }
                    }
                    .onTapGesture {
                        router.bakesPath.append(.formulaList)
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
        LabeledContent(title) {
            TextField("", value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}
