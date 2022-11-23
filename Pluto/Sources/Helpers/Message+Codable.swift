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
        let extraHeaders = try container.decode([String: String].self, forKey: .extraHeaders)
        let createdTime = try container.decode(Date.self, forKey: .createdTime)
        let expiresTimePlus = try container.decode(Date.self, forKey: .expiresTimePlus)
        let attachments = try container.decode([AttachmentDescriptor].self, forKey: .attachments)
        let ack = try container.decode([String].self, forKey: .ack)
        let from = try? container.decode(CodableDID.self, forKey: .from).did
        let to = try? container.decode(CodableDID.self, forKey: .to).did
        let fromPrior = try? container.decode(String.self, forKey: .fromPrior)
        let thid = try? container.decode(String.self, forKey: .thid)
        let pthid = try? container.decode(String.self, forKey: .pthid)

        self.init(message: .init(
            id: id,
            piuri: piuri,
            from: from,
            to: to,
            fromPrior: fromPrior,
            body: body,
            extraHeaders: extraHeaders,
            createdTime: createdTime,
            expiresTimePlus: expiresTimePlus,
            attachments: attachments,
            thid: thid,
            pthid: pthid,
            ack: ack
        ))
    }
}
