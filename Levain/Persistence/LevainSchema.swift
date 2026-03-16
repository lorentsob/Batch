import SwiftData

/// Central source of truth for the current SwiftData schema.
/// Adding optional (String?) properties does not require explicit migration —
/// SwiftData handles them automatically.
enum LevainSchema {
    static var current: Schema {
        Schema(LevainSchemaV1.models)
    }
}

// MARK: - V1

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

// MARK: - Migration Plan

enum LevainMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LevainSchemaV1.self]
    }

    // No explicit stages needed: new String? optional columns are migrated
    // automatically by SwiftData without requiring a version bump.
    static var stages: [MigrationStage] {
        []
    }
}
