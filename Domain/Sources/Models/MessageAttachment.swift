import Foundation

public protocol AttachmentData {}

public struct AttachmentHeader: AttachmentData {
    public let children: String
}

public struct AttachmentJws: AttachmentData {
    public let header: AttachmentHeader
    public let protected: String
    public let signature: String
}

public struct AttachmentJwsData: AttachmentData {
    public let base64: String
    public let jws: AttachmentJws
}

public struct AttachmentBase64: AttachmentData {
    public let base64: String
}

public struct AttachmentLinkData: AttachmentData {
    public let links: [String]
    public let hash: String
}

public struct AttachmentJsonData: AttachmentData {
    public let data: Data
}

public struct AttachmentDescriptor {
    public let id: String
    public let mediaType: [String]
    public let data: AttachmentData
    public let filename: [String]
    public let lastmodTime: Date
    public let byteCount: Int
    public let description: [String]
}
