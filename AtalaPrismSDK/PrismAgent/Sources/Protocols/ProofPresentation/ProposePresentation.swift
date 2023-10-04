import Core
import Domain
import Foundation

public struct ProposePresentation {
    struct Body: Codable, Equatable {
        let goalCode: String?
        let comment: String?
        let proofTypes: [ProofTypes]

        init(
            goalCode: String? = nil,
            comment: String? = nil,
            proofTypes: [ProofTypes]
        ) {
            self.goalCode = goalCode
            self.comment = comment
            self.proofTypes = proofTypes
        }
    }
    public let id: String
    public let type = ProtocolTypes.didcommProposePresentation.rawValue
    let body: Body
    let attachments: [AttachmentDescriptor]
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
            fromMessage.piuri == ProtocolTypes.didcommProposePresentation.rawValue,
            let fromDID = fromMessage.from,
            let toDID = fromMessage.to
        else { throw PrismAgentError.invalidMessageType(
            type: fromMessage.piuri,
            shouldBe: [ProtocolTypes.didcommProposePresentation.rawValue]
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

    public static func makeProposalFromRequest(msg: Message) throws -> ProposePresentation {
        let request = try RequestPresentation(fromMessage: msg)

        return ProposePresentation(
            body: Body(
                goalCode: request.body.goalCode,
                comment: request.body.comment,
                proofTypes: request.body.proofTypes
            ),
            attachments: request.attachments,
            thid: msg.id,
            from: request.to,
            to: request.from)
    }
}

extension ProposePresentation: Equatable {
    public static func == (lhs: ProposePresentation, rhs: ProposePresentation) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.body == rhs.body
    }
}
