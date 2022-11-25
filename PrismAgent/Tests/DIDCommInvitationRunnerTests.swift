import Domain
@testable import PrismAgent
import XCTest

final class DIDCommInvitationRunnerTests: XCTestCase {
    private let mercury = MercuryStub()

    func testWhenReceivedOOBUrlThenParseMessage() async throws {
        let exampleMessage = Message(piuri: ProtocolTypes.didcomminvitation.rawValue, body: Data())
        let queryString = try await mercury.packMessage(msg: exampleMessage)
        let exampleURL = URL(string: "localhost:8080?_oob=\(queryString)")!

        let parsedMessage = try await DIDCommInvitationRunner(mercury: mercury, url: exampleURL).run()
        XCTAssertEqual(exampleMessage, parsedMessage)
    }

    func testWhenInvalidInvitationTypeThenThrowError() async throws {
        let exampleMessage = Message(piuri: "Something wrong", body: Data())
        let queryString = try await mercury.packMessage(msg: exampleMessage)
        let exampleURL = URL(string: "localhost:8080?_oob=\(queryString)")!
        do {
            _ = try await DIDCommInvitationRunner(mercury: mercury, url: exampleURL).run()
            XCTFail("Did not throw error")
        } catch {}
    }
}
