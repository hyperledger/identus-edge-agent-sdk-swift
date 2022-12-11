import Domain
import Foundation

class DIDCommConnectionRunner {
    private let invitationMessage: OutOfBandInvitation
    private let ownDID: DID
    private let connection: DIDCommConnection
    private var request: HandshakeRequest?

    init(
        invitationMessage: OutOfBandInvitation,
        ownDID: DID,
        connection: DIDCommConnection
    ) {
        self.invitationMessage = invitationMessage
        self.ownDID = ownDID
        self.connection = connection
    }

    func run() async throws -> DIDPair {
        let request = try HandshakeRequest(inviteMessage: invitationMessage, from: ownDID)
        try await connection.sendMessage(try request.makeMessage())
        guard
            let message = try await connection.awaitMessageResponse(id: request.id),
            message.piuri == ProtocolTypes.didcommconnectionResponse.rawValue
        else { throw PrismAgentError.noHandshakeResponseError }
        return DIDPair(holder: ownDID, other: request.to, name: nil)
    }
}
