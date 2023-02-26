import Combine
import CoreData

struct CDVerifiableCredentialDAO: CoreDataDAO {
    typealias CoreDataObject = CDVerifiableCredential
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "credentialId"
    let didDAO: CDDIDDAO
}
