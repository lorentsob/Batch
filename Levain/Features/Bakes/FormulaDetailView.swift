import SwiftData
import SwiftUI

struct FormulaDetailView: View {
    let formula: RecipeFormula

    @State private var showingBakeEditor = false

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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard(emphasis: .tinted) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(formula.name)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Theme.ink)
                        HStack(spacing: 12) {
                            StateBadge(text: formula.type.title, tone: .info)
                            StateBadge(text: "\(Int(formula.hydrationPercent.rounded()))% idratazione", tone: .count)
                            StateBadge(text: "\(Int(formula.inoculationPercent.rounded()))% inoculo", tone: .schedule)
                        }
                    }
                }

                SectionCard {
                    Text("Baker's math")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                   LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                        MetricChip(label: "Farina totale", value: "\(Int(formula.totalFlourWeight)) g", tone: .info)
                        MetricChip(label: "Acqua totale", value: "\(Int(formula.totalWaterWeight)) g", tone: .info)
                        MetricChip(label: "Sale", value: "\(Int(formula.saltWeight)) g", tone: .schedule)
                        MetricChip(label: "Peso impasto", value: "\(Int(formula.totalDoughWeight.rounded())) g", tone: .count)
                        MetricChip(label: "Porzioni", value: "\(formula.servings)", tone: .count)
                        MetricChip(label: "Sale %", value: "\(Int(formula.saltPercent.rounded()))%", tone: .schedule)
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
                    Text("Fasi di default")
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
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeCreationView(preselectedFormula: formula)
            }
        }
    }
}
