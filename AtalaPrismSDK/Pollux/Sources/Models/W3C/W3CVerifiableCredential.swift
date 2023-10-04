import Domain
import Foundation

/**
 A struct representing a W3C Verifiable Credential.

 This struct conforms to the VerifiableCredential protocol, which defines the properties and methods required for a verifiable credential.

 The W3CVerifiableCredential struct contains properties for the credential's context, type, ID, issuer, issuance date, expiration date, credential schema, credential subject, credential status, refresh service, evidence, terms of use, valid from date, valid until date, proof, and audience.

 - Note: The W3CVerifiableCredential struct is designed to work with W3C-compliant verifiable credentials.

 */
struct W3CVerifiableCredential {

    // The set of context strings associated with the credential
    let context: Set<String>

    // The set of type strings associated with the credential
    let type: Set<String>

    // The ID of the credential
    let id: String

    // The DID of the entity that issued the credential
    let issuerDID: DID

    // The DID of the entity that is subject of the credential
    let subjectDID: DID?

    // The date on which the credential was issued
    let issuanceDate: Date

    // The date on which the credential expires, if applicable
    let expirationDate: Date?

    // The schema for the credential
    let credentialSchema: VerifiableCredentialTypeContainer?

    // The subject of the credential, represented as a dictionary of key-value pairs
    let credentialSubject: [String: String]

    // The status of the credential
    let credentialStatus: VerifiableCredentialTypeContainer?

    // The refresh service for the credential
    let refreshService: VerifiableCredentialTypeContainer?

    // The evidence associated with the credential
    let evidence: VerifiableCredentialTypeContainer?

    // The terms of use for the credential
    let termsOfUse: VerifiableCredentialTypeContainer?

    // The earliest date from which the credential is valid
    let validFrom: VerifiableCredentialTypeContainer?

    // The latest date at which the credential is valid
    let validUntil: VerifiableCredentialTypeContainer?

    // The proof associated with the credential
    let proof: String?

    // The audience for the credential
    let aud: Set<String>

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
    init(
        context: Set<String> = Set(),
        type: Set<String> = Set(),
        id: String,
        issuerDID: DID,
        subjectDID: DID?,
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
        self.issuerDID = issuerDID
        self.subjectDID = subjectDID
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

extension W3CVerifiableCredential: Credential {
    
    var issuer: String {
        self.issuerDID.string
    }
    
    var subject: String? {
        self.subjectDID?.string
    }
    
    var claims: [Claim] {
        credentialSubject.map {
            Claim(key: $0, value: .string($1))
        }
    }
    
    var properties: [String : Any] {
        var properties = [
            "issuanceDate" : issuanceDate,
            "context" : context,
            "type" : type,
            "id" : id,
            "aud" : aud
        ] as [String : Any]
        
        expirationDate.map { properties["expirationDate"] = $0 }
        credentialSchema.map { properties["schema"] = $0.type }
        credentialStatus.map { properties["credentialStatus"] = $0.type }
        refreshService.map { properties["refreshService"] = $0.type }
        evidence.map { properties["evidence"] = $0.type }
        termsOfUse.map { properties["termsOfUse"] = $0.type }
        validFrom.map { properties["validFrom"] = $0.type }
        validUntil.map { properties["validUntil"] = $0.type }
        proof.map { properties["proof"] = $0 }
        
        return properties
    }
    
    var credentialType: String { "W3C" }
}
