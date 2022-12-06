import CoreData
import Foundation

extension CDVerifiableCredentialType {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDVerifiableCredentialType> {
        return NSFetchRequest<CDVerifiableCredentialType>(entityName: "CDVerifiableCredentialType")
    }

    @NSManaged var name: String
    @NSManaged var credentials: Set<CDVerifiableCredential>
}

// MARK: Generated accessors for credentials
extension CDVerifiableCredentialType {
    @objc(addCredentialsObject:)
    @NSManaged func addToCredentials(_ value: CDVerifiableCredential)

    @objc(removeCredentialsObject:)
    @NSManaged func removeFromCredentials(_ value: CDVerifiableCredential)

    @objc(addCredentials:)
    @NSManaged func addToCredentials(_ values: Set<CDVerifiableCredential>)

    @objc(removeCredentials:)
    @NSManaged func removeFromCredentials(_ values: Set<CDVerifiableCredential>)
}

extension CDVerifiableCredentialType: Identifiable {
    var id: String { name }
}
