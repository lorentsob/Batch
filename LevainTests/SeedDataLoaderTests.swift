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

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([
            Starter.self,
            StarterRefresh.self,
            RecipeFormula.self,
            Bake.self,
            BakeStep.self,
            AppSettings.self
        ])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    // MARK: - Idempotency

    @Test("ensureSeedData inserts content on first call")
    func testEnsureSeedDataInsertsOnFirstCall() throws {
        let context = try makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context)

        let starters = try context.fetch(FetchDescriptor<Starter>())
        #expect(starters.count > 0, "Expected at least one starter after first seed")

        let formulas = try context.fetch(FetchDescriptor<RecipeFormula>())
        #expect(formulas.count > 0, "Expected at least one formula after first seed")

        let bakes = try context.fetch(FetchDescriptor<Bake>())
        #expect(bakes.count > 0, "Expected at least one bake after first seed")
    }

    @Test("ensureSeedData is idempotent — second call does not duplicate content")
    func testEnsureSeedDataIdempotent() throws {
        let context = try makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context)
        let countAfterFirst = try context.fetch(FetchDescriptor<Starter>()).count

        // Second call must be a no-op
        try SeedDataLoader.ensureSeedData(in: context)
        let countAfterSecond = try context.fetch(FetchDescriptor<Starter>()).count

        #expect(countAfterFirst == countAfterSecond, "Idempotency violated: second seed duplicated starters")
    }

    @Test("ensureSeedData sets didSeedSampleData flag to true")
    func testEnsureSeedDataSetsFlag() throws {
        let context = try makeInMemoryContext()

        try SeedDataLoader.ensureSeedData(in: context)

        let settings = try context.fetch(FetchDescriptor<AppSettings>())
        #expect(settings.first?.didSeedSampleData == true, "didSeedSampleData should be marked after seeding")
    }

    // MARK: - Empty store

    @Test("Fresh in-memory store has no starters before seeding")
    func testFreshStorHasNoContent() throws {
        let context = try makeInMemoryContext()

        let starters = try context.fetch(FetchDescriptor<Starter>())
        #expect(starters.isEmpty, "Fresh store must not contain any starters")

        let formulas = try context.fetch(FetchDescriptor<RecipeFormula>())
        #expect(formulas.isEmpty, "Fresh store must not contain any formulas")
    }

    // MARK: - resetAndSeed

    @Test("resetAndSeed re-seeds even when idempotency flag is set")
    func testResetAndSeedOverridesFlag() throws {
        let context = try makeInMemoryContext()

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
}
