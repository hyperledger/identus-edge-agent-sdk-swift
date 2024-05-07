import CoreData
import Foundation

extension CDDIDPair {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDDIDPair> {
        return NSFetchRequest<CDDIDPair>(entityName: "CDDIDPair")
    }

    @NSManaged var name: String?
    @NSManaged var holderDID: CDDIDPrivateKey
    @NSManaged var messages: [CDMessage]
}
