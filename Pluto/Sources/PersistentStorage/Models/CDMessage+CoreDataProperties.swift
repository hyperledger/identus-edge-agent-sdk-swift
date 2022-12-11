import CoreData
import Foundation

extension CDMessage {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDMessage> {
        return NSFetchRequest<CDMessage>(entityName: "CDMessage")
    }

    @NSManaged var messageId: String
    @NSManaged var type: String
    @NSManaged var dataJson: Data
    @NSManaged var createdTime: Date
    @NSManaged var from: String?
    @NSManaged var to: String?
    @NSManaged var thid: String?
    @NSManaged var direction: String?
    @NSManaged var pair: CDDIDPair?
}

extension CDMessage: Identifiable {
    public var id: String { messageId }
}
