import Foundation

/**
 A struct representing a JWT credential payload.

 This payload includes the issuer (`iss`), subject (`sub`), and the verifiable credential (`verifiableCredential`).

 - Note: This struct conforms to the JSON Web Token (JWT) format. For more information, see https://jwt.io/introduction/.
 */
public struct JWTCredentialPayload {

    /**
     A struct representing the verifiable credential in a JWT credential payload.
     */
    public struct JWTVerfiableCredential {
        public let context: Set<String>
        public let type: Set<String>
        public let credentialSchema: VerifiableCredentialTypeContainer?
        public let credentialSubject: [String: String]
        public let credentialStatus: VerifiableCredentialTypeContainer?
        public let refreshService: VerifiableCredentialTypeContainer?
        public let evidence: VerifiableCredentialTypeContainer?
        public let termsOfUse: VerifiableCredentialTypeContainer?

        /**
         Initializes a new instance of `JWTVerifiableCredential`.

         - Parameters:
            - context: A set of JSON-LD contexts.
            - type: A set of types associated with the credential.
            - credentialSchema: The credential schema.
            - credentialSubject: The credential subject, represented as a dictionary of key-value pairs.
            - credentialStatus: The credential status.
            - refreshService: The refresh service.
            - evidence: The evidence associated with the credential.
            - termsOfUse: The terms of use associated with the credential.
         */
        public init(
            context: Set<String> = Set(),
            type: Set<String> = Set(),
            credentialSchema: VerifiableCredentialTypeContainer? = nil,
            credentialSubject: [String: String],
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

    /**
     Initializes a new instance of `JWTCredentialPayload`.

     - Parameters:
        - iss: The issuer of the credential.
        - sub: The subject of the credential.
        - verifiableCredential: The verifiable credential contained within the payload.
        - nbf: The time before which the credential is not valid.
        - exp: The time after which the credential is not valid.
        - jti: The unique identifier for the credential.
        - aud: The intended audience for the credential.
     */
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
    public var credentialSubject: [String: String] { verifiableCredential.credentialSubject }
    public var credentialStatus: VerifiableCredentialTypeContainer? { verifiableCredential.credentialStatus }
    public var refreshService: VerifiableCredentialTypeContainer? { verifiableCredential.refreshService }
    public var evidence: Domain.VerifiableCredentialTypeContainer? { verifiableCredential.evidence }
    public var termsOfUse: Domain.VerifiableCredentialTypeContainer? { verifiableCredential.termsOfUse }
    public var validFrom: Domain.VerifiableCredentialTypeContainer? { nil }
    public var validUntil: Domain.VerifiableCredentialTypeContainer? { nil }
    public var proof: String? { nil }
}
