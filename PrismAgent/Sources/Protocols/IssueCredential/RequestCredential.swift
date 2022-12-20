import Core
import Domain
import Foundation

// ALL parameters are DIDCOMMV2 format and naming conventions and follows the protocol
// https://github.com/hyperledger/aries-rfcs/tree/main/features/0453-issue-credential-v2
public struct RequestCredential {
    struct Body: Codable, Equatable {
        let goalCode: String?
        let comment: String?
        let formats: [CredentialFormat]

        init(
            goalCode: String? = nil,
            comment: String? = nil,
            formats: [CredentialFormat]
        ) {
            self.goalCode = goalCode
            self.comment = comment
            self.formats = formats
        }
    }

    public let id: String
    public let type = ProtocolTypes.didcommRequestCredential.rawValue
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
            fromMessage.piuri == ProtocolTypes.didcommRequestCredential.rawValue,
            let fromDID = fromMessage.from,
            let toDID = fromMessage.to
        else { throw PrismAgentError.invalidRequestCredentialMessageError }

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

    public static func makeRequestFromOfferCredential(offer: OfferCredential) throws -> RequestCredential {
        return RequestCredential(
            body: .init(
                goalCode: offer.body.goalCode,
                comment: offer.body.comment,
                formats: offer.body.formats
            ),
            attachments: offer.attachments,
            thid: offer.thid, //TODO: This needs to be changed in the pr
            from: offer.to,
            to: offer.from
        )
    }

    static func build<T: Encodable>(
        fromDID: DID,
        toDID: DID,
        thid: String?,
        credentialPreview: CredentialPreview,
        credentials: [String: T] = [:]
    ) throws -> RequestCredential {
        let aux = try credentials.map { key, value in
            let attachment = try AttachmentDescriptor.build(payload: value)
            let format = CredentialFormat(attachId: attachment.id, format: key)
            return (format, attachment)
        }
        return RequestCredential(
            body: Body(
                formats: aux.map { $0.0 }
            ),
            attachments: aux.map { $0.1 },
            thid: thid,
            from: fromDID,
            to: toDID
        )
    }
}

extension RequestCredential: Equatable {
    public static func == (lhs: RequestCredential, rhs: RequestCredential) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.body == rhs.body
    }
}
