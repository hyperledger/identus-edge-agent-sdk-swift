import Foundation

public protocol AttachmentData: Codable {}

public struct AttachmentHeader: AttachmentData {
    public let children: String

    public init(children: String) {
        self.children = children
    }
}

public struct AttachmentJws: AttachmentData {
    public let header: AttachmentHeader
    public let protected: String
    public let signature: String

    public init(header: AttachmentHeader, protected: String, signature: String) {
        self.header = header
        self.protected = protected
        self.signature = signature
    }
}

public struct AttachmentJwsData: AttachmentData {
    public let base64: String
    public let jws: AttachmentJws

    public init(base64: String, jws: AttachmentJws) {
        self.base64 = base64
        self.jws = jws
    }
}

public struct AttachmentBase64: AttachmentData {
    public let base64: String

    public init(base64: String) {
        self.base64 = base64
    }
}

public struct AttachmentLinkData: AttachmentData {
    public let links: [String]
    public let hash: String

    public init(links: [String], hash: String) {
        self.links = links
        self.hash = hash
    }
}

public struct AttachmentJsonData: AttachmentData {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }
}

public struct AttachmentDescriptor {
    public let id: String
    public let mediaType: [String]?
    public let data: AttachmentData
    public let filename: [String]?
    public let lastmodTime: Date?
    public let byteCount: Int?
    public let description: [String]?

    public init(
        id: String,
        mediaType: [String]? = nil,
        data: AttachmentData,
        filename: [String]? = nil,
        lastmodTime: Date? = nil,
        byteCount: Int? = nil,
        description: [String]? = nil
    ) {
        self.id = id
        self.mediaType = mediaType
        self.data = data
        self.filename = filename
        self.lastmodTime = lastmodTime
        self.byteCount = byteCount
        self.description = description
    }
}
