import Domain
import Foundation

extension Message: Codable {
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(piuri, forKey: .piuri)
        try container.encode(body, forKey: .body)
        try container.encode(extraHeaders, forKey: .extraHeaders)
        try container.encode(createdTime, forKey: .createdTime)
        try container.encode(expiresTimePlus, forKey: .expiresTimePlus)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(ack, forKey: .ack)
        try from.map { try container.encode($0, forKey: .from) }
        try to.map { try container.encode($0, forKey: .to) }
        try fromPrior.map { try container.encode($0, forKey: .fromPrior) }
        try thid.map { try container.encode($0, forKey: .thid) }
        try pthid.map { try container.encode($0, forKey: .pthid) }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let piuri = try container.decode(String.self, forKey: .piuri)
        let body = try container.decode(Data.self, forKey: .body)
        let extraHeaders = try container.decode([String: String].self, forKey: .extraHeaders)
        let createdTime = try container.decode(Date.self, forKey: .createdTime)
        let expiresTimePlus = try container.decode(Date.self, forKey: .expiresTimePlus)
        let attachments = try container.decode([AttachmentDescriptor].self, forKey: .attachments)
        let ack = try container.decode([String].self, forKey: .ack)
        let from = try? container.decode(DID.self, forKey: .from)
        let to = try? container.decode(DID.self, forKey: .to)
        let fromPrior = try? container.decode(String.self, forKey: .fromPrior)
        let thid = try? container.decode(String.self, forKey: .thid)
        let pthid = try? container.decode(String.self, forKey: .pthid)

        self.init(
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
        )
    }
}
