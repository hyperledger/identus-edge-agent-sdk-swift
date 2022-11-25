import CoreData
import Foundation

extension CDDID {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDDID> {
        return NSFetchRequest<CDDID>(entityName: "CDDID")
    }

    @NSManaged var did: String
    @NSManaged var schema: String
    @NSManaged var method: String
    @NSManaged var methodId: String
}

extension CDDID: Identifiable {
    public var id: String { did }
}
