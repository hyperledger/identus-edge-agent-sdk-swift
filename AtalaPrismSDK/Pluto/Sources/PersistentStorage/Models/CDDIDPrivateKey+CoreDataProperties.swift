import CoreData
import Foundation

extension CDDIDPrivateKey {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDDIDPrivateKey> {
        return NSFetchRequest<CDDIDPrivateKey>(entityName: "CDDIDPrivateKey")
    }

    @NSManaged var alias: String?
    @NSManaged var pair: CDDIDPair?
    @NSManaged var keys: Set<CDKey>
}

extension CDDIDPrivateKey {
    @objc(addKeysObject:)
    @NSManaged func addToKeys(_ value: CDKey)

    @objc(removeKeysObject:)
    @NSManaged func removeFromKeys(_ value: CDKey)

    @objc(addKeys:)
    @NSManaged func addToKeys(_ values: Set<CDKey>)

    @objc(removeKeys:)
    @NSManaged func removeFromKeys(_ values: Set<CDKey>)
}
