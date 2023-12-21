import Core
import Domain
import Foundation

public struct BasicMessage {

    public struct Body: Codable {
        public let content: String

        public init(content: String) {
            self.content = content
        }
    }

    public let id: String
    public let type = ProtocolTypes.didcommBasicMessage.rawValue
    public let from: DID
    public let to: DID
    public let date: Date
    public let body: Body
    public let attachments: [AttachmentDescriptor]

    public init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        body: Body,
        date: Date = Date(),
        attachments: [AttachmentDescriptor] = []
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.body = body
        self.date = date
        self.attachments = attachments
    }

    public init?(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommBasicMessage.rawValue,
            let from = fromMessage.from,
            let to = fromMessage.to
        else {
            return nil
        }
        self.id = fromMessage.id
        self.from = from
        self.to = to
        self.body = try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        self.date = fromMessage.createdTime
        self.attachments = fromMessage.attachments
    }

    public func makeMessage() throws -> Message {
        return Message(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(body),
            createdTime: date, 
            attachments: attachments,
            direction: .sent
        )
    }
}
