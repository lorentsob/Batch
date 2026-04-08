import SwiftData
import SwiftUI

@MainActor
struct FermentationsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query(filter: #Predicate<Starter> { $0.archivedAt == nil }) private var starters: [Starter]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]
    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var kefirBatches: [KefirBatch]
    @Query private var appSettingsList: [AppSettings]

    @State private var showingBakeEditor = false
    @State private var showingStarterEditor = false
    @State private var kefirEditorMode: KefirBatchEditorView.Mode?
    @State private var showingSettings = false

    private var appSettings: AppSettings? { appSettingsList.first }
    private var isBakeEnabled: Bool { appSettings?.isBakeEnabled ?? true }
    private var isStarterEnabled: Bool { appSettings?.isStarterEnabled ?? true }
    private var isKefirEnabled: Bool { appSettings?.isKefirEnabled ?? true }
    private var allFeaturesDisabled: Bool { !isBakeEnabled && !isStarterEnabled && !isKefirEnabled }

    private var activeBakes: [Bake] {
        bakes.filter { $0.derivedStatus != .cancelled && $0.derivedStatus != .completed }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if allFeaturesDisabled {
                    allDisabledEmptyState
                        .padding(.top, 40)
                } else {
                    dashboardHeader

                    LazyVGrid(columns: columns, spacing: 14) {
                        if isBakeEnabled {
                            impastiTile
                        }
                        if isStarterEnabled {
                            starterTile
                        }
                        if isKefirEnabled {
                            kefirHubTile
                        }
                        ricetteTile
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .background(Theme.Surface.app)
        .navigationTitle("I tuoi Batch")
        .navigationBarTitleDisplayMode(.large)
        .accessibilityIdentifier("FermentationsView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .accessibilityLabel("Impostazioni")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            NavigationStack {
                BakeCreationView(preselectedFormula: nil)
            }
        }
        .sheet(isPresented: $showingStarterEditor) {
            NavigationStack {
                StarterEditorView(starter: nil)
            }
        }
        .sheet(item: $kefirEditorMode) { mode in
            NavigationStack {
                KefirBatchEditorView(mode: mode) { batch in
                    router.openKefirBatch(batch.id)
                }
            }
        }
    }



    // MARK: - Dashboard Header

    private var dashboardHeader: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Fermenti attivi")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Text.primary)
                Text("Tieni traccia delle tue fermentazioni in corso")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Theme.Text.secondary)
            }
            .padding(.bottom, 8)

            Menu {
                if isBakeEnabled {
                    Button { showingBakeEditor = true } label: {
                        Label("Nuovo impasto", image: "navbar-bake")
                    }
                }
                if isStarterEnabled {
                    Button { showingStarterEditor = true } label: {
                        Label("Nuovo starter", image: "navbar-starter")
                    }
                }
                if isKefirEnabled {
                    Button { kefirEditorMode = .create } label: {
                        Label("Nuovo batch kefir", systemImage: "drop.fill")
                    }
                }
            } label: {
                Label("Nuova preparazione", systemImage: "plus")
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }

    // MARK: - Section Tiles

    private var impastiTile: some View {
        FermentHubTile(
            icon: .asset("navbar-bake"),
            title: "Impasti",
            badge: bakesBadge,
            rows: bakesRows,
            isEmpty: activeBakes.isEmpty,
            emptyMessage: "Nessun attivo",
            onTap: { router.fermentationsPath.append(.bakesList) },
            onEmptyCTA: { showingBakeEditor = true }
        )
        .accessibilityIdentifier("ImpastiCard")
    }

    private var starterTile: some View {
        FermentHubTile(
            icon: .asset("navbar-starter"),
            title: "Starter",
            badge: startersBadge,
            rows: starterRows,
            isEmpty: starters.isEmpty,
            emptyMessage: "Crea il primo",
            onTap: { router.fermentationsPath.append(.starterList) },
            onEmptyCTA: { showingStarterEditor = true }
        )
        .accessibilityIdentifier("StarterCard")
    }

    private var kefirHubTile: some View {
        FermentHubTile(
            icon: .system("drop.fill"),
            title: "Kefir",
            badge: kefirBadge,
            rows: kefirRows,
            isEmpty: kefirBatches.isEmpty,
            emptyMessage: "Attiva batch",
            onTap: { router.fermentationsPath.append(.kefirHub) },
            onEmptyCTA: { kefirEditorMode = .create }
        )
        .accessibilityIdentifier("KefirHubCard")
    }

    private var ricetteTile: some View {
        FermentHubTile(
            icon: .system("book.closed.fill"),
            title: "Ricette",
            badge: formulas.isEmpty ? nil : "\(formulas.count)",
            rows: formulasRows,
            isEmpty: formulas.isEmpty,
            emptyMessage: "Crea ricetta",
            onTap: { router.fermentationsPath.append(.formulaList) },
            onEmptyCTA: { /* Could trigger formula creation */ }
        )
        .accessibilityIdentifier("RicetteCard")
    }

    // MARK: - Section Rows

    private var bakesRows: [FermentHubTile.Row] {
        guard !activeBakes.isEmpty else { return [] }
        return [
            .init(
                icon: "fork.knife",
                label: "\(activeBakes.count) in corso"
            )
        ]
    }

    private var starterRows: [FermentHubTile.Row] {
        guard !starters.isEmpty else { return [] }
        return [
            .init(
                icon: "flame.fill",
                label: "\(starters.count) gestiti"
            )
        ]
    }

    private var formulasRows: [FermentHubTile.Row] {
        guard !formulas.isEmpty else { return [] }
        return [
            .init(
                icon: "list.clipboard.fill",
                label: "\(formulas.count) salvate"
            )
        ]
    }

    // MARK: - Kefir rows

    private var kefirRows: [FermentHubTile.Row] {
        guard kefirBatches.isEmpty == false else { return [] }
        var rows: [FermentHubTile.Row] = []
        if kefirBatches.warningKefirCount > 0 {
            rows.append(.init(icon: "exclamationmark.circle.fill", label: "\(kefirBatches.warningKefirCount) da rinnovare", tone: .warning))
        }
        if kefirBatches.activeKefirCount > 0 {
            rows.append(.init(icon: "checkmark.circle.fill", label: "\(kefirBatches.activeKefirCount) in corso", tone: .ok))
        }
        if kefirBatches.pausedKefirCount > 0 {
            rows.append(.init(icon: "pause.circle.fill", label: "\(kefirBatches.pausedKefirCount) pausa"))
        }
        return rows
    }

    // MARK: - Badges

    private var bakesBadge: String? {
        activeBakes.isEmpty ? nil : "\(activeBakes.count)"
    }

    private var startersBadge: String? {
        starters.isEmpty ? nil : "\(starters.count)"
    }

    private var kefirBadge: String? {
        if kefirBatches.liveKefirCount > 0 { return "\(kefirBatches.liveKefirCount)" }
        return kefirBatches.archivedKefirCount > 0 ? "\(kefirBatches.archivedKefirCount)" : nil
    }

    // MARK: - Empty States

    private var allDisabledEmptyState: some View {
        EmptyStateView(
            title: "Nessuna sezione attiva",
            message: "Attiva le sezioni dalle impostazioni.",
            actionTitle: "Apri impostazioni"
        ) {
            showingSettings = true
        }
    }
}

