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
    }

    func testWhenReceiveDeliveryMessageThenParseMessages() async throws {
        attachments = try await messagesExamples.asyncMap {
            AttachmentBase64(base64: try await mercury.packMessage(msg: $0))
        }
        let message = Message(
            piuri: ProtocolTypes.pickupDelivery.rawValue,
            body: Data(),
            attachments: attachments.map {
                .init(id: UUID().uuidString, data: $0)
            }
        )
        let runner = try PickupRunner(message: message, mercury: mercury)
        let parsedMessages = try await runner.run()

        XCTAssertEqual(parsedMessages, messagesExamples)
    }

    func testWhenReceiveNotDeliveryMessageThenThrowError() async throws {
        attachments = try await messagesExamples.asyncMap {
            AttachmentBase64(base64: try await mercury.packMessage(msg: $0))
        }
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

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
