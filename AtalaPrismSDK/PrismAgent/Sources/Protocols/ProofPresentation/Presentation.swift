import Core
import Domain
import Foundation

public struct ProofTypes: Codable, Equatable {
    public let schema: String
    public let requiredFields: [String]?
    public let trustIssuers: [String]?
}

public struct Presentation {
    public struct Body: Codable, Equatable {
        public let goalCode: String?
        public let comment: String?

        public init(
            goalCode: String? = nil,
            comment: String? = nil
        ) {
            self.goalCode = goalCode
            self.comment = comment
        }
    }
    public let id: String
    public let type = ProtocolTypes.didcommPresentation.rawValue
    public let body: Body
    public let attachments: [AttachmentDescriptor]
    public let thid: String?
    public let from: DID
    public let to: DID

    public init(
        id: String = UUID().uuidString,
        body: Body,
        attachments: [AttachmentDescriptor],
        thid: String?,
        from: DID,
        to: DID
    ) {
        self.id = id
        self.body = body
        self.attachments = attachments
        self.thid = thid
        self.from = from
        self.to = to
    }

    public init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommPresentation.rawValue,
            let fromDID = fromMessage.from,
            let toDID = fromMessage.to
        else { throw PrismAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: ProtocolTypes.didcommPresentation.rawValue
        ) }

        let body = try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        self.init(
            id: fromMessage.id,
            body: body,
            attachments: fromMessage.attachments,
            thid: fromMessage.thid,
            from: fromDID,
            to: toDID
        )
    }

    public func makeMessage() throws -> Message {
        .init(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder.didComm().encode(body),
            attachments: attachments,
            thid: thid
        )
    }

    public static func makePresentationFromRequest(msg: Message) throws -> Presentation {
        let request = try RequestPresentation(fromMessage: msg)

        return Presentation(
            body: Body(
                goalCode: request.body.goalCode,
                comment: request.body.comment
            ),
            attachments: request.attachments,
            thid: msg.id,
            from: request.to,
            to: request.from)
    }
}

extension Presentation: Equatable {
    public static func == (lhs: Presentation, rhs: Presentation) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.body == rhs.body
    }
}
