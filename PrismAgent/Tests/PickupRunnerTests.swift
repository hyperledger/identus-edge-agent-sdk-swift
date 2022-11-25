@testable import Domain
@testable import PrismAgent
import XCTest

final class PickupRunnerTests: XCTestCase {
    private var mercury: Mercury!
    private var messagesExamples: [Message]!
    private var attachments: [AttachmentData]!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mercury = MercuryStub()
        messagesExamples = [
            Message(piuri: "test1", body: Data()),
            Message(piuri: "test2", body: Data()),
            Message(piuri: "test3", body: Data())
        ]
        attachments = try messagesExamples.map {
            AttachmentBase64(base64: try mercury.packMessage(msg: $0).result)
        }
    }

    func testWhenReceiveDeliveryMessageThenParseMessages() throws {
        let message = Message(
            piuri: ProtocolTypes.pickupDelivery.rawValue,
            body: Data(),
            attachments: attachments.map {
                .init(id: UUID().uuidString, data: $0)
            }
        )
        let runner = try PickupRunner(message: message, mercury: mercury)
        let parsedMessages = try runner.run()

        XCTAssertEqual(parsedMessages, messagesExamples)
    }

    func testWhenReceiveNotDeliveryMessageThenThrowError() throws {
        let message = Message(
            piuri: "SomethingElse",
            body: Data(),
            attachments: attachments.map {
                .init(id: UUID().uuidString, data: $0)
            }
        )

        XCTAssertThrowsError(try PickupRunner(message: message, mercury: mercury))
    }
}
