import Foundation
import SwiftData

enum ModelContainerFactory {
    enum FactoryError: LocalizedError {
        case applicationSupportDirectoryUnavailable
        case persistentStoreDirectoryCreationFailed(URL, Error)
        case persistentContainerCreationFailed(URL, Error)
        case inMemoryContainerCreationFailed(Error)
        case previewContainerCreationFailed(Error)
        case previewSeedDataFailed(Error)

        var errorDescription: String? {
            switch self {
            case .applicationSupportDirectoryUnavailable:
                return "Application Support directory unavailable for the persistent store."
            case .persistentStoreDirectoryCreationFailed(let url, let error):
                return "Unable to create persistent store directory at \(url.path): \(error.localizedDescription)"
            case .persistentContainerCreationFailed(let url, let error):
                return "Unable to open persistent store at \(url.path): \(error.localizedDescription)"
            case .inMemoryContainerCreationFailed(let error):
                return "Unable to create in-memory model container: \(error.localizedDescription)"
            case .previewContainerCreationFailed(let error):
                return "Unable to create preview model container: \(error.localizedDescription)"
            case .previewSeedDataFailed(let error):
                return "Unable to seed preview model container: \(error.localizedDescription)"
            }
        }
    }

    typealias ContainerBuilder = (ModelConfiguration) throws -> ModelContainer
    typealias PreviewSeedLoader = (ModelContext) throws -> Void

    static func makeContainer() -> ModelContainer {
        do {
            return try makeContainer(
                isTesting: NSClassFromString("XCTestCase") != nil,
                wantsReset: AppLaunchOptions.shouldResetStore
            )
        } catch {
            fatalError("Unable to bootstrap model container: \(error.localizedDescription)")
        }
    }

    static func makeContainer(
        isTesting: Bool,
        wantsReset: Bool,
        baseDirectoryURL: URL? = nil,
        fileManager: FileManager = .default,
        containerBuilder: ContainerBuilder = buildContainer
    ) throws -> ModelContainer {
        if isTesting || wantsReset {
            return try makeInMemoryContainer(containerBuilder: containerBuilder)
        }

        let storeURL = try persistentStoreURL(baseDirectoryURL: baseDirectoryURL, fileManager: fileManager)
        do {
            return try containerBuilder(ModelConfiguration(url: storeURL))
        } catch {
            throw FactoryError.persistentContainerCreationFailed(storeURL, error)
        }
    }

    @MainActor
    static func makePreviewContainer(seed: Bool = true) -> ModelContainer {
        do {
            return try makePreviewContainer(
                seed: seed,
                containerBuilder: buildContainer,
                seedLoader: { context in
                    try SeedDataLoader.ensureSeedData(in: context)
                }
            )
        } catch {
            fatalError("Unable to bootstrap preview model container: \(error.localizedDescription)")
        }
    }

    @MainActor
    static func makePreviewContainer(
        seed: Bool,
        containerBuilder: ContainerBuilder,
        seedLoader: PreviewSeedLoader
    ) throws -> ModelContainer {
        let container: ModelContainer
        do {
            container = try containerBuilder(ModelConfiguration(isStoredInMemoryOnly: true))
        } catch {
            throw FactoryError.previewContainerCreationFailed(error)
        }

        if seed {
            do {
                try seedLoader(container.mainContext)
            } catch {
                throw FactoryError.previewSeedDataFailed(error)
            }
        }

        return container
    }

    private static func makeInMemoryContainer(
        containerBuilder: ContainerBuilder = buildContainer
    ) throws -> ModelContainer {
        do {
            return try containerBuilder(ModelConfiguration(isStoredInMemoryOnly: true))
        } catch {
            throw FactoryError.inMemoryContainerCreationFailed(error)
        }
    }

    private static func buildContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        // All schema changes to date are purely additive (new optional entities).
        // SwiftData's automatic lightweight inference handles these without needing
        // an explicit migration plan, and — critically — works on stores that were
        // created before versioned-schema metadata was ever written to disk.
        // Re-add migrationPlan: only when a breaking (destructive) migration is needed.
        return try ModelContainer(
            for: LevainSchema.current,
            configurations: configuration
        )
    }

    static func persistentStoreURL(
        baseDirectoryURL: URL? = nil,
        fileManager: FileManager = .default
    ) throws -> URL {
        let rootURL: URL
        if let baseDirectoryURL {
            rootURL = baseDirectoryURL
        } else if let applicationSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            rootURL = applicationSupportDirectory
        } else {
            throw FactoryError.applicationSupportDirectoryUnavailable
        }

        let folderURL = rootURL.appendingPathComponent("Levain", isDirectory: true)
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            throw FactoryError.persistentStoreDirectoryCreationFailed(folderURL, error)
        }

        return folderURL.appendingPathComponent("Levain.store")
    }
}
