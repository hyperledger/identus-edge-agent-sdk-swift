@testable import Domain
import Foundation

extension AttachmentDescriptor: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case mediaType
        case data
        case filename
        case lastmodTime
        case byteCount
        case description
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try mediaType.map { try container.encode($0, forKey: .mediaType) }
        try filename.map { try container.encode($0, forKey: .filename) }
        try lastmodTime.map { try container.encode($0, forKey: .lastmodTime) }
        try byteCount.map { try container.encode($0, forKey: .byteCount) }
        try description.map { try container.encode($0, forKey: .description) }

        if let attachment = data as? AttachmentBase64 {
            try container.encode(attachment, forKey: .data)
        } else if let attachment = data as? AttachmentJws {
            try container.encode(attachment, forKey: .data)
        } else if let attachment = data as? AttachmentHeader {
            try container.encode(attachment, forKey: .data)
        } else if let attachment = data as? AttachmentJwsData {
            try container.encode(attachment, forKey: .data)
        } else if let attachment = data as? AttachmentJsonData {
            try container.encode(attachment, forKey: .data)
        } else if let attachment = data as? AttachmentLinkData {
            try container.encode(attachment, forKey: .data)
        } else { fatalError("Cannot do this") }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let mediaType = try? container.decode([String].self, forKey: .mediaType)
        let filename = try? container.decode([String].self, forKey: .filename)
        let lastmodTime = try? container.decode(Date.self, forKey: .lastmodTime)
        let byteCount = try? container.decode(Int.self, forKey: .byteCount)
        let description = try? container.decode([String].self, forKey: .description)

        let data: AttachmentData
        if let attachment = try? container.decode(AttachmentBase64.self, forKey: .data) {
            data = attachment
        } else if let attachment = try? container.decode(AttachmentJws.self, forKey: .data) {
            data = attachment
        } else if let attachment = try? container.decode(AttachmentHeader.self, forKey: .data) {
            data = attachment
        } else if let attachment = try? container.decode(AttachmentJwsData.self, forKey: .data) {
            data = attachment
        } else if let attachment = try? container.decode(AttachmentJsonData.self, forKey: .data) {
            data = attachment
        } else if let attachment = try? container.decode(AttachmentLinkData.self, forKey: .data) {
            data = attachment
        } else { fatalError("Cannot do this") }

        self.init(
            id: id,
            mediaType: mediaType,
            data: data,
            filename: filename,
            lastmodTime: lastmodTime,
            byteCount: byteCount,
            description: description
        )
    }
}
