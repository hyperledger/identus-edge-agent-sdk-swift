import Foundation

public struct VerifiableCredentialTypeContainer: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
    }

    public let id: String
    public let type: String

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
    }
}

/// Enum representing different types of verifiable credentials.
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
