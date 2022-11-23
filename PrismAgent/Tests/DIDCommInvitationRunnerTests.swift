import Domain
@testable import PrismAgent
import XCTest

final class DIDCommInvitationRunnerTests: XCTestCase {
    private let mercury = MercuryStub()

    func testWhenReceivedOOBUrlThenParseMessage() throws {
        let exampleMessage = Message(piuri: ProtocolTypes.didcomminvitation.rawValue, body: Data())
        let queryString = try mercury.packMessage(msg: exampleMessage).result
        let exampleURL = URL(string: "localhost:8080?_oob=\(queryString)")!

        let parsedMessage = try DIDCommInvitationRunner(mercury: mercury, url: exampleURL).run()
        XCTAssertEqual(exampleMessage, parsedMessage)
    }

    func testWhenInvalidInvitationTypeThenThrowError() throws {
        let exampleMessage = Message(piuri: "Something wrong", body: Data())
        let queryString = try mercury.packMessage(msg: exampleMessage).result
        let exampleURL = URL(string: "localhost:8080?_oob=\(queryString)")!

        XCTAssertThrowsError(try DIDCommInvitationRunner(mercury: mercury, url: exampleURL).run())
    }
}
