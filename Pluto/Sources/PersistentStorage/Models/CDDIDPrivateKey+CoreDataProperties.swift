import CoreData
import Foundation

extension CDDIDPrivateKey {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDDIDPrivateKey> {
        return NSFetchRequest<CDDIDPrivateKey>(entityName: "CDDIDPrivateKey")
    }

    @NSManaged var privateKey: Data
    @NSManaged var curve: String
    @NSManaged var pair: CDDIDPair?
}
