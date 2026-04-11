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
                    message: "Quando avvii il primo batch lo trovi qui."
                )
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

            journalSection
        }
        .listStyle(.plain)
        .levainListSurface()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
            ScreenTitleBlock(
                title: "Kefir",
                subtitle: "I tuoi batch di kefir"
            )

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
            }

            Button {
                editorMode = .create
            } label: {
                Label("Nuovo batch", systemImage: "plus")
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .padding(.top, Theme.Spacing.xxs)
        }
        .listRowInsets(.levainListRow(top: Theme.Spacing.sm, bottom: Theme.Spacing.xs))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .accessibilityIdentifier("KefirHubSummaryCard")
    }

    private var journalSection: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Cronologia batch")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Text.primary)
                Text("Tieni traccia dei rinnovi dei tuoi batch")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Theme.Text.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                showingJournal = true
            } label: {
                Label("Apri cronologia", systemImage: "clock.arrow.circlepath")
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .padding(.top, Theme.Spacing.xxs)
            .accessibilityIdentifier("KefirHubOpenJournalButton")
        }
        .listRowInsets(.levainListRow(top: Theme.Spacing.xs, bottom: Theme.Spacing.md))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
