import Combine
import CoreData

struct CDDIDPairDAO: CoreDataDAO {
    typealias CoreDataObject = CDDIDPair
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "did"
    let privateKeyDIDDAO: CDDIDPrivateKeyDAO
}
