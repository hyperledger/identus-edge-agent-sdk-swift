import Domain
import Foundation

struct CodableMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case piuri
        case from
        case to
        case fromPrior
        case extraHeaders
        case createdTime
        case expiresTimePlus
        case attachments
        case thid
        case pthid
        case ack
        case body
        case direction
    }

    let message: Message

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message.id, forKey: .id)
        try container.encode(message.piuri, forKey: .piuri)
        try container.encode(message.body, forKey: .body)
        try container.encode(message.extraHeaders, forKey: .extraHeaders)
        try container.encode(message.createdTime, forKey: .createdTime)
        try container.encode(message.expiresTimePlus, forKey: .expiresTimePlus)
        try container.encode(message.attachments, forKey: .attachments)
        try container.encode(message.ack, forKey: .ack)
        try container.encode(message.direction.rawValue, forKey: .direction)
        try message.from.map { try container.encode(CodableDID(did: $0), forKey: .from) }
        try message.to.map { try container.encode(CodableDID(did: $0), forKey: .to) }
        try message.fromPrior.map { try container.encode($0, forKey: .fromPrior) }
        try message.thid.map { try container.encode($0, forKey: .thid) }
        try message.pthid.map { try container.encode($0, forKey: .pthid) }
    }

    init(message: Message) {
        self.message = message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let piuri = try container.decode(String.self, forKey: .piuri)
        let body = try container.decode(Data.self, forKey: .body)
        let extraHeaders = try container.decodeIfPresent([String: String].self, forKey: .extraHeaders)
        let createdTime = try container.decodeIfPresent(Date.self, forKey: .createdTime) 
        let expiresTimePlus = try container.decodeIfPresent(Date.self, forKey: .expiresTimePlus)
        let attachments = try container.decodeIfPresent([AttachmentDescriptor].self, forKey: .attachments)
        let ack = try container.decodeIfPresent([String].self, forKey: .ack)
        let from = try? container.decodeIfPresent(CodableDID.self, forKey: .from)?.did
        let to = try? container.decodeIfPresent(CodableDID.self, forKey: .to)?.did
        let fromPrior = try? container.decodeIfPresent(String.self, forKey: .fromPrior)
        let thid = try? container.decodeIfPresent(String.self, forKey: .thid)
        let pthid = try? container.decodeIfPresent(String.self, forKey: .pthid)
        let directionRaw = try container.decodeIfPresent(String.self, forKey: .direction)
        let direction = directionRaw.flatMap { Message.Direction(rawValue: $0) }

        self.init(message: .init(
            id: id,
            piuri: piuri,
            from: from,
            to: to,
            fromPrior: fromPrior,
            body: body,
            extraHeaders: extraHeaders ?? [:],
            createdTime: createdTime ?? Date(),
            expiresTimePlus: expiresTimePlus,
            attachments: attachments ?? [],
            thid: thid,
            pthid: pthid,
            ack: ack ?? [],
            direction: direction ?? .sent
        ))
    }
}
