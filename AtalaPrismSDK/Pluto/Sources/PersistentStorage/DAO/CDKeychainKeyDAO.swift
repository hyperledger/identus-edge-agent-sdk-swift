import Combine
import CoreData
import Domain

struct CDKeychainKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDKeychainKey
    let keychain: KeychainStore & KeychainProvider
    let keychainService: String
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "identifier"
}
