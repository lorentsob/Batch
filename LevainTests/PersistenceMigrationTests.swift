import Foundation
import SwiftData
import Testing
@testable import Levain

@Suite("Persistence Migration Tests")
struct PersistenceMigrationTests {

    @Test("Migration plan declares the unique live schema versions only")
    func testMigrationPlanContainsUniqueLiveVersions() {
        let schemas = LevainMigrationPlan.schemas
        #expect(schemas.count == 3)
        #expect(schemas[0].versionIdentifier == LevainSchemaV1.versionIdentifier)
        #expect(schemas[1].versionIdentifier == LevainSchemaV3.versionIdentifier)
        #expect(schemas[2].versionIdentifier == LevainSchemaV4.versionIdentifier)
    }

    @Test("V1 schema version is 1.0.0")
    func testV1SchemaVersion() {
        #expect(LevainSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }

    @Test("V2 schema version is 2.0.0")
    func testV2SchemaVersion() {
        #expect(LevainSchemaV2.versionIdentifier == Schema.Version(2, 0, 0))
    }

    @Test("V3 schema version is 3.0.0")
    func testV3SchemaVersion() {
        #expect(LevainSchemaV3.versionIdentifier == Schema.Version(3, 0, 0))
    }

    @Test("V4 schema version is 4.0.0")
    func testV4SchemaVersion() {
        #expect(LevainSchemaV4.versionIdentifier == Schema.Version(4, 0, 0))
    }

    @Test("Version identifiers remain ordered across historical and live schemas")
    func testVersionOrdering() {
        #expect(LevainSchemaV2.versionIdentifier > LevainSchemaV1.versionIdentifier)
        #expect(LevainSchemaV3.versionIdentifier > LevainSchemaV2.versionIdentifier)
        #expect(LevainSchemaV4.versionIdentifier > LevainSchemaV3.versionIdentifier)
    }

    @Test("Current schema uses V4 model list")
    func testCurrentSchemaIsV4() throws {
        let current = LevainSchema.current
        // V4 declares 8 entity types, adding KefirEvent additively beside KefirBatch.
        let entityCount = current.entities.count
        #expect(entityCount == 8)
    }

    @Test("V4 model list contains all legacy entities plus kefir models")
    func testV4ModelsContainAllEntities() {
        let models = LevainSchemaV4.models
        let typeNames = models.map { String(describing: $0) }
        #expect(typeNames.contains("Starter"))
        #expect(typeNames.contains("StarterRefresh"))
        #expect(typeNames.contains("RecipeFormula"))
        #expect(typeNames.contains("Bake"))
        #expect(typeNames.contains("BakeStep"))
        #expect(typeNames.contains("AppSettings"))
        #expect(typeNames.contains("KefirBatch"))
        #expect(typeNames.contains("KefirEvent"))
    }

    @Test("In-memory container bootstraps without error using migration plan")
    func testInMemoryContainerBootstraps() throws {
        let context = try ModelTestSupport.makeInMemoryContext()
        // A freshly created context must be empty and functional
        let bakes = try context.fetch(FetchDescriptor<Bake>())
        #expect(bakes.isEmpty)
    }

    @Test("Existing bread entities survive the additive V3 schema")
    func testExistingEntitiesSurviveMigration() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let bake = DomainFixtures.makeBake(name: "Migration test bake")
        context.insert(bake)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Bake>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Migration test bake")
    }

    @Test("Migration plan declares exactly two additive stages between unique checksums")
    func testMigrationStageCount() {
        #expect(LevainMigrationPlan.stages.count == 2)
    }

