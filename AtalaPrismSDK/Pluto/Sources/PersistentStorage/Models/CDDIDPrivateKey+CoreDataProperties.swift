import CoreData
import Foundation

extension CDDIDPrivateKey {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDDIDPrivateKey> {
        return NSFetchRequest<CDDIDPrivateKey>(entityName: "CDDIDPrivateKey")
    }

    // TODO: For time reasons the solution was to add this fields. In the future change this to be an array.
    @NSManaged var privateKeyAuthenticate: Data?
    @NSManaged var privateKeyKeyAgreement: Data?
    @NSManaged var curveKeyAgreement: String?
    @NSManaged var curveAuthenticate: String?
    @NSManaged var alias: String?
    @NSManaged var pair: CDDIDPair?
}
