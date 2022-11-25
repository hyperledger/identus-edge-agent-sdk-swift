import CoreData
import Foundation

extension CDMediatorDID {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDMediatorDID> {
        return NSFetchRequest<CDMediatorDID>(entityName: "CDMediatorDID")
    }

    @NSManaged var mediatorId: String
    @NSManaged var url: URL
    @NSManaged var routingDID: CDDID
    @NSManaged var peerDID: CDDIDPrivateKey
}

extension CDMediatorDID: Identifiable {
    public var id: String { mediatorId }
}
