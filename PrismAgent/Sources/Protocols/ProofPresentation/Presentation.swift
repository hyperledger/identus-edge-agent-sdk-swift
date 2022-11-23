import Core
import Domain
import Foundation

struct PresentationFormat: Codable, Equatable {
    let attachId: String
    let format: String
}

public struct Presentation {
    struct Body: Codable, Equatable {
        let goalCode: String?
        let comment: String?
        let lastPresentation: Bool?
        let formats: [PresentationFormat]

        init(
            goalCode: String? = nil,
            comment: String? = nil,
            lastPresentation: Bool? = true,
            formats: [PresentationFormat]
        ) {
            self.goalCode = goalCode
            self.comment = comment
            self.lastPresentation = lastPresentation
            self.formats = formats
        }
    }
    public let id: String
    public let type = ProtocolTypes.didcommPresentation.rawValue
    let body: Body
    let attachments: [AttachmentDescriptor]
    public let thid: String?
    public let from: DID
    // swiftlint:disable identifier_name
    public let to: DID
    // swiftlint:enable identifier_name

    init(
        id: String = UUID().uuidString,
        body: Body,
        attachments: [AttachmentDescriptor],
        thid: String?,
        from: DID,
        // swiftlint:disable identifier_name
        to: DID
        // swiftlint:enable identifier_name
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
        else { throw PrismAgentError.invalidPresentationMessageError }

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
                comment: request.body.comment,
                lastPresentation: true,
                formats: request.body.formats
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
