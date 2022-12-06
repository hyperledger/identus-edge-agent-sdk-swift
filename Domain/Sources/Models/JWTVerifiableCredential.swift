import Foundation

public struct JWTCredentialPayload {
    public struct JWTVerfiableCredential {
        public let context: Set<String>
        public let type: Set<String>
        public let credentialSchema: VerifiableCredentialTypeContainer?
        public let credentialSubject: String
        public let credentialStatus: VerifiableCredentialTypeContainer?
        public let refreshService: VerifiableCredentialTypeContainer?
        public let evidence: VerifiableCredentialTypeContainer?
        public let termsOfUse: VerifiableCredentialTypeContainer?

        public init(
            context: Set<String> = Set(),
            type: Set<String> = Set(),
            credentialSchema: VerifiableCredentialTypeContainer? = nil,
            credentialSubject: String,
            credentialStatus: VerifiableCredentialTypeContainer? = nil,
            refreshService: VerifiableCredentialTypeContainer? = nil,
            evidence: VerifiableCredentialTypeContainer? = nil,
            termsOfUse: VerifiableCredentialTypeContainer? = nil
        ) {
            self.context = context
            self.type = type
            self.credentialSchema = credentialSchema
            self.credentialSubject = credentialSubject
            self.credentialStatus = credentialStatus
            self.refreshService = refreshService
            self.evidence = evidence
            self.termsOfUse = termsOfUse
        }
    }
    public let iss: DID
    public let sub: String?
    public let verifiableCredential: JWTVerfiableCredential
    public let nbf: Date
    public let exp: Date?
    public let jti: String
    public let aud: Set<String>

    public init(
        iss: DID,
        sub: String? = nil,
        verifiableCredential: JWTVerfiableCredential,
        nbf: Date,
        exp: Date? = nil,
        jti: String,
        aud: Set<String> = Set()
    ) {
        self.iss = iss
        self.sub = sub
        self.verifiableCredential = verifiableCredential
        self.nbf = nbf
        self.exp = exp
        self.jti = jti
        self.aud = aud
    }
}

extension JWTCredentialPayload: VerifiableCredential {
    public var credentialType: CredentialType { CredentialType.jwt }
    public var context: Set<String> { verifiableCredential.context }
    public var type: Set<String> { verifiableCredential.type }
    public var id: String { jti }
    public var issuer: DID { iss }
    public var issuanceDate: Date { nbf }
    public var expirationDate: Date? { exp }
    public var credentialSchema: VerifiableCredentialTypeContainer? { verifiableCredential.credentialSchema }
    public var credentialSubject: String { verifiableCredential.credentialSubject }
    public var credentialStatus: VerifiableCredentialTypeContainer? { verifiableCredential.credentialStatus }
    public var refreshService: VerifiableCredentialTypeContainer? { verifiableCredential.refreshService }
    public var evidence: Domain.VerifiableCredentialTypeContainer? { verifiableCredential.evidence }
    public var termsOfUse: Domain.VerifiableCredentialTypeContainer? { verifiableCredential.termsOfUse }
    public var validFrom: Domain.VerifiableCredentialTypeContainer? { nil }
    public var validUntil: Domain.VerifiableCredentialTypeContainer? { nil }
    public var proof: String? { nil }
}
