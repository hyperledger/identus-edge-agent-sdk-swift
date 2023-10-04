import Combine
import CoreData
import Domain

struct CDDIDPrivateKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDDIDPrivateKey
    let keychain: KeychainStore & KeychainProvider
    let keychainService: String
    let keyDao: CDKeyDAO
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "did"
}
