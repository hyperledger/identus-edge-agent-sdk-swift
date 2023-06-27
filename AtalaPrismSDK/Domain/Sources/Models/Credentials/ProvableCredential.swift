import Foundation

/// `ProofableCredential` is a protocol that adds provability functionality to a credential.
public protocol ProvableCredential {
    /// Creates a presentation proof for a request message with the given options.
    ///
    /// - Parameters:
    ///   - request: The request message for which the proof needs to be created.
    ///   - options: The options to use when creating the proof.
    /// - Returns: The proof as a `String`.
    /// - Throws: If there is an error creating the proof.
    func presentation(request: Message, options: [CredentialOperationsOptions]) throws -> String
}

public extension Credential {
    /// A Boolean value indicating whether the credential is proofable.
    var isProofable: Bool { self is ProvableCredential }

    /// Returns the proofable representation of the credential.
    var proof: ProvableCredential? { self as? ProvableCredential }
}
