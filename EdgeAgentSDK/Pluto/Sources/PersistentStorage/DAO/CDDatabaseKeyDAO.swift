import Combine
import CoreData
import Domain

struct CDDatabaseKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDDatabaseKey
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "identifier"
}
