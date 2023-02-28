import Foundation

/// The Pollux protocol defines the set of credential operations that are used in the Atala PRISM architecture.
public protocol Pollux {
    /// Parses a JWT-encoded verifiable credential and returns a `VerifiableCredential` object representing the credential.
    /// - Parameter jwtString: The JWT-encoded credential to parse.
    /// - Throws: An error if the JWT cannot be parsed or decoded, or if the resulting verifiable credential is invalid.
    /// - Returns: A `VerifiableCredential` object representing the parsed credential.
    func parseVerifiableCredential(jwtString: String) throws -> VerifiableCredential
}
