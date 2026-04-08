import SwiftUI

struct KefirBatchListView: View {
    let batches: [KefirBatch]
    let onOpen: (KefirBatch) -> Void
    let onArchive: (KefirBatch) -> Void

    @State private var isArchiveExpanded = false

    var body: some View {
        ForEach(batches.kefirSections) { section in
            if section.kind == .archived {
                archiveSectionHeader(section)
                    .listRowInsets(.levainListRow(top: Theme.Spacing.xs, bottom: Theme.Spacing.xxs))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if isArchiveExpanded {
                    batchRows(for: section)
                }
            } else {
                sectionHeader(section)
                    .listRowInsets(.levainListRow(top: Theme.Spacing.xs, bottom: Theme.Spacing.xxs))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                batchRows(for: section)
            }
        }
    }

    @ViewBuilder
    private func batchRows(for section: KefirBatchSectionModel) -> some View {
        ForEach(section.batches) { batch in
            KefirBatchCardView(
                batch: batch,
                lineageSummary: batch.lineageSummary(in: batches)
            ) {
                onOpen(batch)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                if !batch.isArchived {
                    Button(role: .destructive) {
                        onArchive(batch)
                    } label: {
                        Label("Archivia", systemImage: "archivebox")
                    }
                    .accessibilityIdentifier("KefirBatchSwipeArchive-\(batch.id)")
                }
            }
            .listRowInsets(.levainListRow(bottom: Theme.Spacing.xs))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private func sectionHeader(_ section: KefirBatchSectionModel) -> some View {
        HStack {
            Text(section.kind.title)
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Text.primary)
            Spacer()
            StateBadge(text: "\(section.batches.count)", tone: .count)
        }
        .accessibilityIdentifier("KefirSection-\(section.kind.rawValue)")
    }

    private func archiveSectionHeader(_ section: KefirBatchSectionModel) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isArchiveExpanded.toggle()
            }
        } label: {
            HStack {
                Text(section.kind.title)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Text.primary)
                Spacer()
                StateBadge(text: "\(section.batches.count)", tone: .count)
                Image(systemName: isArchiveExpanded ? "chevron.up" : "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.Text.secondary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("KefirArchiveSectionHeader")
    }
}
