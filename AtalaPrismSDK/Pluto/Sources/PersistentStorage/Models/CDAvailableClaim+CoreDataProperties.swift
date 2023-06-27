import CoreData
import Foundation

extension CDAvailableClaim {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDAvailableClaim> {
        return NSFetchRequest<CDAvailableClaim>(entityName: "CDAvailableClaim")
    }

    @NSManaged var value: String
    @NSManaged var credential: CDCredential
}

extension CDAvailableClaim: Identifiable {
    var id: String { value }
}
