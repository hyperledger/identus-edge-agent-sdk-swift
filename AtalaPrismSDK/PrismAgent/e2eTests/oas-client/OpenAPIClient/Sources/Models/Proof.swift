//
// Proof.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

/// A digital signature over the Credential Schema for the sake of asserting authorship. A piece of Metadata. 
public struct Proof: Codable {
    /// The type of cryptographic signature algorithm used to generate the proof.
    public var type: String
    /// The date and time at which the proof was created, in UTC format. This field is used to ensure that the proof was generated before or at the same time as the credential schema itself.
    public var created: Date
    /// The verification method used to generate the proof. This is usually a DID and key ID combination that can be used to look up the public key needed to verify the proof.
    public var verificationMethod: String
    /// The purpose of the proof (for example: `assertionMethod`). This indicates that the proof is being used to assert that the issuer really issued this credential schema instance.
    public var proofPurpose: String
    /// The cryptographic signature value that was generated using the private key associated with the verification method, and which can be used to verify the proof.
    public var proofValue: String
    /// The JSON Web Signature (JWS) that contains the proof information.
    public var jws: String
    /// It specifies the domain context within which the credential schema and proof are being used
    public var domain: String?

    public init(type: String, created: Date, verificationMethod: String, proofPurpose: String, proofValue: String, jws: String, domain: String? = nil) {
        self.type = type
        self.created = created
        self.verificationMethod = verificationMethod
        self.proofPurpose = proofPurpose
        self.proofValue = proofValue
        self.jws = jws
        self.domain = domain
    }
}
