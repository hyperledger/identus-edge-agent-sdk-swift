import Domain
import Foundation

struct JWTCredentialPayload {
    struct JWTVerfiableCredential {
        let context: Set<String>
        let type: Set<String>
        let credentialSchema: VerifiableCredentialTypeContainer?
        let credentialSubject: String
        let credentialStatus: VerifiableCredentialTypeContainer?
        let refreshService: VerifiableCredentialTypeContainer?
        let evidence: VerifiableCredentialTypeContainer?
        let termsOfUse: VerifiableCredentialTypeContainer?
    }
    let iss: DID
    let sub: String?
    let verifiableCredential: JWTVerfiableCredential
    let nbf: Date
    let exp: Date?
    let jti: String?
    let aud: Set<String>
}

extension JWTCredentialPayload: VerifiableCredential {
    var context: Set<String> { verifiableCredential.context }
    var type: Set<String> { verifiableCredential.type }
    var id: String? { jti }
    var issuer: DID { iss }
    var issuanceDate: Date { nbf }
    var expirationDate: Date? { exp }
    var credentialSchema: VerifiableCredentialTypeContainer? { verifiableCredential.credentialSchema }
    var credentialSubject: String { verifiableCredential.credentialSubject }
    var credentialStatus: VerifiableCredentialTypeContainer? { verifiableCredential.credentialStatus }
    var refreshService: VerifiableCredentialTypeContainer? { verifiableCredential.refreshService }
    var evidence: Domain.VerifiableCredentialTypeContainer? { verifiableCredential.evidence }
    var termsOfUse: Domain.VerifiableCredentialTypeContainer? { verifiableCredential.termsOfUse }
    var validFrom: Domain.VerifiableCredentialTypeContainer? { nil }
    var validUntil: Domain.VerifiableCredentialTypeContainer? { nil }
    var proof: String? { nil }
}

extension JWTCredentialPayload.JWTVerfiableCredential: Codable {
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type = "@type"
        case credentialSubject
        case credentialStatus
        case credentialSchema
        case refreshService
        case evidence
        case termsOfUse
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.context, forKey: .context)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.credentialSubject, forKey: .credentialSubject)
        try container.encode(self.credentialStatus, forKey: .credentialStatus)
        try container.encode(self.credentialSchema, forKey: .credentialSchema)
        try container.encode(self.refreshService, forKey: .refreshService)
        try container.encode(self.evidence, forKey: .evidence)
        try container.encode(self.termsOfUse, forKey: .termsOfUse)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.context = try container.decode(Set<String>.self, forKey: .context)
        self.type = try container.decode(Set<String>.self, forKey: .type)
        self.credentialSubject = try container.decode(String.self, forKey: .credentialSubject)
        self.credentialStatus = try? container.decode(
            VerifiableCredentialTypeContainer.self,
            forKey: .credentialStatus
        )
        self.credentialSchema = try? container.decode(
            VerifiableCredentialTypeContainer.self,
            forKey: .credentialSchema
        )
        self.refreshService = try? container.decode(
            VerifiableCredentialTypeContainer.self,
            forKey: .refreshService
        )
        self.evidence = try? container.decode(
            VerifiableCredentialTypeContainer.self,
            forKey: .evidence
        )
        self.termsOfUse = try? container.decode(
            VerifiableCredentialTypeContainer.self,
            forKey: .termsOfUse
        )
    }
}

extension JWTCredentialPayload: Codable {
    enum CodingKeys: String, CodingKey {
        case iss
        case sub
        case verfiableCredential = "vc"
        case nbf
        case exp
        case jti
        case aud
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.iss.string, forKey: .iss)
        try container.encode(self.sub, forKey: .sub)
        try container.encode(self.verifiableCredential, forKey: .verfiableCredential)
        try container.encode(self.nbf, forKey: .nbf)
        try container.encode(self.exp, forKey: .exp)
        try container.encode(self.jti, forKey: .jti)
        try container.encode(self.aud, forKey: .aud)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let didString = try container.decode(String.self, forKey: .iss)
        self.iss = try DID(string: didString)
        self.sub = try? container.decode(String.self, forKey: .sub)
        self.verifiableCredential = try container.decode(JWTVerfiableCredential.self, forKey: .verfiableCredential)
        self.nbf = try container.decode(
            Date.self,
            forKey: .nbf
        )
        self.exp = try? container.decode(
            Date.self,
            forKey: .exp
        )
        self.jti = try? container.decode(
            String.self,
            forKey: .jti
        )
        self.aud = (try? container.decode(
            Set<String>.self,
            forKey: .aud
        )) ?? Set<String>()
    }
}
