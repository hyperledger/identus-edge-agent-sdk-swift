import Domain
@testable import PrismAgent

class ConnectionStub: DIDCommConnection {
    var holderDID = DID()
    var otherDID = DID()
    var awaitMessagesResponse: [Message]!
    var awaitMessageResponse: Message?

    func awaitMessages() async throws -> [Message] {
        awaitMessagesResponse
    }

    func awaitMessageResponse(id: String) async throws -> Domain.Message? {
        awaitMessageResponse
    }
}