// MARK: - Ferment Hub Tile

private struct FermentHubTile: View {
    struct Row {
        enum Tone { case `default`, warning, ok }
        let icon: String
        let label: String
        var tone: Tone = .default

        init(icon: String, label: String, tone: Tone = .default) {
            self.icon = icon
            self.label = label
            self.tone = tone
        }
    }

    enum Icon {
        case system(String)
        case asset(String)
    }

    let icon: Icon
    let title: String
    let badge: String?
    let rows: [Row]
    let isEmpty: Bool
    let emptyMessage: String
    let onTap: () -> Void
    let onEmptyCTA: () -> Void

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    tileIcon
                    Spacer()
                    if let badge {
                        StateBadge(text: badge, tone: .count)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Text.primary)
                        .lineLimit(1)

                    if isEmpty {
                        Text(emptyMessage)
                            .font(Theme.Typography.caption1)
                            .foregroundStyle(Theme.Text.secondary)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(rows.prefix(2), id: \.label) { row in
                                HStack(spacing: 4) {
                                    Image(systemName: row.icon)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(rowColor(row.tone))
                                    Text(row.label)
                                        .font(Theme.Typography.caption2)
                                        .foregroundStyle(Theme.Text.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private func rowColor(_ tone: Row.Tone) -> Color {
        switch tone {
        case .default: return Theme.Text.secondary
        case .warning: return Theme.Palette.amber800
        case .ok: return Theme.Palette.green600
        }
    }

    @ViewBuilder
    private var tileIcon: some View {
        switch icon {
        case let .system(name):
            Image(systemName: name)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Theme.Control.primaryFill)
        case let .asset(name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Theme.Control.primaryFill)
                .frame(width: 24, height: 24)
        }
    }
}
