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
        GridItem(.flexible(), spacing: Theme.Spacing.sm),
        GridItem(.flexible(), spacing: Theme.Spacing.sm)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Layout.sectionGap) {
                if allFeaturesDisabled {
                    allDisabledEmptyState
                        .padding(.top, Theme.Spacing.lg)
                } else {
                    dashboardHeader

                    LazyVGrid(columns: columns, spacing: Theme.Spacing.sm) {
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
            .levainScrollScreenPadding()
        }
        .background(Theme.Surface.app.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
            ScreenTitleBlock(
                title: "Batch",
                subtitle: "I tuoi batch attivi"
            )
            .padding(.bottom, Theme.Spacing.xs)

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
            onTap: { router.fermentationsPath.append(.bakesList) }
        )
        .accessibilityIdentifier("ImpastiCard")
    }

    private var starterTile: some View {
        FermentHubTile(
            icon: .asset("navbar-starter"),
            title: "Starter",
            badge: startersBadge,
            rows: starterRows,
            onTap: { router.fermentationsPath.append(.starterList) }
        )
        .accessibilityIdentifier("StarterCard")
    }

    private var kefirHubTile: some View {
        FermentHubTile(
            icon: .system("drop.fill"),
            title: "Kefir",
            badge: kefirBadge,
            rows: kefirRows,
            onTap: { router.fermentationsPath.append(.kefirHub) }
        )
        .accessibilityIdentifier("KefirHubCard")
    }

    private var ricetteTile: some View {
        FermentHubTile(
            icon: .system("book.closed.fill"),
            title: "Ricette",
            badge: "\(formulas.count)",
            rows: formulasRows,
            onTap: { router.fermentationsPath.append(.formulaList) }
        )
        .accessibilityIdentifier("RicetteCard")
    }

    // MARK: - Section Rows

    private var bakesRows: [FermentHubTile.Row] {
        [
            .init(
                icon: "fork.knife",
                label: "\(activeBakes.count) in corso"
            )
        ]
    }

    private var starterRows: [FermentHubTile.Row] {
        [
            .init(
                icon: "flame.fill",
                label: "\(starters.count) gestit\(starters.count == 1 ? "o" : "i")"
            )
        ]
    }

    private var formulasRows: [FermentHubTile.Row] {
        [
            .init(
                icon: "list.clipboard.fill",
                label: "\(formulas.count) salvat\(formulas.count == 1 ? "a" : "e")"
            )
        ]
    }

    // MARK: - Kefir rows

    private var kefirRows: [FermentHubTile.Row] {
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
        if rows.isEmpty {
            if kefirBatches.archivedKefirCount > 0 {
                rows.append(
                    .init(
                        icon: "archivebox.fill",
                        label: "\(kefirBatches.archivedKefirCount) archiviat\(kefirBatches.archivedKefirCount == 1 ? "o" : "i")"
                    )
                )
            } else {
                rows.append(.init(icon: "drop.fill", label: "0 batch attivi"))
            }
        }
        return rows
    }

    // MARK: - Badges

    private var bakesBadge: String? {
        "\(activeBakes.count)"
    }

    private var startersBadge: String? {
        "\(starters.count)"
    }

    private var kefirBadge: String? {
        if kefirBatches.liveKefirCount > 0 { return "\(kefirBatches.liveKefirCount)" }
        return kefirBatches.archivedKefirCount > 0 ? "\(kefirBatches.archivedKefirCount)" : "0"
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
    let onTap: () -> Void

    private static let maxVisibleRows = 2
    private static let minTileContentHeight: CGFloat = 104
    private static let metricRowsMinHeight: CGFloat = 30

    var body: some View {
        SectionCard(emphasis: .tinted) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack(alignment: .top) {
                    tileIcon
                    Spacer()
                    if let badge {
                        StateBadge(text: badge, tone: .count)
                    }
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Text.primary)
                        .lineLimit(1)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        ForEach(visibleRows, id: \.label) { row in
                            HStack(spacing: Theme.Spacing.xxs) {
                                Image(systemName: row.icon)
                                    .font(Theme.Typography.caption2.weight(.semibold))
                                    .foregroundStyle(rowColor(row.tone))
                                    .frame(width: 12, alignment: .center)
                                Text(row.label)
                                    .font(Theme.Typography.caption2)
                                    .foregroundStyle(Theme.Text.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.86)
                            }
                        }
                    }
                    .frame(minHeight: Self.metricRowsMinHeight, alignment: .topLeading)
                }
            }
            .padding(.vertical, Theme.Spacing.xxs)
            .frame(maxWidth: .infinity, minHeight: Self.minTileContentHeight, alignment: .topLeading)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .accessibilityElement(children: .combine)
        .accessibilityValue(visibleRows.map(\.label).joined(separator: " · "))
    }

    private var visibleRows: [Row] {
        Array(rows.prefix(Self.maxVisibleRows))
    }

    private func rowColor(_ tone: Row.Tone) -> Color {
        switch tone {
        case .default: return Theme.Text.secondary
        case .warning: return Theme.Control.secondaryForeground
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
