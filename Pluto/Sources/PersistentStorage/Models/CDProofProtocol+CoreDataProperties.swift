import CoreData
import Foundation

extension CDProofProtocol {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDProofProtocol> {
        return NSFetchRequest<CDProofProtocol>(entityName: "CDProofProtocol")
    }

    @NSManaged var protocolId: String
    @NSManaged var threadId: String?
    @NSManaged var presentation: CDMessage?
    @NSManaged var propose: CDMessage?
    @NSManaged var request: CDMessage?
}
