import Foundation
import SwiftData
import Testing
@testable import Levain

/// Tests that verify the sample-data seeding contract:
/// - Normal first launch does not auto-seed (the RootTabView change enforces this,
///   but we test the SeedDataLoader methods directly).
/// - `ensureSeedData` is idempotent: multiple calls insert content only once.
/// - `resetAndSeed` bypasses the idempotency guard when called explicitly on an
///   in-memory store (internal testing path).
@Suite("SeedDataLoader Tests")
struct SeedDataLoaderTests {

    // MARK: - Helpers

    // MARK: - Idempotency

    @Test("ensureSeedData inserts content on first call")
    func testEnsureSeedDataInsertsOnFirstCall() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context)

        let starters = try context.fetch(FetchDescriptor<Starter>())
        #expect(starters.count > 0, "Expected at least one starter after first seed")

        let formulas = try context.fetch(FetchDescriptor<RecipeFormula>())
        #expect(formulas.count > 0, "Expected at least one formula after first seed")

        let bakes = try context.fetch(FetchDescriptor<Bake>())
        #expect(bakes.count > 0, "Expected at least one bake after first seed")

        let kefirEvents = try context.fetch(KefirEvent.timelineDescriptor)
        #expect(kefirEvents.count > 0, "Expected seeded kefir history after first seed")
    }

    @Test("ensureSeedData is idempotent — second call does not duplicate content")
    func testEnsureSeedDataIdempotent() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context)
        let countAfterFirst = try context.fetch(FetchDescriptor<Starter>()).count

        // Second call must be a no-op
        try SeedDataLoader.ensureSeedData(in: context)
        let countAfterSecond = try context.fetch(FetchDescriptor<Starter>()).count

        #expect(countAfterFirst == countAfterSecond, "Idempotency violated: second seed duplicated starters")
    }

    @Test("ensureSeedData sets didSeedSampleData flag to true")
    func testEnsureSeedDataSetsFlag() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context)

        let settings = try context.fetch(FetchDescriptor<AppSettings>())
        #expect(settings.first?.didSeedSampleData == true, "didSeedSampleData should be marked after seeding")
    }

    // MARK: - Empty store

    @Test("Fresh in-memory store has no starters before seeding")
    func testFreshStorHasNoContent() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let starters = try context.fetch(FetchDescriptor<Starter>())
        #expect(starters.isEmpty, "Fresh store must not contain any starters")

        let formulas = try context.fetch(FetchDescriptor<RecipeFormula>())
        #expect(formulas.isEmpty, "Fresh store must not contain any formulas")
    }

    // MARK: - resetAndSeed

    @Test("resetAndSeed re-seeds even when idempotency flag is set")
    func testResetAndSeedOverridesFlag() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        // First seed
        try SeedDataLoader.ensureSeedData(in: context)
        let settings = try context.fetch(FetchDescriptor<AppSettings>()).first
        #expect(settings?.didSeedSampleData == true)

        // resetAndSeed should succeed without throwing even with flag set
        // (in-memory store; we delete starters first to get a clean count)
        let existingStarters = try context.fetch(FetchDescriptor<Starter>())
        for s in existingStarters { context.delete(s) }

        try SeedDataLoader.resetAndSeed(in: context)

        let starters = try context.fetch(FetchDescriptor<Starter>())
        #expect(starters.count > 0, "resetAndSeed must insert content even when flag was true")
    }

    @Test("operational scenario seeds event-rich kefir history")
    func testOperationalScenarioSeedsKefirHistory() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context, scenario: .operational)

        let batches = try context.fetch(FetchDescriptor<KefirBatch>())
        #expect(batches.count == 5, "Operational scenario should seed five kefir batches")

        let events = try context.fetch(KefirEvent.timelineDescriptor)
        #expect(events.count >= 20, "Operational scenario should seed a readable journal history")
        #expect(events.contains(where: { $0.kind == .derivedFromBatch }), "Expected lineage events for derived batches")
        #expect(events.contains(where: { $0.kind == .spawnedDerivedBatch }), "Expected reciprocal lineage events on source batches")
        #expect(events.contains(where: { $0.kind == .storageChanged }), "Expected storage changes for paused batches")
        #expect(events.contains(where: { $0.kind == .archived }), "Expected at least one archive event")
    }

    @Test("operational scenario seeds archived and derived kefir context")
    func testOperationalScenarioSeedsArchivedDerivedKefirContext() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context, scenario: .operational)

        let archivedBatch = try context.fetch(FetchDescriptor<KefirBatch>()).first {
            $0.name == "Batch test derivato"
        }
        #expect(archivedBatch?.isArchived == true, "Archived seeded batch should remain available in archive")

        guard let archivedBatch else {
            return
        }

        let archiveEvents = try context.fetch(KefirEvent.descriptor(for: archivedBatch.id))
        #expect(archiveEvents.contains(where: { $0.kind == .derivedFromBatch }))
        #expect(archiveEvents.contains(where: { $0.kind == .archived }))
    }
}
