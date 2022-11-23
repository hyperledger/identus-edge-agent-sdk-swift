import Domain
@testable import PrismAgent
import XCTest

final class ConnectionRunnerTests: XCTestCase {
    private let mercury = MercuryStub()

    func testWhenInvitationMessageThenTryConnectingWith() async throws {
        let body = HandshakeRequest.Body(
            goalCode: "123",
            goal: "Test",
            accept: ["Test1"]
        )

        let exampleMessage = Message(
            piuri: ProtocolTypes.didcomminvitation.rawValue,
            from: DID(index: 1),
            to: DID(index: 2),
            body: try JSONEncoder().encode(body)
        )

        let exampleMessageResponse = Message(
            piuri: ProtocolTypes.didcommconnectionResponse.rawValue,
            from: DID(index: 2),
            to: DID(index: 1),
            body: try JSONEncoder().encode(body)
        )

        let selfDID = DID(index: 3)
        let connection = ConnectionStub()
        connection.awaitMessageResponse = exampleMessageResponse

        _ = try await DIDCommConnectionRunner(
            mercury: mercury,
            invitationMessage: exampleMessage,
            ownDID: selfDID
        ) { holderDID, otherDID, _ in
            connection.holderDID = holderDID
            connection.otherDID = otherDID
            return connection
        }.run()
    }
}
