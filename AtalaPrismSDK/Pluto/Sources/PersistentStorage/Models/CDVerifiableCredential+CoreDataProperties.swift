import CoreData
import Foundation

extension CDVerifiableCredential {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDVerifiableCredential> {
        return NSFetchRequest<CDVerifiableCredential>(entityName: "CDVerifiableCredential")
    }

    @NSManaged var credentialType: String
    @NSManaged var schemaId: String?
    @NSManaged var credentialId: String
    @NSManaged var issuanceDate: Date
    @NSManaged var verifiableCredetialJson: Data
    @NSManaged var expirationDate: Date?
    @NSManaged var issuer: CDDID
    @NSManaged var context: Set<CDVerifiableCredentialContext>
    @NSManaged var type: Set<CDVerifiableCredentialType>
    @NSManaged var originalJWT: String?
}

extension CDVerifiableCredential {
    @objc(addContextObject:)
    @NSManaged func addToContext(_ value: CDVerifiableCredentialContext)

    @objc(removeContextObject:)
    @NSManaged func removeFromContext(_ value: CDVerifiableCredentialContext)

    @objc(addContext:)
    @NSManaged func addToContext(_ values: Set<CDVerifiableCredentialContext>)

    @objc(removeContext:)
    @NSManaged func removeFromContext(_ values: Set<CDVerifiableCredentialContext>)
}

extension CDVerifiableCredential {
    @objc(addTypeObject:)
    @NSManaged func addToType(_ value: CDVerifiableCredentialType)

    @objc(removeTypeObject:)
    @NSManaged func removeFromType(_ value: CDVerifiableCredentialType)

    @objc(addType:)
    @NSManaged func addToType(_ values: Set<CDVerifiableCredentialType>)

    @objc(removeType:)
    @NSManaged func removeFromType(_ values: Set<CDVerifiableCredentialType>)
}

extension CDVerifiableCredential: Identifiable {
    var id: String { credentialId }
}
