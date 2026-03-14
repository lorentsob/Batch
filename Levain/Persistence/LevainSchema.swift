import SwiftData

/// Central source of truth for the current SwiftData schema.
/// Every persisted-model change must go through an explicit schema version bump.
enum LevainSchema {
    static var current: Schema {
        Schema(LevainSchemaV1.models)
    }
}

enum LevainSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [
            Starter.self,
            StarterRefresh.self,
            RecipeFormula.self,
            Bake.self,
            BakeStep.self,
            AppSettings.self
        ]
    }
}

enum LevainMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LevainSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
