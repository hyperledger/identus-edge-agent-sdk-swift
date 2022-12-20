import Core
import Domain
import Foundation

public struct RequestPresentation {
    public struct Body: Codable, Equatable {
        let goalCode: String?
        let comment: String?
        let willConfirm: Bool?
        let proofTypes: [ProofTypes]

        init(
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
    public let type = ProtocolTypes.didcommRequestCredential.rawValue
    public let body: Body
    public let attachments: [AttachmentDescriptor]
    public let thid: String?
    public let from: DID
    public let to: DID

    init(
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
        else { throw PrismAgentError.invalidRequestPresentationMessageError }

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
