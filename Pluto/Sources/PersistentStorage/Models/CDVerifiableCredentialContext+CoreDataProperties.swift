import CoreData
import Foundation

extension CDVerifiableCredentialContext {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDVerifiableCredentialContext> {
        return NSFetchRequest<CDVerifiableCredentialContext>(entityName: "CDVerifiableCredentialContext")
    }

    @NSManaged var name: String
    @NSManaged var credentials: Set<CDVerifiableCredential>
}

extension CDVerifiableCredentialContext {
    @objc(addCredentialsObject:)
    @NSManaged func addToCredentials(_ value: CDVerifiableCredential)

    @objc(removeCredentialsObject:)
    @NSManaged func removeFromCredentials(_ value: CDVerifiableCredential)

    @objc(addCredentials:)
    @NSManaged func addToCredentials(_ values: Set<CDVerifiableCredential>)

    @objc(removeCredentials:)
    @NSManaged func removeFromCredentials(_ values: Set<CDVerifiableCredential>)
}

extension CDVerifiableCredentialContext: Identifiable {
    var id: String { name }
}
