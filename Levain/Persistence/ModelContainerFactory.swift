import Foundation
import SwiftData

enum ModelContainerFactory {
    static func makeContainer() -> ModelContainer {
        let isTesting = NSClassFromString("XCTestCase") != nil
        if isTesting {
            return makeInMemoryContainer()
        }

        let storeURL = persistentStoreURL()
        do {
            return try makePersistentContainer(at: storeURL)
        } catch {
            #if DEBUG
            if erasePersistentStore(at: storeURL) {
                if let container = try? makePersistentContainer(at: storeURL) {
                    return container
                }
            }
            #endif
            return fallbackContainer(after: error, inMemory: true)
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

    private static func makeInMemoryContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            return fallbackContainer(after: error, inMemory: true)
        }
    }

    private static func makePersistentContainer(at url: URL) throws -> ModelContainer {
        let configuration = ModelConfiguration(url: url)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    private static func persistentStoreURL() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let rootURL = baseURL ?? FileManager.default.temporaryDirectory
        let folderURL = rootURL.appendingPathComponent("Levain", isDirectory: true)
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        return folderURL.appendingPathComponent("Levain.store")
    }

    private static func erasePersistentStore(at url: URL) -> Bool {
        let fileManager = FileManager.default
        let shmURL = URL(fileURLWithPath: url.path + "-shm")
        let walURL = URL(fileURLWithPath: url.path + "-wal")
        let candidates = [url, shmURL, walURL]
        var removedAny = false

        for candidate in candidates where fileManager.fileExists(atPath: candidate.path) {
            do {
                try fileManager.removeItem(at: candidate)
                removedAny = true
            } catch {
                assertionFailure("Unable to remove persistent store at \(candidate): \(error)")
            }
        }

        return removedAny
    }

    private static func fallbackContainer(after error: Error, inMemory: Bool = true) -> ModelContainer {
        assertionFailure("Unable to create model container: \(error)")
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Unable to create in-memory fallback model container: \(error)")
        }
    }
}
