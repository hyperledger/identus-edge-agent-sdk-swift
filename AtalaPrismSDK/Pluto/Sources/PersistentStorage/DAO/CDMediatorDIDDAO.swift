import Combine
import CoreData

struct CDMediatorDIDDAO: CoreDataDAO {
    typealias CoreDataObject = CDMediatorDID
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "mediatorId"
    let didDAO: CDDIDDAO
    let privateKeyDIDDao: CDDIDPrivateKeyDAO
}