    @Test("Starter entities survive the additive V3 migration")
    func testStarterEntitiesSurviveMigration() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let starter = DomainFixtures.makeStarter(name: "Migration test starter")
        context.insert(starter)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Starter>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Migration test starter")
    }

    @Test("Kefir batches persist without requiring a culture model")
    func testKefirBatchesPersist() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let roomBatch = DomainFixtures.makeKefirBatch(name: "Batch cucina")
        let derivedBatch = DomainFixtures.makeKefirBatch(
            name: "Batch frigo",
            storageMode: .fridge,
            sourceBatchId: roomBatch.id
        )

        context.insert(roomBatch)
        context.insert(derivedBatch)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<KefirBatch>())
        #expect(fetched.count == 2)
        #expect(fetched.contains { $0.sourceBatchId == roomBatch.id })
    }

    @Test("Kefir events persist additively beside batches")
    func testKefirEventsPersist() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let batch = DomainFixtures.makeKefirBatch(name: "Batch eventi")
        let event = DomainFixtures.makeKefirEvent(
            batchID: batch.id,
            kind: .created,
            storageMode: .roomTemperature,
            expectedRoutineHours: 24
        )

        context.insert(batch)
        context.insert(event)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<KefirEvent>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.batchID == batch.id)
        #expect(fetched.first?.kind == .created)
    }
}

@Suite("Model Container Factory Tests")
struct ModelContainerFactoryTests {
    private enum SampleError: Error, Equatable {
        case forcedFailure
    }

    @Test("Persistent store URL is rooted under a Levain subdirectory")
    func testPersistentStoreURLUsesLevainFolder() throws {
        let fileManager = FileManager.default
        let baseDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? fileManager.removeItem(at: baseDirectoryURL) }

        try fileManager.createDirectory(at: baseDirectoryURL, withIntermediateDirectories: true)
        let storeURL = try ModelContainerFactory.persistentStoreURL(baseDirectoryURL: baseDirectoryURL, fileManager: fileManager)

        #expect(storeURL.lastPathComponent == "Levain.store")
        #expect(storeURL.deletingLastPathComponent().lastPathComponent == "Levain")
    }

    @Test("Persistent bootstrap surfaces store directory failures explicitly")
    func testPersistentBootstrapSurfacesDirectoryFailure() throws {
        let fileManager = FileManager.default
        let blockedURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? fileManager.removeItem(at: blockedURL) }

        try Data("blocked".utf8).write(to: blockedURL)

        do {
            _ = try ModelContainerFactory.makeContainer(
                isTesting: false,
                wantsReset: false,
                baseDirectoryURL: blockedURL,
                fileManager: fileManager
            )
            Issue.record("Expected persistent store directory failure")
        } catch let error as ModelContainerFactory.FactoryError {
            switch error {
            case .persistentStoreDirectoryCreationFailed(let folderURL, _):
                #expect(folderURL.lastPathComponent == "Levain")
            default:
                Issue.record("Unexpected factory error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test("Persistent bootstrap surfaces container creation failures explicitly")
    func testPersistentBootstrapSurfacesBuilderFailure() throws {
        let fileManager = FileManager.default
        let baseDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? fileManager.removeItem(at: baseDirectoryURL) }

        try fileManager.createDirectory(at: baseDirectoryURL, withIntermediateDirectories: true)

        do {
            _ = try ModelContainerFactory.makeContainer(
                isTesting: false,
                wantsReset: false,
                baseDirectoryURL: baseDirectoryURL,
                fileManager: fileManager,
                containerBuilder: { _ in throw SampleError.forcedFailure }
            )
            Issue.record("Expected persistent container creation failure")
        } catch let error as ModelContainerFactory.FactoryError {
            switch error {
            case .persistentContainerCreationFailed(let storeURL, let underlying as SampleError):
                #expect(storeURL.lastPathComponent == "Levain.store")
                #expect(underlying == .forcedFailure)
            default:
                Issue.record("Unexpected factory error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @MainActor
    @Test("Preview seed failures surface explicitly")
    func testPreviewSeedFailureIsExplicit() throws {
        do {
            _ = try ModelContainerFactory.makePreviewContainer(
                seed: true,
                containerBuilder: { configuration in
                    try ModelContainer(
                        for: LevainSchema.current,
                        migrationPlan: LevainMigrationPlan.self,
                        configurations: configuration
                    )
                },
                seedLoader: { _ in throw SampleError.forcedFailure }
            )
            Issue.record("Expected preview seed failure")
        } catch let error as ModelContainerFactory.FactoryError {
            switch error {
            case .previewSeedDataFailed(let underlying as SampleError):
                #expect(underlying == .forcedFailure)
            default:
                Issue.record("Unexpected factory error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
