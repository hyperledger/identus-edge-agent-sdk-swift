import Combine
import CoreData

struct CDLinkSecretDAO: CoreDataDAO {
    typealias CoreDataObject = CDLinkSecret
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "secret"
}
