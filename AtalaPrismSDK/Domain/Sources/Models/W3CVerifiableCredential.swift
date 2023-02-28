import Foundation

/**
 A struct representing a W3C Verifiable Credential.

 This struct conforms to the VerifiableCredential protocol, which defines the properties and methods required for a verifiable credential.

 The W3CVerifiableCredential struct contains properties for the credential's context, type, ID, issuer, issuance date, expiration date, credential schema, credential subject, credential status, refresh service, evidence, terms of use, valid from date, valid until date, proof, and audience.

 - Note: The W3CVerifiableCredential struct is designed to work with W3C-compliant verifiable credentials.

 */
public struct W3CVerifiableCredential: VerifiableCredential {

    // The credential type for this verifiable credential is set to `CredentialType.w3c`
    public let credentialType = CredentialType.w3c

    // The set of context strings associated with the credential
    public let context: Set<String>

    // The set of type strings associated with the credential
    public let type: Set<String>

    // The ID of the credential
    public let id: String

    // The DID of the entity that issued the credential
    public let issuer: DID

    // The date on which the credential was issued
    public let issuanceDate: Date

    // The date on which the credential expires, if applicable
    public let expirationDate: Date?

    // The schema for the credential
    public let credentialSchema: VerifiableCredentialTypeContainer?

    // The subject of the credential, represented as a dictionary of key-value pairs
    public let credentialSubject: [String: String]

    // The status of the credential
    public let credentialStatus: VerifiableCredentialTypeContainer?

    // The refresh service for the credential
    public let refreshService: VerifiableCredentialTypeContainer?

    // The evidence associated with the credential
    public let evidence: VerifiableCredentialTypeContainer?

    // The terms of use for the credential
    public let termsOfUse: VerifiableCredentialTypeContainer?

    // The earliest date from which the credential is valid
    public let validFrom: VerifiableCredentialTypeContainer?

    // The latest date at which the credential is valid
    public let validUntil: VerifiableCredentialTypeContainer?

    // The proof associated with the credential
    public let proof: String?

    // The audience for the credential
    public let aud: Set<String>

    /**
     Initializes a new instance of the W3CVerifiableCredential struct.

     - Parameters:
        - context: The set of context strings associated with the credential.
        - type: The set of type strings associated with the credential.
        - id: The ID of the credential.
        - issuer: The DID of the entity that issued the credential.
        - issuanceDate: The date on which the credential was issued.
        - expirationDate: The date on which the credential expires, if applicable.
        - credentialSchema: The schema for the credential.
        - credentialSubject: The subject of the credential, represented as a dictionary of key-value pairs.
        - credentialStatus: The status of the credential.
        - refreshService: The refresh service for the credential.
        - evidence: The evidence associated with the credential.
        - termsOfUse: The terms of use for the credential.
        - validFrom: The earliest date from which the credential is valid.
        - validUntil: The latest date at which the credential is valid.
        - proof: The proof associated with the credential.
        - aud: The audience for the credential.

     */
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
