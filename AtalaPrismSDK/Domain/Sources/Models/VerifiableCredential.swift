import Foundation

/**
 A struct representing a container for verifiable credential types.

 This struct is used to encode and decode verifiable credential types for use with JSON.

 The VerifiableCredentialTypeContainer struct contains properties for the ID and type of the verifiable credential.

 - Note: The VerifiableCredentialTypeContainer struct is used to encode and decode verifiable credential types for use with JSON.

 */
public struct VerifiableCredentialTypeContainer: Codable {

    // Enum to define the two coding keys for encoding and decoding
    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
    }

    // The ID of the verifiable credential type
    public let id: String

    // The type of the verifiable credential
    public let type: String

    /**
     Encodes the verifiable credential type container to the specified encoder.

     - Parameter encoder: The encoder to use for encoding.

     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
    }

    /**
     Initializes a new instance of the VerifiableCredentialTypeContainer struct from the specified decoder.

     - Parameter decoder: The decoder to use for decoding.

     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
    }
}

/**
 Enum representing different types of verifiable credentials.

 The CredentialType enum is used to indicate the type of a verifiable credential.

 The possible values of the enum are jwt, w3c, and unknown.

 - Note: The CredentialType enum is used to indicate the type of a verifiable credential.

 */
public enum CredentialType {
    case jwt
    case w3c
    case unknown
}

/// Protocol for objects representing verifiable credentials.
public protocol VerifiableCredential {
    /// The type of this credential.
    var credentialType: CredentialType { get }
    /// The ID of this credential.
    var id: String { get }
    /// The context(s) of this credential.
    var context: Set<String> { get }
    /// The type(s) of this credential.
    var type: Set<String> { get }
    /// The issuer of this credential.
    var issuer: DID { get }
    /// The subject of this credential.
    var subject: DID? { get }
    /// The date of issuance of this credential.
    var issuanceDate: Date { get }
    /// The expiration date of this credential, if any.
    var expirationDate: Date? { get }
    /// The schema of this credential.
    var credentialSchema: VerifiableCredentialTypeContainer? { get }
    /// The subject of this credential.
    var credentialSubject: [String: String] { get }
    /// The status of this credential.
    var credentialStatus: VerifiableCredentialTypeContainer? { get }
    /// The refresh service of this credential.
    var refreshService: VerifiableCredentialTypeContainer? { get }
    /// The evidence of this credential.
    var evidence: VerifiableCredentialTypeContainer? { get }
    /// The terms of use of this credential.
    var termsOfUse: VerifiableCredentialTypeContainer? { get }
    /// The valid-from date of this credential.
    var validFrom: VerifiableCredentialTypeContainer? { get }
    /// The valid-until date of this credential.
    var validUntil: VerifiableCredentialTypeContainer? { get }
    /// JsonString containing proof content as per `https://www.w3.org/2018/credentials/v1`
    /// The proof of this credential, if any.
    var proof: String? { get }
    /// Not part of W3C Credential but included to preserve in case of conversion from JWT.
    /// The audience of this credential, if any.
    var aud: Set<String> { get }
}
