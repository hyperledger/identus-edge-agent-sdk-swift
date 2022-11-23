import Domain
@testable import PrismAgent
import XCTest

final class RequestCredentialTests: XCTestCase {
    func testWhenValidRequestMessageThenInitRequestCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validRequestCredential = RequestCredential(
            body: .init(
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
        let requestMessage = try validRequestCredential.makeMessage()

        let testRequestCredential = try RequestCredential(fromMessage: requestMessage)
        XCTAssertEqual(validRequestCredential, testRequestCredential)
    }

    func testWhenInvalidRequestMessageThenInitRequestCredential() throws {
        let invalidRequestCredential = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try RequestCredential(fromMessage: invalidRequestCredential))
    }

    func testWhenValidOfferMessageThenInitRequestCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validOfferCredential = OfferCredential(
            body: .init(
                credentialPreview: .init(attributes: []),
                formats: [.init(attachId: "test1", format: "test")]
            ),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let offerMessage = try validOfferCredential.makeMessage()

        let testRequestCredential = try RequestCredential.makeRequestFromOfferCredential(message: offerMessage)
        XCTAssertEqual(validOfferCredential.from, testRequestCredential.to)
        XCTAssertEqual(validOfferCredential.to, testRequestCredential.from)
        XCTAssertEqual(validOfferCredential.attachments, testRequestCredential.attachments)
        XCTAssertEqual(validOfferCredential.id, testRequestCredential.thid)
        XCTAssertEqual(validOfferCredential.body.goalCode, testRequestCredential.body.goalCode)
        XCTAssertEqual(validOfferCredential.body.comment, testRequestCredential.body.comment)
        XCTAssertEqual(validOfferCredential.body.formats, testRequestCredential.body.formats)
    }
}
