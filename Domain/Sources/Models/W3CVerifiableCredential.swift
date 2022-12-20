import Foundation

public struct W3CVerifiableCredential: VerifiableCredential {
    public let credentialType = CredentialType.w3c
    public let context: Set<String>
    public let type: Set<String>
    public let id: String
    public let issuer: DID
    public let issuanceDate: Date
    public let expirationDate: Date?
    public let credentialSchema: VerifiableCredentialTypeContainer?
    public let credentialSubject: [String: String]
    public let credentialStatus: VerifiableCredentialTypeContainer?
    public let refreshService: VerifiableCredentialTypeContainer?
    public let evidence: VerifiableCredentialTypeContainer?
    public let termsOfUse: VerifiableCredentialTypeContainer?
    public let validFrom: VerifiableCredentialTypeContainer?
    public let validUntil: VerifiableCredentialTypeContainer?
    public let proof: String?
    public let aud: Set<String>

    public init(
        context: Set<String> = Set(),
        type: Set<String> = Set(),
        id: String,
        issuer: DID,
        issuanceDate: Date,
        expirationDate: Date? = nil,
        credentialSchema: VerifiableCredentialTypeContainer? = nil,
        credentialSubject: [String: String],
        credentialStatus: VerifiableCredentialTypeContainer? = nil,
        refreshService: VerifiableCredentialTypeContainer? = nil,
        evidence: VerifiableCredentialTypeContainer? = nil,
        termsOfUse: VerifiableCredentialTypeContainer? = nil,
        validFrom: VerifiableCredentialTypeContainer? = nil,
        validUntil: VerifiableCredentialTypeContainer? = nil,
        proof: String? = nil,
        aud: Set<String> = Set()
    ) {
        self.context = context
        self.type = type
        self.id = id
        self.issuer = issuer
        self.issuanceDate = issuanceDate
        self.expirationDate = expirationDate
        self.credentialSchema = credentialSchema
        self.credentialSubject = credentialSubject
        self.credentialStatus = credentialStatus
        self.refreshService = refreshService
        self.evidence = evidence
        self.termsOfUse = termsOfUse
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.proof = proof
        self.aud = aud
    }
}
