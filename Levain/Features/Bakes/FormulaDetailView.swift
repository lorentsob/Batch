import SwiftData
import SwiftUI

@MainActor
struct FormulaDetailView: View {
    let formulaID: UUID

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @Query private var results: [RecipeFormula]

    @State private var showingBakeEditor = false
    @State private var showingFormulaEditor = false
    @State private var showingRestoreConfirm = false
    @State private var detailRefreshToken = 0
    @State private var ingredientSections: [IngredientSection] = []
    @State private var procedureSections: [ProcedureSection] = []

    init(formulaID: UUID) {
        self.formulaID = formulaID
        _results = Query(filter: #Predicate<RecipeFormula> { $0.id == formulaID })
    }

    /// Backward-compat init — extracts the id from a passed model object.
    init(formula: RecipeFormula) {
        self.init(formulaID: formula.id)
    }

    private var formula: RecipeFormula? { results.first }

    private let metricColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    // MARK: - Parsed data

    private struct IngredientSection: Decodable {
        let title: String
        let items: [String]
    }

    private struct ProcedureSection: Decodable {
        let title: String
        let content: String
    }

    private static let decoder = JSONDecoder()

    private func decodeSections<T: Decodable>(_ type: T.Type, from raw: String?) -> T? {
        guard let raw, !raw.isEmpty,
              let data = raw.data(using: .utf8)
        else { return nil }
        return try? Self.decoder.decode(T.self, from: data)
    }

    private func safeInt(_ val: Double) -> Int {
        guard val.isFinite else { return 0 }
        let rounded = val.rounded()
        guard rounded >= -1e15, rounded <= 1e15 else { return 0 }
        return Int(rounded)
    }

    private var glossaryIndex: KnowledgeGlossaryIndex {
        environment.knowledgeLibrary.glossaryIndex
    }

    var body: some View {
        Group {
            if let formula {
                formulaContent(formula)
            } else {
                ContentUnavailableView("Ricetta non trovata", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("Ricetta")
        .tint(Theme.Control.primaryFill)
        .task {
            environment.knowledgeLibrary.loadIfNeeded()
        }
    }

    // MARK: - Main content (only called when formula is non-nil)

    @ViewBuilder
    private func formulaContent(_ formula: RecipeFormula) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard(formula)
                bakersCard(formula)

                if !ingredientSections.isEmpty {
                    ingredientsCard(ingredientSections)
                }

                preparationCard(formula)

                if formula.isSystemFormula && formula.isModifiedFromDefault {
                    restoreButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .id(detailRefreshToken)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingFormulaEditor = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(formula: formula, onSaved: {})
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeCreationView(preselectedFormula: formula)
            }
        }
        .confirmationDialog(
            "Ripristina la ricetta ai valori originali?",
            isPresented: $showingRestoreConfirm,
            titleVisibility: .visible
        ) {
            Button("Ripristina", role: .destructive) {
                restoreToDefault(formula)
                detailRefreshToken += 1
            }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Tutte le modifiche alla ricetta verranno perse.")
        }
        .onChange(of: showingFormulaEditor) { wasShowing, isShowing in
            if wasShowing && !isShowing {
                detailRefreshToken += 1
            }
        }
        .task(id: formula.ingredients) {
            ingredientSections = decodeSections([IngredientSection].self, from: formula.ingredients) ?? []
        }
        .task(id: formula.procedure) {
            procedureSections = (decodeSections([ProcedureSection].self, from: formula.procedure) ?? [])
                .filter { !$0.content.isEmpty }
        }
    }

    // MARK: - Header card

    @ViewBuilder
    private func headerCard(_ formula: RecipeFormula) -> some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 12) {
                Text(formula.name)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.ink)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        StateBadge(text: formula.type.title, tone: .info)
                        StateBadge(text: formula.yeastType.title, tone: .info)
                        StateBadge(text: "\(safeInt(formula.hydrationPercent))% idratazione", tone: .count)
                        StateBadge(
                            text: formula.yeastType == .sourdough
                                ? "\(safeInt(formula.inoculationPercent))% inoculo"
                                : "\(String(format: "%.1f", formula.inoculationPercent))% lievito",
                            tone: .schedule
                        )
                    }
                }

                Button {
                    showingBakeEditor = true
                } label: {
                    Label("Nuovo impasto", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionButtonStyle())
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Baker's math card

    @ViewBuilder
    private func bakersCard(_ formula: RecipeFormula) -> some View {
        SectionCard {
            Text("Baker's math")
                .font(.headline)
                .foregroundStyle(Theme.ink)
            LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                MetricChip(label: "Farina totale", value: "\(safeInt(formula.totalFlourWeight)) g", tone: .info)
                MetricChip(label: "Acqua totale", value: "\(safeInt(formula.totalWaterWeight)) g", tone: .info)
                MetricChip(label: "Sale", value: "\(safeInt(formula.saltWeight)) g", tone: .schedule)
                MetricChip(label: "Peso impasto", value: "\(safeInt(formula.totalDoughWeight)) g", tone: .count)
                MetricChip(label: "Porzioni", value: "\(formula.servings)", tone: .count)
                MetricChip(label: "Sale", value: "\(safeInt(formula.saltPercent))%", tone: .schedule)
            }

            let flours = formula.selectedFlours
            if !flours.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    StateBadge(text: "Mix farine", tone: .schedule)
                    LazyVGrid(columns: metricColumns, alignment: .leading, spacing: 8) {
                        ForEach(flours) { flour in
                            MetricChip(
                                label: flour.shortDisplayName,
                                value: "\(safeInt(flour.percentage))%",
                                tone: .schedule
                            )
                        }
                    }
                }
            }
            if !formula.notes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    StateBadge(text: "Note", tone: .info)
                    Text(formula.notes)
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }
            }
        }
    }

    // MARK: - Ingredients card

    @ViewBuilder
    private func ingredientsCard(_ sections: [IngredientSection]) -> some View {
        SectionCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ingredienti")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)

                ForEach(sections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        if !section.title.isEmpty {
                            Text(section.title.uppercased())
                                .font(.caption.weight(.semibold))
                                .tracking(0.6)
                                .foregroundStyle(Theme.Control.primaryFill)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
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
        }
    }

    // MARK: - Preparation card

    @ViewBuilder
    private func preparationCard(_ formula: RecipeFormula) -> some View {
        SectionCard {
            Text("Preparazione")
                .font(.headline)
                .foregroundStyle(Theme.ink)

            if formula.defaultSteps.isEmpty, !procedureSections.isEmpty {
                ForEach(procedureSections, id: \.title) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        if !section.title.isEmpty {
                            glossarySectionTitle(section.title)
                        }

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
                    .padding(.vertical, 6)
                }
            } else {
                ForEach(formula.defaultSteps) { step in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            GlossaryLinkedText(
                                text: step.name,
                                glossaryIndex: glossaryIndex,
                                maxLinks: 1,
                                onOpenKnowledge: router.openKnowledge
                            )
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.ink)
                            Spacer()
                            StateBadge(
                                text: DateFormattingService.duration(minutes: step.durationMinutes),
                                tone: .schedule
                            )
                        }
                        if !step.details.isEmpty {
                            GlossaryLinkedText(
                                text: step.details,
                                glossaryIndex: glossaryIndex,
                                maxLinks: 2,
                                onOpenKnowledge: router.openKnowledge
                            )
                                .font(.footnote)
                                .foregroundStyle(Theme.muted)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    // MARK: - Restore button

    private var restoreButton: some View {
        Button(role: .destructive) {
            showingRestoreConfirm = true
        } label: {
            Label("Ripristina default", systemImage: "arrow.counterclockwise")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.red)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.red.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func glossarySectionTitle(_ title: String) -> some View {
        GlossaryLinkedText(
            text: title.uppercased(),
            glossaryIndex: glossaryIndex,
            maxLinks: 1,
            onOpenKnowledge: router.openKnowledge
        )
        .font(.caption.weight(.semibold))
        .tracking(0.6)
        .foregroundStyle(Theme.Control.primaryFill)
    }

    // MARK: - Actions

    private func restoreToDefault(_ formula: RecipeFormula) {
        guard let original = SystemFormulaLoader.formula(id: formula.id) else { return }
        formula.name = original.name
        formula.type = original.type
        formula.totalFlourWeight = original.totalFlourWeight
        formula.totalWaterWeight = original.totalWaterWeight
        formula.saltWeight = original.saltWeight
        formula.inoculationPercent = original.inoculationPercent
        formula.servings = original.servings
        formula.notes = original.notes
        formula.flourMix = original.flourMix
        formula.yeastType = original.yeastType
        formula.selectedFlours = original.flours
        formula.defaultSteps = original.defaultSteps
        formula.ingredients = original.ingredients
        formula.procedure = original.procedure
        formula.bakingInstructions = original.bakingInstructions
        formula.isModifiedFromDefault = false
        formula.recalculateDerivedValues()
        try? modelContext.save()
    }
}
