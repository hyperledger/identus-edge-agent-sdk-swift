import Domain
import Foundation

protocol DIDCommConnection {
    var holderDID: DID { get }
    var otherDID: DID { get }
    func awaitMessages() async throws -> [Message]
    func awaitMessageResponse(id: String) async throws -> Message?
}
