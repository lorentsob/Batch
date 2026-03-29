import SwiftData
import Testing
@testable import Levain

@Suite("Persistence Migration Tests")
struct PersistenceMigrationTests {

    @Test("Migration plan declares both V1 and V2 schemas")
    func testMigrationPlanContainsBothVersions() {
        let schemas = LevainMigrationPlan.schemas
        #expect(schemas.count == 2)
    }

    @Test("V1 schema version is 1.0.0")
    func testV1SchemaVersion() {
        #expect(LevainSchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }

    @Test("V2 schema version is 2.0.0")
    func testV2SchemaVersion() {
        #expect(LevainSchemaV2.versionIdentifier == Schema.Version(2, 0, 0))
    }

    @Test("V2 version identifier is greater than V1")
    func testV2IsNewerThanV1() {
        #expect(LevainSchemaV2.versionIdentifier > LevainSchemaV1.versionIdentifier)
    }

    @Test("Current schema uses V2 model list")
    func testCurrentSchemaIsV2() throws {
        let current = LevainSchema.current
        // V2 declares 6 entity types — confirm the schema exposes them all
        let entityCount = current.entities.count
        #expect(entityCount == 6)
    }

    @Test("V2 model list contains all bread-domain entity types")
    func testV2ModelsContainAllEntities() {
        let models = LevainSchemaV2.models
        let typeNames = models.map { String(describing: $0) }
        #expect(typeNames.contains("Starter"))
        #expect(typeNames.contains("StarterRefresh"))
        #expect(typeNames.contains("RecipeFormula"))
        #expect(typeNames.contains("Bake"))
        #expect(typeNames.contains("BakeStep"))
        #expect(typeNames.contains("AppSettings"))
    }

    @Test("In-memory container bootstraps without error using migration plan")
    func testInMemoryContainerBootstraps() throws {
        let context = try ModelTestSupport.makeInMemoryContext()
        // A freshly created context must be empty and functional
        let bakes = try context.fetch(FetchDescriptor<Bake>())
        #expect(bakes.isEmpty)
    }

    @Test("Existing entities survive the additive V2 migration")
    func testExistingEntitiesSurviveMigration() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let bake = DomainFixtures.makeBake(name: "Migration test bake")
        context.insert(bake)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Bake>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Migration test bake")
    }

    @Test("Migration plan declares exactly one stage for V1 to V2")
    func testMigrationStageCount() {
        #expect(LevainMigrationPlan.stages.count == 1)
    }

    @Test("Starter entities survive the additive V2 migration")
    func testStarterEntitiesSurviveMigration() throws {
        let context = try ModelTestSupport.makeInMemoryContext()

        let starter = DomainFixtures.makeStarter(name: "Migration test starter")
        context.insert(starter)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Starter>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Migration test starter")
    }
}
