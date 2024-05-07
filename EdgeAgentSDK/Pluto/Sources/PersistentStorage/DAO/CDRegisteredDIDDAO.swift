import Combine
import CoreData

struct CDRegisteredDIDDAO: CoreDataDAO {
    typealias CoreDataObject = CDRegisteredDID
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "did"
}
