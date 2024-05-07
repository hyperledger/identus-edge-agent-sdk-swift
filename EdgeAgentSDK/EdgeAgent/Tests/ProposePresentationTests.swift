import Domain
@testable import EdgeAgent
import XCTest

final class ProposePresentationTests: XCTestCase {
    func testWhenValidProposePresentationMessageThenInitProposePresentation() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validProposePresentation = ProposePresentation(
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
        let proposePresentationMessage = try validProposePresentation.makeMessage()

        let testProposePresentation = try ProposePresentation(fromMessage: proposePresentationMessage)
        XCTAssertEqual(validProposePresentation, testProposePresentation)
    }

    func testWhenInvalidProposePresentationMessageThenThrowError() throws {
        let invalidProposePresentation = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try ProposePresentation(fromMessage: invalidProposePresentation))
    }

    func testWhenValidRequestMessageThenInitProposePresentation() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validRequestPresentation = RequestPresentation(
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
        let requestMessage = try validRequestPresentation.makeMessage()

        let testProposePresentation = try ProposePresentation.makeProposalFromRequest(msg: requestMessage)
        XCTAssertEqual(validRequestPresentation.from, testProposePresentation.to)
        XCTAssertEqual(validRequestPresentation.to, testProposePresentation.from)
        XCTAssertEqual(validRequestPresentation.attachments, testProposePresentation.attachments)
        XCTAssertEqual(validRequestPresentation.id, testProposePresentation.thid)
        XCTAssertEqual(validRequestPresentation.body.goalCode, testProposePresentation.body.goalCode)
        XCTAssertEqual(validRequestPresentation.body.comment, testProposePresentation.body.comment)
    }
}
