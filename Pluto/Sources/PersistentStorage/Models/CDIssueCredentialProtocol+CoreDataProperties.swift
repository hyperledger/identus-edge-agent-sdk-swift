import CoreData
import Foundation

extension CDIssueCredentialProtocol {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDIssueCredentialProtocol> {
        return NSFetchRequest<CDIssueCredentialProtocol>(entityName: "CDIssueCredentialProtocol")
    }

    @NSManaged var protocolId: String
    @NSManaged var threadId: String?
    @NSManaged var credential: CDVerifiableCredential?
    @NSManaged var issue: CDMessage?
    @NSManaged var offer: CDMessage?
    @NSManaged var propose: CDMessage?
    @NSManaged var request: CDMessage?
}
