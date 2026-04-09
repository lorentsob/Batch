import SwiftData
import SwiftUI

struct FormulaListView: View {
    @Environment(\.modelContext) private var modelContext


    @Query(sort: \RecipeFormula.name) private var allFormulas: [RecipeFormula]

    @State private var showingFormulaEditor = false
    @State private var editingFormula: RecipeFormula?
    @State private var showingArchiveSheet = false
     @State private var formulaListRefreshToken = 0

    private let metricColumns = [
        GridItem(.adaptive(minimum: 118), spacing: 8)
    ]

    private var activeFormulas: [RecipeFormula] {
        allFormulas.filter { !$0.isArchived }
    }

    private var archivedFormulas: [RecipeFormula] {
        allFormulas.filter { $0.isArchived }
    }

    var body: some View {
        List {
            Group {
                SectionCard(emphasis: .tinted) {
                    ScreenTitleBlock(
                        title: "Ricette",
                        subtitle: "Consulta le ricette e creane di nuove"
                    )
                    HStack(spacing: 8) {
                        StateBadge(text: "\(activeFormulas.count) ricette", tone: .count)
                        let userCount = activeFormulas.filter { !$0.isSystemFormula }.count
                        if userCount > 0 {
                            StateBadge(text: "\(userCount) personali", tone: .schedule)
                        }
                    }

                    Button {
                        editingFormula = nil
                        showingFormulaEditor = true
                    } label: {
                        Label("Nuova ricetta", systemImage: "plus")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .padding(.top, Theme.Spacing.xxs)
                }
                .listRowInsets(.levainListRow(top: Theme.Spacing.sm, bottom: Theme.Spacing.md))


                if activeFormulas.isEmpty {
                    EmptyStateView(
                        title: "Nessuna ricetta",
                        message: "Le ricette di sistema appariranno al prossimo avvio."
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.levainListRow(bottom: Theme.Spacing.xs))
                } else {
                    ForEach(activeFormulas) { formula in
                        ZStack {
                            NavigationLink(value: FermentationsRoute.formula(formula.id)) {
                                EmptyView()
                            }
                            .opacity(0)

                            SectionCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(spacing: 6) {
                                                Text(formula.name)
                                                    .font(.headline)
                                                    .foregroundStyle(Theme.ink)
                                                if !formula.isSystemFormula {
                                                    formulaBadge(text: "Mia ricetta", color: Theme.Control.primaryFill)
                                                } else if formula.isModifiedFromDefault {
                                                    formulaBadge(text: "Modificata", color: Theme.muted)
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                withAnimation {
                                    archive(formula)
                                }
                            } label: {
                                Label("Archivia", systemImage: "archivebox")
                            }
                            .tint(.orange)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.levainListRow(bottom: Theme.Spacing.xs))
                    }
                }

                if !archivedFormulas.isEmpty {
                    Button {
                        showingArchiveSheet = true
                    } label: {
                        HStack {
                            Text("Archivio ricette")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            StateBadge(text: "\(archivedFormulas.count)", tone: .count)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Theme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.levainListRow(top: Theme.Spacing.xs, bottom: Theme.Spacing.xs))
                }

                Color.clear.frame(height: 80)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .levainListSurface()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        .accessibilityIdentifier("FormulaListView")
        .sheet(isPresented: $showingFormulaEditor) {
            NavigationStack {
                FormulaEditorView(
                    formula: editingFormula,
                    onSaved: {
                         formulaListRefreshToken += 1
                      }
                  )
            }
        }
        .sheet(isPresented: $showingArchiveSheet) {
            NavigationStack {
                FormulaArchiveView(
                    archivedFormulas: archivedFormulas,
                    onClose: { showingArchiveSheet = false }
                )
            }
        }
    }

    private func archive(_ formula: RecipeFormula) {
        formula.isArchived = true
        try? modelContext.save()
    }

    @ViewBuilder
    private func formulaBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}

// MARK: - Archivio ricette

private struct FormulaArchiveView: View {
    @Environment(\.modelContext) private var modelContext

    let archivedFormulas: [RecipeFormula]
    let onClose: () -> Void

    @State private var selectedIDs: Set<UUID> = []

    private var sorted: [RecipeFormula] {
        archivedFormulas.sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            if sorted.isEmpty {
                Section {
                    EmptyStateView(
                        title: "Archivio vuoto",
                        message: "Scorri a sinistra su una ricetta per archiviarla.",
                        actionTitle: "Chiudi",
                        action: onClose
                    )
                }
            } else {
                Section {
                    ForEach(sorted) { formula in
                        let isSelected = selectedIDs.contains(formula.id)

                        SectionCard(emphasis: .subtle) {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(formula.name)
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                    Text(formula.type.title)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.muted)
                                    HStack(spacing: 6) {
                                        if !formula.isSystemFormula {
                                            StateBadge(text: "Mia ricetta", tone: .schedule)
                                        }
                                        StateBadge(text: "\(Int(formula.hydrationPercent.rounded()))% idr.", tone: .info)
                                    }
                                }
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Theme.Status.doneForeground)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                selectedIDs.remove(formula.id)
                            } else {
                                selectedIDs.insert(formula.id)
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                withAnimation { restore(formula) }
                            } label: {
                                Label("Ripristina", systemImage: "arrow.uturn.left")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation { delete([formula]) }
                            } label: {
                                Label("Elimina", systemImage: "trash")
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .levainListSurface()
        .navigationTitle("Archivio ricette")
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                let allIDs = Set(sorted.map(\.id))
                let allSelected = !allIDs.isEmpty && allIDs.isSubset(of: selectedIDs)

                Button(allSelected ? "Deseleziona" : "Seleziona tutto") {
                    if allSelected {
                        selectedIDs.subtract(allIDs)
                    } else {
                        selectedIDs.formUnion(allIDs)
                    }
                }

                Spacer()

                Button(role: .destructive) {
                    let toDelete = sorted.filter { selectedIDs.contains($0.id) }
                    guard !toDelete.isEmpty else { return }
                    withAnimation {
                        delete(toDelete)
                        selectedIDs.removeAll()
                    }
                } label: {
                    Text("Elimina selezionati")
                }
                .disabled(selectedIDs.isEmpty)
            }
        }
    }

    private func restore(_ formula: RecipeFormula) {
        formula.isArchived = false
        try? modelContext.save()
    }

    private func delete(_ formulas: [RecipeFormula]) {
        for f in formulas { modelContext.delete(f) }
        try? modelContext.save()
    }
}

#Preview("Formula List") {
    NavigationStack {
        FormulaListView()
    }
    .environmentObject(AppRouter())
    .modelContainer(ModelContainerFactory.makePreviewContainer())
}
