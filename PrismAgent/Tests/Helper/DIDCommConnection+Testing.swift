import Domain
@testable import PrismAgent

class ConnectionStub: DIDCommConnection, ConnectionsManager {
    var awaitMessagesResponse: [Message]!
    var awaitMessageResponse: Message?
    var sendMessageResponse: Message?

    func sendMessage(_ message: Message) async throws -> Message? {
        sendMessageResponse
    }

    func awaitMessages() async throws -> [Message] {
        awaitMessagesResponse
    }

    func awaitMessageResponse(id: String) async throws -> Domain.Message? {
        awaitMessageResponse
    }

    func addConnection(_ paired: DIDPair) async throws {}

    func removeConnection(_ pair: DIDPair) async throws -> DIDPair? {
        return nil
    }

    func registerMediator(hostDID: DID, mediatorDID: DID) async throws {}
}
