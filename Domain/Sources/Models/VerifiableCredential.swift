import Foundation

public struct VerifiableCredentialTypeContainer: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
    }

    let id: String
    let type: String

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

public enum CredentialType {
    case jwt
    case w3c
    case unknown
}

public protocol VerifiableCredential {
    var credentialType: CredentialType { get }
    var id: String { get }
    var context: Set<String> { get }
    var type: Set<String> { get }
    var issuer: DID { get }
    var issuanceDate: Date { get }
    var expirationDate: Date? { get }
    var credentialSchema: VerifiableCredentialTypeContainer? { get }
    var credentialSubject: String { get }
    var credentialStatus: VerifiableCredentialTypeContainer? { get }
    var refreshService: VerifiableCredentialTypeContainer? { get }
    var evidence: VerifiableCredentialTypeContainer? { get }
    var termsOfUse: VerifiableCredentialTypeContainer? { get }
    var validFrom: VerifiableCredentialTypeContainer? { get }
    var validUntil: VerifiableCredentialTypeContainer? { get }

    // JsonString containing proof content as per `https://www.w3.org/2018/credentials/v1`
    var proof: String? { get }

    // Not part of W3C Credential but included to preserve in case of conversion from JWT.
    var aud: Set<String> { get }
}
