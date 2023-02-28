import Foundation

/// The `AttachmentData` protocol represents a generic attachment for a DIDComm `Message`. Any type that conforms to `AttachmentData` can be used as an attachment.
public protocol AttachmentData: Codable {}

/// The `AttachmentHeader` struct represents the header for a DIDComm attachment.
public struct AttachmentHeader: AttachmentData {
    /// The `children` value associated with the attachment.
    public let children: String

    /// Initializes a new `AttachmentHeader` object with the specified properties.
    /// - Parameter children: The `children` value associated with the attachment.
    public init(children: String) {
        self.children = children
    }
}

/// The `AttachmentJws` struct represents a DIDComm attachment containing a JWS (JSON Web Signature).
public struct AttachmentJws: AttachmentData {
    /// The header for the JWS attachment.
    public let header: AttachmentHeader

    /// The `protected` value associated with the JWS.
    public let protected: String

    /// The signature for the JWS.
    public let signature: String

    /// Initializes a new `AttachmentJws` object with the specified properties.
    /// - Parameters:
    ///   - header: The header for the JWS attachment.
    ///   - protected: The `protected` value associated with the JWS.
    ///   - signature: The signature for the JWS.
    public init(header: AttachmentHeader, protected: String, signature: String) {
        self.header = header
        self.protected = protected
        self.signature = signature
    }
}

/// The `AttachmentJwsData` struct represents a DIDComm attachment containing JWS data.
public struct AttachmentJwsData: AttachmentData {
    /// The base64-encoded data for the JWS.
    public let base64: String

    /// The `AttachmentJws` object containing the JWS data.
    public let jws: AttachmentJws

    /// Initializes a new `AttachmentJwsData` object with the specified properties.
    /// - Parameters:
    ///   - base64: The base64-encoded data for the JWS.
    ///   - jws: The `AttachmentJws` object containing the JWS data.
    public init(base64: String, jws: AttachmentJws) {
        self.base64 = base64
        self.jws = jws
    }
}

/// The `AttachmentBase64` struct represents a DIDComm attachment containing base64-encoded data.
public struct AttachmentBase64: AttachmentData {
    /// The base64-encoded data.
    public let base64: String

    /// Initializes a new `AttachmentBase64` object with the specified properties.
    /// - Parameter base64: The base64-encoded data.
    public init(base64: String) {
        self.base64 = base64
    }
}

/// The `AttachmentLinkData` struct represents a DIDComm attachment containing a link to external data.
public struct AttachmentLinkData: AttachmentData {
    /// The links associated with the attachment.
    public let links: [String]

    /// The hash associated with the attachment.
    public let hash: String

    /// Initializes a new `AttachmentLinkData` object with the specified properties.
    /// - Parameters:
    ///   - links: The links associated with the attachment.
    ///   - hash: The hash associated with the attachment.
    public init(links: [String], hash: String) {
        self.links = links
        self.hash = hash
    }
}

/// The `AttachmentJsonData` struct represents a DIDComm attachment containing JSON data.
public struct AttachmentJsonData: AttachmentData {
    /// The JSON data associated with the attachment.
    public let data: Data

    /// Initializes a new `AttachmentJsonData` object with the specified properties.
    /// - Parameter data: The JSON data associated with the attachment.
    public init(data: Data) {
        self.data = data
    }
}

/// The `AttachmentDescriptor` struct represents metadata for a DIDComm attachment.
public struct AttachmentDescriptor {
    /// The ID associated with the attachment.
    public let id: String

    /// The media type associated with the attachment.
    public let mediaType: String?

    /// The data associated with the attachment.
    public let data: AttachmentData

    /// The filename associated with the attachment.
    public let filename: [String]?

    /// The format associated with the attachment.
    public let format: String?

    /// The last modification time associated with the attachment.
    public let lastmodTime: Date?

    /// The byte count associated with the attachment.
    public let byteCount: Int?

    /// The description associated with the attachment.
    public let description: String?

    /// Initializes a new `AttachmentDescriptor` object with the specified properties.
    /// - Parameters:
    ///   - id: The ID associated with the attachment.
    ///   - mediaType: The media type associated with the attachment.
    ///   - data: The data associated with the attachment.
    ///   - filename: The filename associated with the attachment.
    ///   - format: The format associated with the attachment.
    ///   - lastmodTime: The last modification time associated with the attachment.
    ///   - byteCount: The byte count associated with the attachment.
    ///   - description: The description associated with the attachment.
    public init(
        id: String,
        mediaType: String? = nil,
        data: AttachmentData,
        filename: [String]? = nil,
        format: String? = nil,
        lastmodTime: Date? = nil,
        byteCount: Int? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.mediaType = mediaType
        self.data = data
        self.filename = filename
        self.format = format
        self.lastmodTime = lastmodTime
        self.byteCount = byteCount
        self.description = description
    }
}
