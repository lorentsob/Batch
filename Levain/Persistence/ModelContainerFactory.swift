import SwiftData

enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: schema)
        } catch {
            return fallbackContainer(after: error)
        }
    }

    @MainActor
    static func makePreviewContainer(seed: Bool = true) -> ModelContainer {
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            if seed {
                try SeedDataLoader.ensureSeedData(in: container.mainContext)
            }
            return container
        } catch {
            return fallbackContainer(after: error, inMemory: true)
        }
    }

    private static let schema = Schema([
        Starter.self,
        StarterRefresh.self,
        RecipeFormula.self,
        Bake.self,
        BakeStep.self,
        AppSettings.self
    ])

    private static func fallbackContainer(after error: Error, inMemory: Bool = false) -> ModelContainer {
        assertionFailure("Unable to create model container: \(error)")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Unable to create fallback model container: \(error)")
        }
    }
}
