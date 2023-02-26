import Combine
import CoreData
import Domain

struct CDDIDDAO: CoreDataDAO {
    typealias CoreDataObject = CDDID
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "did"
}

extension CDDID {
    func parseFrom(did: DID) {
        self.did = did.string
        self.schema = did.schema
        self.method = did.method
        self.methodId = did.methodId
    }
}
