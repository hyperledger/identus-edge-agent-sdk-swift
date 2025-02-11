import Domain
@testable import EdgeAgent
import XCTest

final class HandshakeRequestTests: XCTestCase {
    func testHandshakeRequestMakeMessage() throws {
        let request = ConnectionRequest(
            from: DID(index: 1),
            to: DID(index: 2),
            thid: "0",
            body: .init(goalCode: "1", goal: "Test", accept: ["Test1"])
        )

        let message = try request.makeMessage()
        XCTAssertEqual(message.id, request.id)
        XCTAssertEqual(message.piuri, request.type)
        XCTAssertEqual(message.from, request.from)
        XCTAssertEqual(message.to, request.to)
        XCTAssertEqual(message.thid, request.thid)
        let decodedBody = try JSONDecoder.didComm().decode(ConnectionRequest.Body.self, from: message.body)
        XCTAssertEqual(decodedBody, request.body)
    }

    func testHandshakeRequestInitFromInvitationMessage() throws {
        let body = ConnectionRequest.Body(
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

        let selfDID = DID(index: 3)

        let request = try ConnectionRequest(inviteMessage: exampleMessage, from: selfDID)
        XCTAssertNotEqual(exampleMessage.id, request.id)
        XCTAssertEqual(request.type, ProtocolTypes.didcommconnectionRequest.rawValue)
        XCTAssertEqual(selfDID, request.from)
        XCTAssertEqual(exampleMessage.from, request.to)
        XCTAssertEqual(exampleMessage.id, request.thid)
        XCTAssertEqual(body, request.body)
    }
}

extension ConnectionRequest.Body: Equatable {
    public static func == (lhs: ConnectionRequest.Body, rhs: ConnectionRequest.Body) -> Bool {
        lhs.goalCode == rhs.goalCode && lhs.goal == rhs.goal && lhs.accept == rhs.accept
    }
}
