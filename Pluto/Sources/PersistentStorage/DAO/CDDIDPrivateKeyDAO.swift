import Combine
import CoreData

struct CDDIDPrivateKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDDIDPrivateKey
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "did"
}
