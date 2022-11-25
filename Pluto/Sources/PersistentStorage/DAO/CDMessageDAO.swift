import Combine
import CoreData

struct CDMessageDAO: CoreDataDAO {
    typealias CoreDataObject = CDMessage
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "messageId"
    let pairDAO: CDDIDPairDAO
}
