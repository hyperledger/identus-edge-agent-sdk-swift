import Domain
@testable import PrismAgent
import XCTest

final class IssueCredentialTests: XCTestCase {
    func testWhenValidIssueMessageThenInitIssueCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validIssueCredential = IssueCredential(
            body: .init(formats: [.init(attachId: "test1", format: "test")]),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let issueMessage = try validIssueCredential.makeMessage()

        let testIssueCredential = try IssueCredential(fromMessage: issueMessage)
        XCTAssertEqual(validIssueCredential, testIssueCredential)
    }

    func testWhenInvalidIssueMessageThenInitIssueCredential() throws {
        let invalidIssueCredential = Message(
            piuri: "InvalidType",
            from: nil,
            to: nil,
            body: Data()
        )

        XCTAssertThrowsError(try IssueCredential(fromMessage: invalidIssueCredential))
    }

    func testWhenValidRequestMessageThenInitIssueCredential() throws {
        let fromDID = DID(index: 0)
        let toDID = DID(index: 1)
        let validRequestCredential = RequestCredential(
            body: .init(formats: [.init(attachId: "test1", format: "test")]),
            attachments: [],
            thid: "1",
            from: fromDID,
            to: toDID
        )
        let requestMessage = try validRequestCredential.makeMessage()

        let testIssueCredential = try IssueCredential.makeIssueFromRequestCredential(msg: requestMessage)
        XCTAssertEqual(validRequestCredential.from, testIssueCredential.to)
        XCTAssertEqual(validRequestCredential.to, testIssueCredential.from)
        XCTAssertEqual(validRequestCredential.attachments, testIssueCredential.attachments)
        XCTAssertEqual(validRequestCredential.id, testIssueCredential.thid)
        XCTAssertEqual(validRequestCredential.body.goalCode, validRequestCredential.body.goalCode)
        XCTAssertEqual(validRequestCredential.body.comment, validRequestCredential.body.comment)
        XCTAssertEqual(validRequestCredential.body.formats, validRequestCredential.body.formats)
    }
}
