import SwiftData

enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Unable to create model container: \(error)")
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
            fatalError("Unable to create model container: \(error)")
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
}
