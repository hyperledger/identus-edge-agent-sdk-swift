import Core
import Domain
import Foundation

public struct RequestPresentation {
    public struct Body: Codable, Equatable {
        public let goalCode: String?
        public let comment: String?
        public let willConfirm: Bool?
        public let proofTypes: [ProofTypes]

        public init(
            goalCode: String? = nil,
            comment: String? = nil,
            willConfirm: Bool? = false,
            proofTypes: [ProofTypes]
        ) {
            self.goalCode = goalCode
            self.comment = comment
            self.willConfirm = willConfirm
            self.proofTypes = proofTypes
        }
    }
    public let id: String
    public let type = ProtocolTypes.didcommRequestPresentation.rawValue
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
            fromMessage.piuri == ProtocolTypes.didcommRequestPresentation.rawValue,
            let fromDID = fromMessage.from,
            let toDID = fromMessage.to
        else { throw EdgeAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: [ProtocolTypes.didcommRequestPresentation.rawValue]
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
            thid: thid,
            direction: .sent
        )
    }

    public static func makeRequestFromProposal(msg: Message) throws -> RequestPresentation {
        let request = try ProposePresentation(fromMessage: msg)

        return RequestPresentation(
            body: Body(
                goalCode: request.body.goalCode,
                comment: request.body.comment,
                willConfirm: false,
                proofTypes: request.body.proofTypes
            ),
            attachments: request.attachments,
            thid: msg.id,
            from: request.to,
            to: request.from)
    }
}

extension RequestPresentation: Equatable {
    public static func == (lhs: RequestPresentation, rhs: RequestPresentation) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.body == rhs.body
    }
}
