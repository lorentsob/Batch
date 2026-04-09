import SwiftUI
import SwiftData

struct StarterDetailView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    let starter: Starter

    @State private var showingEditor = false
    @State private var showingRefreshSheet = false
    @State private var selectedRefresh: StarterRefresh?
    @State private var showingAllRefreshes = false

    private var sortedRefreshes: [StarterRefresh] {
        starter.refreshes.sorted { $0.dateTime > $1.dateTime }
    }

    var body: some View {
        let orderedRefreshes = sortedRefreshes
        let linkedBakes = starter.bakes.sorted { $0.targetBakeDateTime > $1.targetBakeDateTime }

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StarterDetailHeaderView(starter: starter) {
                    showingRefreshSheet = true
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Log rinfreschi")
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        Text("Registro dei rinfreschi passati con dosi, tempi e note.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    .padding(.bottom, 8)

                    if orderedRefreshes.isEmpty {
                        Text("Ancora nessun rinfresco registrato.")
                            .foregroundStyle(Theme.muted)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(orderedRefreshes.prefix(3)) { refresh in
                                Button {
                                    selectedRefresh = refresh
                                } label: {
                                    RefreshHistoryRow(refresh: refresh)
                                }
                                .buttonStyle(.plain)
                                Divider().padding(.vertical, 8)
                            }
                        }

                        Button {
                            showingAllRefreshes = true
                        } label: {
                            Label("Tutti i rinfreschi", systemImage: "clock.arrow.circlepath")
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                        .accessibilityIdentifier("StarterOpenAllLogsButton")
                    }
                }

                if linkedBakes.isEmpty == false {
                    SectionCard {
                        HStack {
                            Text("Impasti collegati")
                                .font(.headline)
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            StateBadge(text: "\(linkedBakes.count)", tone: .count)
                        }

                        ForEach(linkedBakes.prefix(4)) { bake in
                            Button {
                                router.openBake(bake.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(bake.name)
                                            .foregroundStyle(Theme.ink)
                                        HStack(spacing: 8) {
                                            StateBadge(bakeStatus: bake.derivedStatus)
                                            Text(DateFormattingService.dayTime(bake.targetBakeDateTime))
                                                .font(.footnote)
                                                .foregroundStyle(Theme.muted)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Theme.muted)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                TipGroupView(items: environment.knowledgeLibrary.tips(for: starter.dueState())) { id in
                    router.openKnowledge(id)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(starter.name)
        .tint(Theme.Control.primaryFill)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                StarterEditorView(starter: starter)
            }
        }
        .sheet(isPresented: $showingRefreshSheet) {
            NavigationStack {
                RefreshLogView(starter: starter)
            }
        }
        .sheet(item: $selectedRefresh) { refresh in
            NavigationStack {
                RefreshDetailView(refresh: refresh)
            }
        }
        .sheet(isPresented: $showingAllRefreshes) {
            NavigationStack {
                AllRefreshesView(starter: starter, onSelect: { refresh in
                    showingAllRefreshes = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        selectedRefresh = refresh
                    }
                })
            }
        }
    }
}

struct AllRefreshesView: View {
    @Environment(\.dismiss) private var dismiss
    let starter: Starter
    let onSelect: (StarterRefresh) -> Void

    private var sortedRefreshes: [StarterRefresh] {
        starter.refreshes.sorted { $0.dateTime > $1.dateTime }
    }

    var body: some View {
        let orderedRefreshes = sortedRefreshes

        ScrollView {
            VStack(spacing: 8) {
                ForEach(orderedRefreshes) { refresh in
                    Button {
                        onSelect(refresh)
                    } label: {
                        RefreshHistoryRow(refresh: refresh)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Tutti i rinfreschi")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") { dismiss() }
            }
        }
    }
}
