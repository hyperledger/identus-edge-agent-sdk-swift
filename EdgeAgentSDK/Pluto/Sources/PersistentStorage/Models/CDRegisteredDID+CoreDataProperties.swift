import CoreData
import Foundation

extension CDRegisteredDID {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDRegisteredDID> {
        return NSFetchRequest<CDRegisteredDID>(entityName: "CDRegisteredDID")
    }

    @NSManaged var keyIndex: Int64
    @NSManaged var alias: String?
}
