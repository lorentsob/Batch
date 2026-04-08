import SwiftUI

// MARK: - Data model for structured ingredient sections

private struct IngredientSection: Decodable {
    let title: String
    let items: [String]
}

private struct ProcedureSection: Decodable {
    let title: String
    let content: String
}

// MARK: - Main modal view

/// Modale con i dettagli della ricetta: baker's math, ingredienti, procedimento e cottura
struct BakeIngredientsView: View {
    let bake: Bake

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    private let metricColumns = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]

    // MARK: Parsed data

    private var ingredientSections: [IngredientSection] {
        guard let raw = bake.ingredients, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let sections = try? JSONDecoder().decode([IngredientSection].self, from: data)
        else { return [] }
        return sections
    }

    private var procedureSections: [ProcedureSection] {
        guard let raw = bake.procedure, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let sections = try? JSONDecoder().decode([ProcedureSection].self, from: data)
        else { return [] }
        return sections
    }

    private var bakingSteps: [String] {
        guard let raw = bake.bakingInstructions, !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let steps = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return steps
    }

    private var glossaryIndex: KnowledgeGlossaryIndex {
        environment.knowledgeLibrary.glossaryIndex
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {

                // ── Baker's math ────────────────────────────────────────────
                SectionCard {
                    Text("Baker's math")
                        .font(.headline)
                        .foregroundStyle(Theme.ink)

                    LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                        MetricChip(label: "Farina", value: "\(Int(bake.totalFlourWeight)) g", tone: .info)
                        MetricChip(label: "Acqua", value: "\(Int(bake.totalWaterWeight)) g", tone: .info)
                        MetricChip(label: "Idratazione", value: "\(Int(bake.hydrationPercent))%", tone: .schedule)
                        MetricChip(label: "Porzioni", value: "\(bake.servings)", tone: .count)
                        if let formula = bake.formula {
                            let saltW = Int(formula.saltWeight)
                            if saltW > 0 {
                                MetricChip(label: "Sale", value: "\(saltW) g", tone: .schedule)
                            }
                            let inocW = Int(bake.totalFlourWeight * formula.inoculationPercent / 100)
                            MetricChip(label: "Lievito madre", value: "~\(inocW) g", tone: .info)
                        } else {
                            let inocW = Int(bake.totalFlourWeight * bake.inoculationPercent / 100)
                            if inocW > 0 {
                                MetricChip(label: "Lievito madre", value: "~\(inocW) g", tone: .info)
                            }
                        }
                    }

                    if let formula = bake.formula, !formula.flourMix.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            StateBadge(text: "Mix farine", tone: .schedule)
                            Text(formula.flourMix)
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }

                // ── Ingredienti strutturati ──────────────────────────────────
                if !ingredientSections.isEmpty {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingredienti")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)

                            ForEach(ingredientSections, id: \.title) { section in
                                IngredientSectionView(section: section)
                            }
                        }
                    }
                }

                // ── Procedimento ─────────────────────────────────────────────
                if !procedureSections.isEmpty {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Dettagli")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)

                            ForEach(procedureSections, id: \.title) { section in
                                VStack(alignment: .leading, spacing: 8) {
                                    GlossaryLinkedText(
                                        text: section.title.uppercased(),
                                        glossaryIndex: glossaryIndex,
                                        maxLinks: 1,
                                        onOpenKnowledge: router.openKnowledge
                                    )
                                    .font(.caption.weight(.semibold))
                                    .tracking(0.6)
                                    .foregroundStyle(Theme.Control.primaryFill)

                                    GlossaryLinkedText(
                                        text: section.content,
                                        glossaryIndex: glossaryIndex,
                                        maxLinks: 2,
                                        onOpenKnowledge: router.openKnowledge
                                    )
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }

                // ── Cottura ──────────────────────────────────────────────────
                if !bakingSteps.isEmpty {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Cottura")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)

                            ForEach(Array(bakingSteps.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(idx + 1)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Theme.Control.primaryFill)
                                        .frame(width: 20, height: 20)
                                        .background(
                                            Circle()
                                                .fill(Theme.Control.primaryFill.opacity(0.12))
                                        )
                                    Text(step)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
            }
                .frame(width: geometry.size.width, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
        }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollClipDisabled(false)
        }
        .contentMargins(.bottom, 20, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Dettagli ricetta")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        .task {
            environment.knowledgeLibrary.loadIfNeeded()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Fatto") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Ingredient section row

private struct IngredientSectionView: View {
    let section: IngredientSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !section.title.isEmpty {
                Text(section.title.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(0.6)
                    .foregroundStyle(Theme.Control.primaryFill)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(section.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Theme.Control.primaryFill.opacity(0.55))
                            .frame(width: 3, height: 16)
                            .padding(.top, 3)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(Theme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }
}
