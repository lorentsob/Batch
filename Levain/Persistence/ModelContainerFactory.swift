import Foundation
import SwiftData

enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        // Use an isolated in-memory store when running under XCTest *or* when
        // a UI test has explicitly requested a clean store via launch options.
        let isTesting = NSClassFromString("XCTestCase") != nil
        let wantsReset = AppLaunchOptions.shouldResetStore
        if isTesting || wantsReset {
            return makeInMemoryContainer()
        }

        let storeURL = persistentStoreURL()
        do {
            return try makePersistentContainer(at: storeURL)
        } catch {
            return fallbackContainer(after: error, inMemory: true)
        }
    }

    @MainActor
    static func makePreviewContainer(seed: Bool = true) -> ModelContainer {
        do {
            let container = try ModelContainer(
                for: LevainSchema.current,
                migrationPlan: LevainMigrationPlan.self,
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

    private static func makeInMemoryContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: LevainSchema.current,
                migrationPlan: LevainMigrationPlan.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            return fallbackContainer(after: error, inMemory: true)
        }
    }

    private static func makePersistentContainer(at url: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(url: url)
        return try ModelContainer(
            for: LevainSchema.current,
            migrationPlan: LevainMigrationPlan.self,
            configurations: configuration
        )
    }

    private static func persistentStoreURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let rootURL = baseURL ?? FileManager.default.temporaryDirectory
        let folderURL = rootURL.appendingPathComponent("Levain", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        return folderURL.appendingPathComponent("Levain.store")
    }

    private static func fallbackContainer(after error: Error, inMemory: Bool = true) -> ModelContainer {
        assertionFailure("Unable to create persistent model container without mutating the existing store: \(error)")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(
                for: LevainSchema.current,
                migrationPlan: LevainMigrationPlan.self,
                configurations: configuration
            )
        } catch {
            fatalError("Unable to create in-memory fallback model container: \(error)")
        }
    }
}
