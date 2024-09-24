import Core
import Domain
import Foundation

public struct ForwardMessage {
    // Connection Body is the same as Invitation body message
    public struct Body: Codable {
        public let next: String

        public init(next: String) {
            self.next = next
        }
    }
    public let type: String = "https://didcomm.org/routing/2.0/forward"
    public let id: String
    public let from: DID
    public let to: DID
    public let body: Body
    public let encryptedJsonMessage: Data

    public init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        body: Body,
        encryptedJsonMessage: Data
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.body = body
        self.encryptedJsonMessage = encryptedJsonMessage
    }

    public func makeMessage() throws -> Message {
        Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(self.body),
            attachments: [
                .init(
                    mediaType: "application/json",
                    data: AttachmentJsonData(
                        json: try JSONDecoder.didComm().decode(AnyCodable.self, from: encryptedJsonMessage)
                    )
                )
            ]
        )
    }
}
