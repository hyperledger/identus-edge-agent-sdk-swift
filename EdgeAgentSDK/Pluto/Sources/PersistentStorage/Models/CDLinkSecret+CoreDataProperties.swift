import CoreData
import Foundation

extension CDLinkSecret {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDLinkSecret> {
        return NSFetchRequest<CDLinkSecret>(entityName: "CDLinkSecret")
    }

    @NSManaged var secret: String
}

extension CDLinkSecret: Identifiable {
    var id: String { secret }
}
