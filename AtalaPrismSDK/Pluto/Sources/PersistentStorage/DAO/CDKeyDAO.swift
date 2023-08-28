import Combine
import CoreData
import Domain

struct CDKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDKey
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "identifier"
}
