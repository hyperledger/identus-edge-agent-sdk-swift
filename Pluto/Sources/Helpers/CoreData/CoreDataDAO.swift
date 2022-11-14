import CoreData

protocol CoreDataDAO {
    associatedtype CoreDataObject: NSManagedObject
    var identifierKey: String? { get }
}

extension CoreDataDAO {
    func newEntity(context: NSManagedObjectContext) -> CoreDataObject {
        CoreDataObject(entity: CoreDataObject.entity(), insertInto: context)
    }

    func fetch(
        predicate: NSPredicate? = nil,
        sorting: NSSortDescriptor? = nil,
        fetchLimit: Int? = nil,
        context: NSManagedObjectContext
    ) -> Set<CoreDataObject> {
        let request = CoreDataObject.fetchRequest()
        request.predicate = predicate
        fetchLimit.map { request.fetchLimit = $0 }
        sorting.map { request.sortDescriptors = [$0] }
        let items = (try? context.fetch(request) as? [CoreDataObject]) ?? []
        return Set(items)
    }

    func delete(predicate: NSPredicate? = nil, context: NSManagedObjectContext) throws {
        let fetchRequest = CoreDataObject.fetchRequest()
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        guard
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult,
            let objects = result.result as? [NSManagedObjectID]
        else {
            return
        }
        let changes: [AnyHashable: Any] = [
            NSDeletedObjectsKey: objects
        ]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
    }

    func deleteAll(context: NSManagedObjectContext) throws {
        try delete(predicate: nil, context: context)
    }
}

extension CoreDataDAO where CoreDataObject: Identifiable {
    func fetchByID(_ identifier: CoreDataObject.ID, context: NSManagedObjectContext) -> CoreDataObject? {
        guard let key = identifierKey else {
            assertionFailure("""
            The identityKey is nil, please set up the identityKey when you have an Identifiable object
            """)
            return nil
        }
        return fetch(predicate: NSPredicate(format: "%K == %@", key, "\(identifier)"), context: context).first
    }

    func deleteByID(_ identifier: CoreDataObject.ID, context: NSManagedObjectContext) throws {
        guard let key = identifierKey else {
            assertionFailure("""
            The identityKey is nil, please set up the identityKey when you have an Identifiable object
            """)
            return
        }
        try delete(predicate: NSPredicate(format: "%K == %@", key, "\(identifier)"), context: context)
    }
}
