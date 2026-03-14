import SwiftData
@testable import Levain

enum ModelTestSupport {
    static func makeInMemoryContext() throws -> ModelContext {
        let container = try ModelContainer(
            for: LevainSchema.current,
            migrationPlan: LevainMigrationPlan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }
}
