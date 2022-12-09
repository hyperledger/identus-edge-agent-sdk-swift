import Domain
import Foundation

class DIDCommConnectionRunner {
    private let mercury: Mercury
    private let invitationMessage: OutOfBandInvitation
    private let ownDID: DID
    private let connection: DIDCommConnection
    private var request: HandshakeRequest?

    init(
        mercury: Mercury,
        invitationMessage: OutOfBandInvitation,
        ownDID: DID,
        connection: DIDCommConnection
    ) {
        self.mercury = mercury
        self.invitationMessage = invitationMessage
        self.ownDID = ownDID
        self.connection = connection
    }

    func run() async throws -> DIDPair {
        let request = try HandshakeRequest(inviteMessage: invitationMessage, from: ownDID)
        try await mercury.sendMessage(msg: try request.makeMessage())
        guard
            let message = try await connection.awaitMessageResponse(id: request.id),
            message.piuri == ProtocolTypes.didcommconnectionResponse.rawValue
        else { throw PrismAgentError.noHandshakeResponseError }
        return DIDPair(holder: ownDID, other: request.to, name: nil)
    }
}
