import Foundation

/// `RevocableCredential` is a protocol that defines the attributes and behaviors
/// of a credential that can be revoked or suspended.
public protocol RevocableCredential {
    /// Indicates whether the credential can be revoked.
    var canBeRevoked: Bool { get }

    /// Indicates whether the credential can be suspended.
    var canBeSuspended: Bool { get }

    /// Checks if the credential is currently revoked.
    ///
    /// - Returns: A Boolean value indicating whether the credential is revoked.
    /// - Throws: An error if the status cannot be determined.
    var isRevoked: Bool { get async throws }

    /// Checks if the credential is currently suspended.
    ///
    /// - Returns: A Boolean value indicating whether the credential is suspended.
    /// - Throws: An error if the status cannot be determined.
    var isSuspended: Bool { get async throws }
}

public extension Credential {
    /// A Boolean value indicating whether the credential can verify revocability.
    var isRevocable: Bool { self is RevocableCredential }

    /// Returns the revocable representation of the credential.
    var revocable: RevocableCredential? { self as? RevocableCredential }
}
