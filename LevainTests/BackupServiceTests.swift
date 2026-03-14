import Foundation
import SwiftData
import Testing
@testable import Levain

@Suite("BackupService Tests")
struct BackupServiceTests {
    @Test("Backup round-trip restores user data with stable identifiers")
    func testBackupRoundTripRestore() throws {
        let sourceContext = try ModelTestSupport.makeInMemoryContext()
        let starter = DomainFixtures.makeStarter(name: "Madre")
        let formula = DomainFixtures.makeFormula(name: "Pane rustico")
        let bake = BakeScheduler.generateBake(
            name: "Weekend",
            targetBakeDateTime: .fixedNow,
            formula: formula,
            starter: starter
        )

        sourceContext.insert(starter)
        sourceContext.insert(formula)
        sourceContext.insert(bake)
        bake.steps.forEach { sourceContext.insert($0) }
        sourceContext.insert(
            StarterRefresh(
                flourWeight: 100,
                waterWeight: 100,
                starterWeightUsed: 50,
                ratioText: "1:2:2",
                starter: starter
            )
        )
        try sourceContext.save()

        let data = try BackupService.exportData(using: sourceContext)

        let destinationContext = try ModelTestSupport.makeInMemoryContext()
        try BackupService.restore(from: data, into: destinationContext)

        let starters = try destinationContext.fetch(FetchDescriptor<Starter>())
        let formulas = try destinationContext.fetch(FetchDescriptor<RecipeFormula>())
        let bakes = try destinationContext.fetch(FetchDescriptor<Bake>())
        let steps = try destinationContext.fetch(FetchDescriptor<BakeStep>())
        let refreshes = try destinationContext.fetch(FetchDescriptor<StarterRefresh>())

        #expect(starters.count == 1)
        #expect(formulas.count == 1)
        #expect(bakes.count == 1)
        #expect(steps.count == bake.steps.count)
        #expect(refreshes.count == 1)
        #expect(starters.first?.id == starter.id)
        #expect(formulas.first?.id == formula.id)
        #expect(bakes.first?.id == bake.id)
    }

    @Test("Restore is idempotent on an empty store")
    func testRestoreIdempotentOnEmptyStore() throws {
        let sourceContext = try ModelTestSupport.makeInMemoryContext()
        try SeedDataLoader.ensureSeedData(in: sourceContext)
        let data = try BackupService.exportData(using: sourceContext)

        let restoreContext = try ModelTestSupport.makeInMemoryContext()
        try BackupService.restore(from: data, into: restoreContext)
        try BackupService.restore(from: data, into: restoreContext)

        let starters = try restoreContext.fetch(FetchDescriptor<Starter>())
        let formulas = try restoreContext.fetch(FetchDescriptor<RecipeFormula>())
        let bakes = try restoreContext.fetch(FetchDescriptor<Bake>())

        #expect(starters.count == 1)
        #expect(formulas.count == 2)
        #expect(bakes.count == 1)
    }

    @Test("Restore rejects unsupported schema versions")
    func testRestoreRejectsUnsupportedSchemaVersion() throws {
        let payload = BackupPayloadV1(
            schemaVersion: 999,
            exportedAt: .fixedNow,
            starters: [],
            starterRefreshes: [],
            recipeFormulas: [],
            bakes: [],
            bakeSteps: []
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        let context = try ModelTestSupport.makeInMemoryContext()

        do {
            try BackupService.restore(from: data, into: context)
            Issue.record("Expected unsupported schema version error")
        } catch let error as BackupService.BackupError {
            #expect(error == .unsupportedSchemaVersion(999))
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
