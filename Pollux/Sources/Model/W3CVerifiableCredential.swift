import Domain
import Foundation

struct W3CVerifiableCredential: VerifiableCredential {
    let context: Set<String>
    let type: Set<String>
    let id: String?
    let issuer: DID
    let issuanceDate: Date
    let expirationDate: Date?
    let credentialSchema: VerifiableCredentialTypeContainer?
    let credentialSubject: String
    let credentialStatus: VerifiableCredentialTypeContainer?
    let refreshService: VerifiableCredentialTypeContainer?
    let evidence: VerifiableCredentialTypeContainer?
    let termsOfUse: VerifiableCredentialTypeContainer?
    let validFrom: VerifiableCredentialTypeContainer?
    let validUntil: VerifiableCredentialTypeContainer?
    let proof: String?
    let aud: Set<String>
}

extension W3CVerifiableCredential: Codable {
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type = "@type"
        case id
        case issuer
        case issuanceDate
        case expirationDate
        case validFrom
        case validUntil
        case proof
        case credentialSubject
        case credentialStatus
        case credentialSchema
        case refreshService
        case evidence
        case termsOfUse
        case aud
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.context, forKey: .context)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.issuer.string, forKey: .issuer)
        try container.encode(self.issuanceDate, forKey: .issuanceDate)
        try container.encode(self.expirationDate, forKey: .expirationDate)
        try container.encode(self.validFrom, forKey: .validFrom)
        try container.encode(self.validUntil, forKey: .validUntil)
        try container.encode(self.proof, forKey: .proof)
        try container.encode(self.aud, forKey: .aud)
        try container.encode(self.credentialSubject, forKey: .credentialSubject)
        try container.encode(self.credentialStatus, forKey: .credentialStatus)
        try container.encode(self.credentialSchema, forKey: .credentialSchema)
        try container.encode(self.refreshService, forKey: .refreshService)
        try container.encode(self.evidence, forKey: .evidence)
        try container.encode(self.termsOfUse, forKey: .termsOfUse)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.context = (try? container.decode(Set<String>.self, forKey: .context)) ?? Set()
        self.type = (try? container.decode(Set<String>.self, forKey: .type)) ?? Set()
        self.id = try container.decode(String.self, forKey: .id)
        let didString = try container.decode(String.self, forKey: .issuer)
        self.issuer = try DID(string: didString)
        self.issuanceDate = try container.decode(Date.self, forKey: .issuanceDate)
        self.expirationDate = try? container.decode(Date.self, forKey: .expirationDate)
        self.validFrom = try? container.decode(VerifiableCredentialTypeContainer.self, forKey: .validFrom)
        self.validUntil = try? container.decode(VerifiableCredentialTypeContainer.self, forKey: .validUntil)
        self.proof = try? container.decode(String.self, forKey: .proof)
        self.aud = (try? container.decode(Set<String>.self, forKey: .proof)) ?? Set()
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
