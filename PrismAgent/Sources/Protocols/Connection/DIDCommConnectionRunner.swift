import Domain
import Foundation

class DIDCommConnectionRunner {
    private let mercury: Mercury
    private let invitationMessage: Message
    private let ownDID: DID
    private let connectionMaker: (DID, DID, Mercury) -> DIDCommConnection
    private var request: HandshakeRequest?

    init(
        mercury: Mercury,
        invitationMessage: Message,
        ownDID: DID,
        connectionMaker: @escaping (DID, DID, Mercury) -> DIDCommConnection
    ) {
        self.mercury = mercury
        self.invitationMessage = invitationMessage
        self.ownDID = ownDID
        self.connectionMaker = connectionMaker
    }

    func run() async throws -> DIDCommConnection {
        let request = try HandshakeRequest(inviteMessage: invitationMessage, from: ownDID)
        try await mercury.sendMessage(msg: try request.makeMessage())
        let connection = connectionMaker(ownDID, request.to, mercury)
        guard
            let message = try await connection.awaitMessageResponse(id: request.id),
            message.piuri == ProtocolTypes.didcommconnectionResponse.rawValue
        else { throw PrismAgentError.noHandshakeResponseError }
        return connection
    }
}
