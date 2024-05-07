import CoreData
import Foundation

extension CDCredential {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDCredential> {
        return NSFetchRequest<CDCredential>(entityName: "CDCredential")
    }

    @NSManaged var storingId: String
    @NSManaged var recoveryId: String
    @NSManaged var credentialData: Data
    @NSManaged var queryIssuer: String?
    @NSManaged var querySubject: String?
    @NSManaged var queryCredentialCreated: Date?
    @NSManaged var queryCredentialUpdated: Date?
    @NSManaged var queryCredentialSchema: String?
    @NSManaged var queryValidUntil: Date?
    @NSManaged var queryRevoked: NSNumber?
    @NSManaged var queryAvailableClaims: Set<CDAvailableClaim>
}

extension CDCredential {
    @objc(addQueryAvailableClaimsObject:)
    @NSManaged func addToQueryAvailableClaims(_ value: CDAvailableClaim)

    @objc(removeQueryAvailableClaimsObject:)
    @NSManaged func removeFromQueryAvailableClaims(_ value: CDAvailableClaim)

    @objc(addQueryAvailableClaims:)
    @NSManaged func addToQueryAvailableClaims(_ values: Set<CDAvailableClaim>)

    @objc(removeQueryAvailableClaims:)
    @NSManaged func removeFromQueryAvailableClaims(_ values: Set<CDAvailableClaim>)
}

extension CDCredential: Identifiable {
    var id: String { storingId }
}
