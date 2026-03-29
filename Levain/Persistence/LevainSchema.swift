import SwiftData

/// Central source of truth for the current SwiftData schema.
/// Adding optional (String?) properties does not require explicit migration —
/// SwiftData handles them automatically.
enum LevainSchema {
    static var current: Schema {
        Schema(LevainSchemaV2.models)
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

// MARK: - V2
// Additive milestone boundary introduced for the v2 multi-fermentation shell.
// No model is added or removed yet — this version checkpoint reserves the
// migration path before Phase 19 adds KefirBatch and related types.

enum LevainSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
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
        [LevainSchemaV1.self, LevainSchemaV2.self]
    }

    // V1 → V2 is a lightweight additive stage. No column changes; the version
    // boundary is declared now so Phase 19 can append a second stage when
    // KefirBatch is introduced without improvising schema work.
    static var stages: [MigrationStage] {
        [v1ToV2]
    }

    private static let v1ToV2 = MigrationStage.lightweight(
        fromVersion: LevainSchemaV1.self,
        toVersion: LevainSchemaV2.self
    )
}
