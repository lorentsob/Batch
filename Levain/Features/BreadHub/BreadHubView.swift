import SwiftData
import SwiftUI

@MainActor
struct BreadHubView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter

    @Query(sort: \Bake.targetBakeDateTime, order: .forward) private var bakes: [Bake]
    @Query private var starters: [Starter]
    @Query(sort: \RecipeFormula.name) private var formulas: [RecipeFormula]

    @State private var showingBakeEditor = false
    @State private var showingStarterEditor = false
    @State private var showingFormulaEditor = false

    private var activeBakes: [Bake] {
        bakes.filter { $0.derivedStatus != .cancelled && $0.derivedStatus != .completed }
    }

    var body: some View {
        List {
            SectionCard(emphasis: .tinted) {
                Text("Pane e lievito madre")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("Impasti, starter e formule.")
                    .foregroundStyle(Theme.muted)
            }
            .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            breadEntries
        }
        .listStyle(.plain)
        .background(Theme.Surface.app)
        .navigationTitle("Pane e lievito madre")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Nuovo impasto", systemImage: "plus") {
                        showingBakeEditor = true
                    }
                    Button("Nuovo starter", systemImage: "flame") {
                        showingStarterEditor = true
                    }
                    Button("Nuova formula", systemImage: "doc.text") {
                        showingFormulaEditor = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingBakeEditor) {
            BakeCreationView(preselectedFormula: nil)
        }
        .sheet(isPresented: $showingStarterEditor) {
            StarterEditorView(starter: nil)
        }
        .sheet(isPresented: $showingFormulaEditor) {
            FormulaEditorView(formula: nil)
        }
        .accessibilityIdentifier("BreadHubView")
    }

    // MARK: - Entries

    private var breadEntries: some View {
        Section {
            BreadHubEntryRow(
                systemImage: "loaf.fill",
                title: "Impasti",
                subtitle: impastiSubtitle,
                badge: activeBakes.isEmpty ? nil : "\(activeBakes.count)",
                isEmpty: activeBakes.isEmpty,
                emptyLabel: "Nuovo impasto",
                accessibilityIdentifier: "BreadHubImpastiRow",
                onTap: {
                    router.preparationsPath.append(.bakesList)
                },
                onEmptyCTA: {
                    showingBakeEditor = true
                }
            )

            BreadHubEntryRow(
                systemImage: "flame.fill",
                title: "Starter",
                subtitle: starterSubtitle,
                badge: starters.isEmpty ? nil : "\(starters.count)",
                isEmpty: starters.isEmpty,
                emptyLabel: "Nuovo starter",
                accessibilityIdentifier: "BreadHubStarterRow",
                onTap: {
                    router.preparationsPath.append(.starterList)
                },
                onEmptyCTA: {
                    showingStarterEditor = true
                }
            )

            BreadHubEntryRow(
                systemImage: "doc.text.fill",
                title: "Formule",
                subtitle: formuleSubtitle,
                badge: formulas.isEmpty ? nil : "\(formulas.count)",
                isEmpty: formulas.isEmpty,
                emptyLabel: "Nuova formula",
                accessibilityIdentifier: "BreadHubFormuleRow",
                onTap: {
                    router.preparationsPath.append(.formulaList)
                },
                onEmptyCTA: {
                    showingFormulaEditor = true
                }
            )
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Subtitles

    private var impastiSubtitle: String {
        activeBakes.isEmpty ? "Nessun impasto attivo." : "\(activeBakes.count) attiv\(activeBakes.count == 1 ? "o" : "i")"
    }

    private var starterSubtitle: String {
        starters.isEmpty ? "Nessuno starter registrato." : "\(starters.count) starter"
    }

    private var formuleSubtitle: String {
        formulas.isEmpty ? "Nessuna formula salvata." : "\(formulas.count) formula\(formulas.count == 1 ? "" : "e")"
    }
}

// MARK: - Entry Row

private struct BreadHubEntryRow: View {
    let systemImage: String
    let title: String
    let subtitle: String
    let badge: String?
    let isEmpty: Bool
    let emptyLabel: String
    let accessibilityIdentifier: String
    let onTap: () -> Void
    let onEmptyCTA: () -> Void

    var body: some View {
        Button(action: onTap) {
            SectionCard {
                HStack(spacing: 14) {
                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            if let badge {
                                StateBadge(text: badge, tone: .count)
                            }
                        }
                        if isEmpty {
                            Button(emptyLabel, action: onEmptyCTA)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.accent)
                        } else {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Theme.muted)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.muted)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
