import SwiftData
import SwiftUI

@MainActor
struct PreparationsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query private var starters: [Starter]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingBakeEditor = false
    @State private var showingStarterEditor = false

    private var activeBakes: [Bake] {
        bakes.filter { $0.derivedStatus != .cancelled && $0.derivedStatus != .completed }
    }

    var body: some View {
        List {
            // Header
            SectionCard(emphasis: .tinted) {
                Text("Preparazioni")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("Pane, lievito madre e fermentazioni.")
                    .foregroundStyle(Theme.muted)
            }
            .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            // Quick actions strip
            quickActionsSection

            // Domain hubs
            hubsSection
        }
        .listStyle(.plain)
        .background(Theme.Surface.app)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingBakeEditor) {
            BakeCreationView(preselectedFormula: nil)
        }
        .sheet(isPresented: $showingStarterEditor) {
            StarterEditorView(starter: nil)
        }
        .accessibilityIdentifier("PreparationsView")
    }

    // MARK: - Sections

    private var quickActionsSection: some View {
        Section {
            HStack(spacing: 10) {
                QuickActionButton(
                    label: "Nuovo impasto",
                    systemImage: "plus.circle.fill",
                    accessibilityIdentifier: "QuickNewBakeButton"
                ) {
                    showingBakeEditor = true
                }

                QuickActionButton(
                    label: "Nuovo starter",
                    systemImage: "flame.fill",
                    accessibilityIdentifier: "QuickNewStarterButton"
                ) {
                    showingStarterEditor = true
                }

                QuickActionButton(
                    label: "Nuovo kefir",
                    systemImage: "drop.fill",
                    accessibilityIdentifier: "QuickNewKefirButton"
                ) {
                    // Kefir batch creation — Phase 19
                }
            }
            .padding(.vertical, 4)
        }
        .listRowInsets(.init(top: 8, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var hubsSection: some View {
        Section {
            PreparationHubCardView(
                systemImage: "wheat",
                title: "Pane e lievito madre",
                subtitle: breadHubSubtitle,
                badge: breadBadge,
                isEmpty: activeBakes.isEmpty && starters.isEmpty,
                emptyLabel: "Inizia il primo impasto",
                onTap: {
                    router.preparationsPath.append(.breadHub)
                },
                onEmptyCTA: {
                    showingBakeEditor = true
                }
            )
            .accessibilityIdentifier("BreadHubCard")

            PreparationHubCardView(
                systemImage: "drop.triangle.fill",
                title: "Milk kefir",
                subtitle: "Gestisci i tuoi batch di kefir.",
                badge: nil,
                isEmpty: true,
                emptyLabel: "Nuovo batch",
                onTap: {
                    router.preparationsPath.append(.kefirHub)
                },
                onEmptyCTA: {
                    // Kefir batch creation — Phase 19
                }
            )
            .accessibilityIdentifier("KefirHubCard")
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 12, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Helpers

    private var breadHubSubtitle: String {
        if activeBakes.isEmpty && starters.isEmpty {
            return "Nessun impasto o starter attivi."
        }
        var parts: [String] = []
        if activeBakes.isEmpty == false {
            parts.append("\(activeBakes.count) impast\(activeBakes.count == 1 ? "o" : "i") attiv\(activeBakes.count == 1 ? "o" : "i")")
        }
        if starters.isEmpty == false {
            parts.append("\(starters.count) starter")
        }
        return parts.joined(separator: " · ")
    }

    private var breadBadge: String? {
        let total = activeBakes.count + starters.count
        return total > 0 ? "\(total)" : nil
    }
}

// MARK: - Quick Action Button

private struct QuickActionButton: View {
    let label: String
    let systemImage: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Theme.Surface.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
