import SwiftData

/// Central source of truth for the current SwiftData schema.
/// Adding optional (String?) properties does not require explicit migration —
/// SwiftData handles them automatically.
enum LevainSchema {
    static var current: Schema {
        Schema(LevainSchemaV4.models)
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
// Historical milestone boundary introduced for the v2 multi-fermentation shell.
// It intentionally stays out of the live migration plan because its model list
// is identical to V1, and SwiftData rejects duplicate schema checksums across
// migration stages.

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

// MARK: - V3
// Phase 19 adds the persisted batch-first Kefir model while preserving the
// existing bread and starter entities unchanged.

enum LevainSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(3, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [
            Starter.self,
            StarterRefresh.self,
            RecipeFormula.self,
            Bake.self,
            BakeStep.self,
            AppSettings.self,
            KefirBatch.self
        ]
    }
}

// MARK: - V4
// Phase 20 adds typed kefir lifecycle events additively beside the persisted
// batch model introduced in V3.

enum LevainSchemaV4: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(4, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [
            Starter.self,
            StarterRefresh.self,
            RecipeFormula.self,
            Bake.self,
            BakeStep.self,
            AppSettings.self,
            KefirBatch.self,
            KefirEvent.self
        ]
    }
}

// MARK: - Migration Plan
//
// NOTE: LevainMigrationPlan is NOT passed to ModelContainer at runtime.
// All schema changes to date are additive (new optional entities), so
// SwiftData's automatic lightweight inference is used instead. Stores created
// before versioned-schema metadata existed on disk would fail staged migration
// with "unknown model version". Re-activate this plan only when a breaking
// (destructive/rename) migration is required.

enum LevainMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LevainSchemaV1.self, LevainSchemaV3.self, LevainSchemaV4.self]
    }

    static var stages: [MigrationStage] {
        [v1ToV3, v3ToV4]
    }

    private static let v1ToV3 = MigrationStage.lightweight(
        fromVersion: LevainSchemaV1.self,
        toVersion: LevainSchemaV3.self
    )

    private static let v3ToV4 = MigrationStage.lightweight(
        fromVersion: LevainSchemaV3.self,
        toVersion: LevainSchemaV4.self
    )
}
