import SwiftData
import SwiftUI

@MainActor
struct KefirHubView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \KefirBatch.lastManagedAt, order: .reverse) private var batches: [KefirBatch]

    @State private var editorMode: KefirBatchEditorView.Mode?
    @State private var showingJournal = false

    var body: some View {
        List {
            headerCard

            if batches.isEmpty {
                EmptyStateView(
                    title: "Nessun batch attivo",
                    message: "Quando avvii il primo batch lo trovi qui.",
                    actionTitle: "Nuovo batch"
                ) {
                    editorMode = .create
                }
                .listRowInsets(.init(top: 16, leading: 20, bottom: 16, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                KefirBatchListView(batches: batches) { batch in
                    router.fermentationsPath.append(.kefirBatch(batch.id))
                } onArchive: { batch in
                    archiveBatch(batch)
                }
            }
        }
        .listStyle(.plain)
        .background(Theme.Surface.app)
        .navigationTitle("Kefir")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Nuovo batch") {
                    editorMode = .create
                }
            }
        }
        .accessibilityIdentifier("KefirHubView")
        .sheet(item: $editorMode) { mode in
            NavigationStack {
                KefirBatchEditorView(mode: mode) { batch in
                    router.fermentationsPath.append(.kefirBatch(batch.id))
                }
            }
        }
        .navigationDestination(isPresented: $showingJournal) {
            KefirJournalView()
        }
    }

    private func archiveBatch(_ batch: KefirBatch) {
        let now = Date.now
        batch.archive(at: now)
        KefirEventRecorder.recordArchive(of: batch, in: modelContext, at: now)
        try? modelContext.save()
        let batchID = batch.id
        let context = modelContext
        Task { @MainActor in
            await environment.notificationService.syncNotifications(forKefirBatch: batchID, in: context)
        }
    }

    private var headerCard: some View {
        SectionCard(emphasis: .tinted) {
            Text("Kefir")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.ink)
            Text("I tuoi batch, dove sono e cosa fare.")
                .foregroundStyle(Theme.muted)

            if batches.isEmpty == false {
                HStack(spacing: 10) {
                    if batches.warningKefirCount > 0 {
                        StateBadge(text: "\(batches.warningKefirCount) da seguire", tone: .count)
                    }
                    if batches.activeKefirCount > 0 {
                        StateBadge(text: "\(batches.activeKefirCount) in corso", tone: .count)
                    }
                    if batches.pausedKefirCount > 0 {
                        StateBadge(text: "\(batches.pausedKefirCount) in pausa", tone: .count)
                    }
                    if batches.liveKefirCount == 0, batches.archivedKefirCount > 0 {
                        StateBadge(text: "\(batches.archivedKefirCount) archiviat\(batches.archivedKefirCount == 1 ? "o" : "i")", tone: .count)
                    }
                }

                HStack {
                    Spacer()
                    Button {
                        showingJournal = true
                    } label: {
                        Label("Journal", systemImage: "clock.arrow.circlepath")
                    }
                    .buttonStyle(SecondaryActionButtonStyle(fill: Theme.Surface.card))
                    .accessibilityIdentifier("KefirHubOpenJournalButton")
                }
            }
        }
        .listRowInsets(.init(top: 0, leading: 20, bottom: 8, trailing: 20))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .accessibilityIdentifier("KefirHubSummaryCard")
    }
}
