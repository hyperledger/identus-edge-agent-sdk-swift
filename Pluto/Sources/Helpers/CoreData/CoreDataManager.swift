import CoreData
import Foundation

public final class CoreDataManager {
    lazy var editContext: NSManagedObjectContext = persistentContainer.newBackgroundContext()

    lazy var mainContext: NSManagedObjectContext = {
        func mergeChanges(context: NSManagedObjectContext, notification: Notification) {
            guard
                let contextSaved = notification.object as? NSManagedObjectContext,
                self.editContext == contextSaved
            else { return }
            context.perform {
                context.mergeChanges(fromContextDidSave: notification)
            }
        }

        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true

        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidMergeChangesObjectIDs,
            object: nil,
            queue: nil
        ) { [weak context] notification in
            guard let context = context else { return }
            mergeChanges(context: context, notification: notification)
        }

        return context
    }()

    private let setup: CoreDataSetup

    private static var _model: NSManagedObjectModel?

    private(set) lazy var model: NSManagedObjectModel = {
        if let mdl = CoreDataManager._model { return mdl }
        let modelPath: URL
        switch setup.modelPath {
        case let .storeName(name, bundle):
            guard let modelURL = bundle.url(forResource: name, withExtension: "momd") else {
                fatalError("Unable to Find Data Model")
            }
            modelPath = modelURL
        case let .storeURL(modelURL):
            modelPath = modelURL
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelPath) else {
            fatalError("Unable to Load Data Model")
        }
        CoreDataManager._model = managedObjectModel
        return managedObjectModel
    }()

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: self.setup.modelName, managedObjectModel: model)
        if case CoreDataSetup.StoreType.memory = setup.storeType {
            let persistentStoreDescription = NSPersistentStoreDescription()
            persistentStoreDescription.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [persistentStoreDescription]
        }
        persistentContainer.loadPersistentStores { [weak persistentContainer] _, _ in
            persistentContainer?.viewContext.automaticallyMergesChangesFromParent = true
        }
        return persistentContainer
    }()

    private(set) lazy var defaultManagedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext

    public init(setup: CoreDataSetup) {
        self.setup = setup
    }

    public func start() {
        persistentContainer.loadPersistentStores { _, error in
            error.map { assertionFailure($0.localizedDescription) }
        }
    }

    public func delete() throws {
        try persistentContainer
            .persistentStoreCoordinator
            .destroyPersistentStore(
                at: persistentStoreUrl(),
                ofType: "sqlite",
                options: nil
            )
        start()
    }

    private func makeNewContext(
        concurrencyType: NSManagedObjectContextConcurrencyType
    ) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.parent = defaultManagedObjectContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    private func persistentStoreUrl() -> URL {
        let modelName: String
        switch setup.modelPath {
        case let .storeName(value, _):
            modelName = value
        case let .storeURL(value):
            modelName = value.deletingPathExtension().lastPathComponent
        }
        let url = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(modelName).sqlite")

        assert(FileManager.default.fileExists(atPath: url.path))

        return url
    }
}

public extension CoreDataManager {
    struct CoreDataSetup {
        public enum StoreType {
            case memory
            case persistent
        }

        public enum ModelPath {
            case storeName(String, Bundle = ModelKit.bundle)
            case storeURL(URL)
        }

        public let modelPath: ModelPath
        public let storeType: StoreType

        public init(modelPath: ModelPath, storeType: StoreType) {
            self.modelPath = modelPath
            self.storeType = storeType
        }
    }
}

// Helper so the core data model can be found
public enum ModelKit {
    public static let bundle = Bundle.module
}

private extension CoreDataManager.CoreDataSetup {
    var modelName: String {
        switch modelPath {
        case let .storeName(name, _):
            return name
        case let .storeURL(url):
            return url.deletingPathExtension().lastPathComponent
        }
    }
}
