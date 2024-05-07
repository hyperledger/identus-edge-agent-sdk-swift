import Domain
@testable import EdgeAgent
import XCTest

final class ProposeCredentialTests: XCTestCase {
    func testWhenValidProposeMessageThenInitProposeCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validProposeCredential = ProposeCredential(
            body: .init(
                goalCode: "Test1",
                comment: "Test1",
                credentialPreview: .init(
                    attributes: [
                        .init(
                            name: "test1",
                            value: "test",
                            mimeType: "test.x")
                    ]),
                formats: [
                    .init(
                        attachId: "test1",
                        format: "test")
                ]
            ),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let proposeMessage = try validProposeCredential.makeMessage()

        let testProposeCredential = try ProposeCredential(fromMessage: proposeMessage)
        XCTAssertEqual(validProposeCredential, testProposeCredential)
    }

    func testWhenInvalidProposeMessageThenInitProposeCredential() throws {
        let invalidProposeCredential = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try ProposeCredential(fromMessage: invalidProposeCredential))
    }
}
