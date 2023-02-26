import Combine
import CoreData
import Foundation

extension CoreDataDAO {
    func fetchController(
        predicate: NSPredicate? = nil,
        sorting: NSSortDescriptor? = nil,
        fetchLimit: Int? = nil,
        context: NSManagedObjectContext
    ) -> AnyPublisher<[CoreDataObject], Error> {
        let request = CoreDataObject.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sorting.map { [$0] } ?? [NSSortDescriptor(key: identifierKey, ascending: true)]
        fetchLimit.map { request.fetchLimit = $0 }

        return context
            .fetchPublisher(request: request)
            .map { $0 as? [CoreDataObject] ?? [] }
            .map {
                let unique = Set($0)
                return Array(unique)
            }
            .eraseToAnyPublisher()
    }

    func fetchByKeyValuePublisher(
        key: String,
        value: CustomStringConvertible,
        context: NSManagedObjectContext
    ) -> AnyPublisher<[CoreDataObject], Error> {
        return fetchController(
            predicate: NSPredicate(format: "%K == %@", key, "\(value)"),
            context: context
        )
        .eraseToAnyPublisher()
    }

    func deletePublisher(predicate: NSPredicate? = nil, context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return context.write {
            try delete(predicate: predicate, context: $0)
        }
        .eraseToAnyPublisher()
    }

    func deleteAllPublisher(context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return context.write {
            try deleteAll(context: $0)
        }
        .eraseToAnyPublisher()
    }
}

extension CoreDataDAO where CoreDataObject: Identifiable {
    func updateOrCreate(
        _ id: CoreDataObject.ID,
        context: NSManagedObjectContext,
        modify: @escaping (CoreDataObject, NSManagedObjectContext) throws -> Void
    ) -> AnyPublisher<CoreDataObject.ID, Error> {
        context.write { context in
            try modify(self.fetchByID(id, context: context) ?? self.newEntity(context: context), context)
            return id
        }
        .eraseToAnyPublisher()
    }

    func fetchByIDsPublisher(
        _ identifier: CoreDataObject.ID,
        context: NSManagedObjectContext
    ) -> AnyPublisher<CoreDataObject?, Error> {
        guard let key = identifierKey else {
            assertionFailure("""
            The identityKey is nil, please set up the identityKey when you have an Identifiable object
            """)
            return Just(nil).tryMap { $0 }.eraseToAnyPublisher()
        }
        return fetchController(
            predicate: NSPredicate(format: "%K == %@", key, "\(identifier)"),
            context: context
        )
        .map { $0.first }
        .eraseToAnyPublisher()
    }

    func deleteByIDsPublisher(
        _ identifiers: [CoreDataObject.ID],
        context: NSManagedObjectContext
    ) -> AnyPublisher<Void, Error> {
        guard let key = identifierKey else {
            assertionFailure("""
            The identityKey is nil, please set up the identityKey when you have an Identifiable object
            """)
            return Just(()).tryMap { $0 }.eraseToAnyPublisher()
        }
        return deletePublisher(predicate: NSPredicate(format: "\(key) IN %@", identifiers), context: context)
    }
}
