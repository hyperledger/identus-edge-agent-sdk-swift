import Domain
@testable import EdgeAgent
import XCTest

final class RequestPresentationTests: XCTestCase {
    func testWhenValidRequestPresentationMessageThenInitRequestPresentation() throws {
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
        let requestPresentationMessage = try validRequestPresentation.makeMessage()

        let testRequestPresentation = try RequestPresentation(fromMessage: requestPresentationMessage)
        XCTAssertEqual(validRequestPresentation, testRequestPresentation)
    }

    func testWhenInvalidRequestPresentationMessageThenThrowError() throws {
        let invalidRequestPresentation = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try RequestPresentation(fromMessage: invalidRequestPresentation))
    }

    func testWhenValidProposalMessageThenInitRequestPresentation() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validProposalRequest = ProposePresentation(
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
        let proposalMessage = try validProposalRequest.makeMessage()

        let testRequestPresentation = try RequestPresentation.makeRequestFromProposal(msg: proposalMessage)
        XCTAssertEqual(validProposalRequest.from, testRequestPresentation.to)
        XCTAssertEqual(validProposalRequest.to, testRequestPresentation.from)
        XCTAssertEqual(validProposalRequest.attachments, testRequestPresentation.attachments)
        XCTAssertEqual(validProposalRequest.id, testRequestPresentation.thid)
        XCTAssertEqual(validProposalRequest.body.goalCode, testRequestPresentation.body.goalCode)
        XCTAssertEqual(validProposalRequest.body.comment, testRequestPresentation.body.comment)
    }
}
