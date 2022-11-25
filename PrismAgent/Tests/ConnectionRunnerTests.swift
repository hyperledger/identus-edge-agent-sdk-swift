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

        let testOtherDID = DID(index: 1)
        let testOwnDID = DID(index: 2)

        let exampleMessage = Message(
            piuri: ProtocolTypes.didcomminvitation.rawValue,
            from: testOtherDID,
            to: nil,
            body: try JSONEncoder().encode(body)
        )

        let exampleMessageResponse = Message(
            piuri: ProtocolTypes.didcommconnectionResponse.rawValue,
            from: testOwnDID,
            to: testOtherDID,
            body: try JSONEncoder().encode(body)
        )

        let connection = ConnectionStub()
        connection.awaitMessageResponse = exampleMessageResponse

        let pair = try await DIDCommConnectionRunner(
            mercury: mercury,
            invitationMessage: exampleMessage,
            ownDID: testOwnDID,
            connection: connection
        ).run()

        XCTAssertEqual(pair, .init(holder: testOwnDID, other: testOtherDID, name: nil))
    }
}
