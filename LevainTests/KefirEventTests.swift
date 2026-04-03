import Foundation
import SwiftData
import Testing
@testable import Levain

@Suite("Kefir Event Tests")
struct KefirEventTests {
    @Test("Create and derive events persist typed lineage")
    func createAndDeriveEventsPersistTypedLineage() throws {
        let context = try ModelTestSupport.makeInMemoryContext()
        let sourceCreatedAt = Date.fixedNow
        let sourceBatch = DomainFixtures.makeKefirBatch(
            name: "Batch madre",
            lastManagedAt: sourceCreatedAt
        )
        context.insert(sourceBatch)
        KefirEventRecorder.recordCreation(of: sourceBatch, mode: .create, in: context, at: sourceCreatedAt)

        let derivedCreatedAt = sourceCreatedAt.adding(minutes: 90)
        let derivedBatch = DomainFixtures.makeKefirBatch(
            name: "Batch figlio",
            lastManagedAt: derivedCreatedAt,
            sourceBatchId: sourceBatch.id,
            differentiationNote: "Piu delicato"
        )
        context.insert(derivedBatch)
        KefirEventRecorder.recordCreation(
            of: derivedBatch,
            mode: .derive(source: sourceBatch),
            in: context,
            at: derivedCreatedAt
        )

        try context.save()

        let events = try context.fetch(FetchDescriptor<KefirEvent>())
        #expect(events.count == 4)

        let sourceCreated = try #require(
            events.first(where: { $0.batchID == sourceBatch.id && $0.kind == .created })
        )
        #expect(sourceCreated.storageMode == .roomTemperature)

        let derivedCreated = try #require(
            events.first(where: { $0.batchID == derivedBatch.id && $0.kind == .created })
        )
        #expect(derivedCreated.storageMode == .roomTemperature)

        let derivedLineage = try #require(
            events.first(where: { $0.batchID == derivedBatch.id && $0.kind == .derivedFromBatch })
        )
        #expect(derivedLineage.relatedBatchID == sourceBatch.id)
        #expect(derivedLineage.relatedBatchName == "Batch madre")
        #expect(derivedLineage.note == "Piu delicato")

        let spawnedEvent = try #require(
            events.first(where: { $0.batchID == sourceBatch.id && $0.kind == .spawnedDerivedBatch })
        )
        #expect(spawnedEvent.relatedBatchID == derivedBatch.id)
        #expect(spawnedEvent.relatedBatchName == "Batch figlio")
    }

    @Test("Renewal and management updates capture storage-aware event types")
    func renewalAndManagementUpdatesCaptureStorageAwareEventTypes() throws {
        let context = try ModelTestSupport.makeInMemoryContext()
        let batch = DomainFixtures.makeKefirBatch(
            name: "Batch gestione",
            lastManagedAt: .fixedNow
        )
        context.insert(batch)

        let renewedAt = Date.fixedNow.adding(minutes: 60)
        batch.renew(at: renewedAt)
        KefirEventRecorder.recordRenewal(of: batch, in: context, at: renewedAt)

        let storageSnapshot = KefirEventRecorder.Snapshot(batch: batch)
        let storageChangedAt = renewedAt.adding(minutes: 60)
        batch.applyManagementUpdate(
            storageMode: .fridge,
            expectedRoutineHours: 7 * 24,
            at: storageChangedAt
        )
        KefirEventRecorder.recordManagementUpdate(
            of: batch,
            previous: storageSnapshot,
            in: context,
            at: storageChangedAt
        )

        let routineSnapshot = KefirEventRecorder.Snapshot(batch: batch)
        let routineChangedAt = storageChangedAt.adding(minutes: 60)
        batch.applyManagementUpdate(
            storageMode: .fridge,
            expectedRoutineHours: 5 * 24,
            at: routineChangedAt
        )
        KefirEventRecorder.recordManagementUpdate(
            of: batch,
            previous: routineSnapshot,
            in: context,
            at: routineChangedAt
        )

        try context.save()

        let events = try context.fetch(KefirEvent.descriptor(for: batch.id))
        let renewedEvent = try #require(events.first(where: { $0.kind == .renewed }))
        #expect(renewedEvent.storageMode == .roomTemperature)

        let storageChangedEvent = try #require(events.first(where: { $0.kind == .storageChanged }))
        #expect(storageChangedEvent.previousStorageMode == .roomTemperature)
        #expect(storageChangedEvent.storageMode == .fridge)
        #expect(storageChangedEvent.expectedRoutineHours == 7 * 24)

        let managementEvent = try #require(events.first(where: { $0.kind == .managementUpdated }))
        #expect(managementEvent.storageMode == .fridge)
        #expect(managementEvent.expectedRoutineHours == 5 * 24)
    }

    @Test("Reactivation and archive events persist lifecycle transitions")
    func reactivationAndArchiveEventsPersistLifecycleTransitions() throws {
        let context = try ModelTestSupport.makeInMemoryContext()
        let batch = DomainFixtures.makeKefirBatch(
            name: "Batch freezer",
            storageMode: .freezer,
            lastManagedAt: .fixedNow.adding(minutes: -(3 * 24 * 60)),
            plannedReactivationAt: .fixedNow.adding(minutes: 2 * 24 * 60)
        )
        context.insert(batch)

        let previous = KefirEventRecorder.Snapshot(batch: batch)
        let reactivatedAt = Date.fixedNow
        batch.reactivate(at: reactivatedAt)
        KefirEventRecorder.recordReactivation(
            of: batch,
            previous: previous,
            in: context,
            at: reactivatedAt
        )

        let archivedAt = reactivatedAt.adding(minutes: 60)
        batch.archive(at: archivedAt)
        KefirEventRecorder.recordArchive(of: batch, in: context, at: archivedAt)

        try context.save()

        let events = try context.fetch(KefirEvent.descriptor(for: batch.id))
        let reactivationEvent = try #require(events.first(where: { $0.kind == .reactivated }))
        #expect(reactivationEvent.previousStorageMode == .freezer)
        #expect(reactivationEvent.storageMode == .roomTemperature)
        #expect(reactivationEvent.plannedReactivationAt == nil)

        let archiveEvent = try #require(events.first(where: { $0.kind == .archived }))
        #expect(archiveEvent.storageMode == .roomTemperature)
    }

    @Test("Manual notes persist as note events")
    func manualNotesPersistAsNoteEvents() throws {
        let context = try ModelTestSupport.makeInMemoryContext()
        let batch = DomainFixtures.makeKefirBatch(name: "Batch note", lastManagedAt: .fixedNow)
        context.insert(batch)

        KefirEventRecorder.recordManualNote(
            "  Piu cremoso dopo 24 ore  ",
            for: batch,
            in: context,
            at: .fixedNow
        )
        try context.save()

        let noteEvent = try #require(context.fetch(KefirEvent.descriptor(for: batch.id)).first)
        #expect(noteEvent.kind == .noteAdded)
        #expect(noteEvent.note == "Piu cremoso dopo 24 ore")
    }
}
