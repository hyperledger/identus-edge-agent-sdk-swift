import CoreData

extension NSManagedObjectContext {
    func saveWithBlock(
        block: @escaping ((_ localContext: NSManagedObjectContext) throws -> Void)
    ) throws {
        var lastError: Error?
        performAndWait { [weak self] in
            do {
                guard let self = self else { return }
                try block(self)
                try self.save()
            } catch {
                lastError = error
            }
        }
        if let error = lastError { throw error }
    }
}
