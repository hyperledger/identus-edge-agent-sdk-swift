import Foundation

/// Represents a container for cryptographic proof associated with a digital document or credential.
public struct ProofContainer: Codable {
    /// The type of cryptographic proof, such as a specific signature scheme.
    public let type: String

    /// The date and time when the proof was created, if applicable.
    public let created: Date?

    /// The intended purpose of the proof, such as "assertionMethod" or "authentication".
    public let proofPurpose: String?

    /// The URI or identifier of the verification method used to create the proof.
    public let verificationMethod: String?

    /// The domain associated with the proof, typically used to scope the validity of the proof to a specific domain.
    public let domain: String?

    /// A challenge that was incorporated into the proof, often used in challenge-response protocols.
    public let challenge: String?

    /// The JSON Web Signature (JWS) representation of the proof, containing the actual cryptographic signature.
    public let jws: String?

    /// Initializes a new `ProofContainer` with specified proof details.
    /// - Parameters:
    ///   - type: The type of the proof, indicating the signature or method used.
    ///   - created: Optional date and time the proof was generated.
    ///   - proofPurpose: Optional purpose for which the proof is intended.
    ///   - verificationMethod: Optional method or identifier used for verification.
    ///   - domain: Optional domain within which the proof is relevant.
    ///   - challenge: Optional challenge value used in the creation of the proof.
    ///   - jws: Optional JSON Web Signature encapsulating the proof.
    public init(type: String, created: Date? = nil, proofPurpose: String? = nil, verificationMethod: String? = nil, domain: String? = nil, challenge: String? = nil, jws: String? = nil) {
        self.type = type
        self.created = created
        self.proofPurpose = proofPurpose
        self.verificationMethod = verificationMethod
        self.domain = domain
        self.challenge = challenge
        self.jws = jws
    }
}
