import CoreData
import CryptoKit
import Foundation

extension CDDatabaseKey {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDDatabaseKey> {
        return NSFetchRequest<CDDatabaseKey>(entityName: "CDDatabaseKey")
    }

    @NSManaged var storableData: Data
}
