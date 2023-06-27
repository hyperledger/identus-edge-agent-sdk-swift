import Combine
import CoreData

struct CDCredentialDAO: CoreDataDAO {
    typealias CoreDataObject = CDCredential
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "storingId"
}
