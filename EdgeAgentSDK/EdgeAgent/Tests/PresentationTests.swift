import Domain
@testable import EdgeAgent
import XCTest

final class PresentationTests: XCTestCase {
    func testWhenValidPresentationMessageThenInitPresentation() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validPresentation = Presentation(
            body: .init(),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let presentationMessage = try validPresentation.makeMessage()

        let testPresentation = try Presentation(fromMessage: presentationMessage)
        XCTAssertEqual(validPresentation, testPresentation)
    }

    func testWhenInvalidPresentationMessageThenThrowError() throws {
        let invalidPresentation = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try Presentation(fromMessage: invalidPresentation))
    }

    func testWhenValidRequestMessageThenInitPresentation() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validRequest = RequestPresentation(
            body: .init(proofTypes: [
                .init(
                    schema: "testSchema",
                    requiredFields: nil,
                    trustIssuers: nil
                )
            ]),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let requestMessage = try validRequest.makeMessage()

        let testPresentation = try Presentation.makePresentationFromRequest(msg: requestMessage)
        XCTAssertEqual(validRequest.from, testPresentation.to)
        XCTAssertEqual(validRequest.to, testPresentation.from)
        XCTAssertEqual(validRequest.attachments, testPresentation.attachments)
        XCTAssertEqual(validRequest.id, testPresentation.thid)
        XCTAssertEqual(validRequest.body.goalCode, testPresentation.body.goalCode)
        XCTAssertEqual(validRequest.body.comment, testPresentation.body.comment)
    }
}
