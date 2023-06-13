import Combine
import CoreData
import Domain

struct CDDIDPrivateKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDDIDPrivateKey
    let keyRestoration: KeyRestoration
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "did"
}
