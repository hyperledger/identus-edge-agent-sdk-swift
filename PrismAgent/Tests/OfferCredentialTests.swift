import Domain
@testable import PrismAgent
import XCTest

final class OfferCredentialTests: XCTestCase {
    func testWhenValidOfferMessageThenInitOfferCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validOfferCredential = OfferCredential(
            body: .init(
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
        let offerMessage = try validOfferCredential.makeMessage()

        let testOfferCredential = try OfferCredential(fromMessage: offerMessage)
        XCTAssertEqual(validOfferCredential, testOfferCredential)
    }

    func testWhenInvalidOfferMessageThenInitOfferCredential() throws {
        let invalidOfferCredential = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try OfferCredential(fromMessage: invalidOfferCredential))
    }

    func testWhenValidProposeMessageThenInitOfferCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validProposeCredential = ProposeCredential(
            body: .init(
                credentialPreview: .init(attributes: []),
                formats: [.init(attachId: "test1", format: "test")]
            ),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let proposeMessage = try validProposeCredential.makeMessage()

        let testOfferCredential = try OfferCredential.makeOfferToProposedCredential(msg: proposeMessage)
        XCTAssertEqual(validProposeCredential.from, testOfferCredential.to)
        XCTAssertEqual(validProposeCredential.to, testOfferCredential.from)
        XCTAssertEqual(validProposeCredential.attachments, testOfferCredential.attachments)
        XCTAssertEqual(validProposeCredential.id, testOfferCredential.thid)
        XCTAssertEqual(validProposeCredential.body.goalCode, testOfferCredential.body.goalCode)
        XCTAssertEqual(validProposeCredential.body.comment, testOfferCredential.body.comment)
        XCTAssertEqual(validProposeCredential.body.formats, testOfferCredential.body.formats)
    }
}
