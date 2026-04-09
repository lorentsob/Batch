import SwiftData
import SwiftUI

struct FormulaDetailView: View {
    let formula: RecipeFormula

    @State private var showingBakeEditor = false
    @State private var showingFormulaEditor = false

    private let metricColumns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]

    // MARK: - Parsed data (same structure as BakeIngredientsView)

    private struct IngredientSection: Decodable {
        let title: String
        let items: [String]
    }

    private struct ProcedureSection: Decodable {
        let title: String
        let content: String
    }

    private var ingredientSections: [IngredientSection] {
        guard let raw = formula.ingredients, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let sections = try? JSONDecoder().decode([IngredientSection].self, from: data)
        else { return [] }
        return sections
    }

    private var procedureSections: [ProcedureSection] {
        guard let raw = formula.procedure, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let sections = try? JSONDecoder().decode([ProcedureSection].self, from: data)
        else { return [] }
        return sections
    }

    var body: some View {
        // Defensive guards for potentially corrupted legacy data (NaN / non-finite values)
        let safeHydrationPercent = formula.hydrationPercent.isFinite ? Int(formula.hydrationPercent.rounded()) : 0
        let safeInoculationPercent = formula.inoculationPercent.isFinite ? Int(formula.inoculationPercent.rounded()) : 0
        let safeSaltPercent = formula.saltPercent.isFinite ? Int(formula.saltPercent.rounded()) : 0
        let safeTotalFlourWeight = formula.totalFlourWeight.isFinite ? Int(formula.totalFlourWeight.rounded()) : 0
        let safeTotalWaterWeight = formula.totalWaterWeight.isFinite ? Int(formula.totalWaterWeight.rounded()) : 0
        let safeSaltWeight = formula.saltWeight.isFinite ? Int(formula.saltWeight.rounded()) : 0
        let safeTotalDoughWeight = formula.totalDoughWeight.isFinite ? Int(formula.totalDoughWeight.rounded()) : 0

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard(emphasis: .surface) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(formula.name)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Theme.ink)
                        HStack(spacing: 12) {
                            StateBadge(text: formula.type.title, tone: .info)
                            StateBadge(text: "\(safeHydrationPercent)% idratazione", tone: .count)
                            StateBadge(text: "\(safeInoculationPercent)% inoculo", tone: .schedule)
                        }
                    }
                }

                SectionCard {
                    Text("Baker's math")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                   LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                        MetricChip(label: "Farina totale", value: "\(safeTotalFlourWeight) g", tone: .info)
                        MetricChip(label: "Acqua totale", value: "\(safeTotalWaterWeight) g", tone: .info)
                        MetricChip(label: "Sale", value: "\(safeSaltWeight) g", tone: .schedule)
                        MetricChip(label: "Peso impasto", value: "\(safeTotalDoughWeight) g", tone: .count)
                        MetricChip(label: "Porzioni", value: "\(formula.servings)", tone: .count)
                        MetricChip(label: "Sale", value: "\(safeSaltPercent)%", tone: .schedule)
                    }

                    if formula.selectedFlours.isEmpty == false {
                        VStack(alignment: .leading, spacing: 8) {
                            StateBadge(text: "Mix farine", tone: .schedule)
                            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                                ForEach(formula.selectedFlours) { flour in
                                    MetricChip(
                                        label: flour.shortDisplayName,
                                        value: "\(Int(flour.percentage.rounded()))%",
                                        tone: .schedule
                                    )
                                }
                            }
                        }
                    }
                    if formula.notes.isEmpty == false {
                        VStack(alignment: .leading, spacing: 6) {
                            StateBadge(text: "Note", tone: .info)
                            Text(formula.notes)
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }

                SectionCard {
                    Text("Preparazione")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    ForEach(formula.defaultSteps) { step in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(step.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.ink)
                                Spacer()
                                StateBadge(
                                    text: DateFormattingService.duration(minutes: step.durationMinutes),
                                    tone: .schedule
                                )
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

                // Azione di modifica formula centrata sotto la preparazione
                Button {
                    showingFormulaEditor = true
                } label: {
                    Text("Modifica ricetta")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Theme.Control.secondaryForeground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Theme.Surface.card)
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Theme.Control.secondaryBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Ricetta")
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Nuovo bake") {
                    showingBakeEditor = true
                }
            }
        }
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: formula)
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeCreationView(preselectedFormula: formula)
            }
        }
    }
}
