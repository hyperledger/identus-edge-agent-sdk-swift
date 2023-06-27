import Foundation

/// `StorableCredential` is a protocol that provides storable properties for a credential.
/// These properties are typically used for indexing or querying the credential in a storage system.
public protocol StorableCredential {
    /// The identifier to be used for storing this credential.
    var storingId: String { get }
    /// The identifier to be used for recovering this credential.
    var recoveryId: String { get }
    /// The data representation of this credential.
    var credentialData: Data { get }
    /// The issuer that can be used as a query parameter.
    var queryIssuer: String? { get }
    /// The subject that can be used as a query parameter.
    var querySubject: String? { get }
    /// The date the credential was created that can be used as a query parameter.
    var queryCredentialCreated: Date? { get }
    /// The date the credential was last updated that can be used as a query parameter.
    var queryCredentialUpdated: Date? { get }
    /// The schema of the credential that can be used as a query parameter.
    var queryCredentialSchema: String? { get }
    /// The date until which the credential is valid that can be used as a query parameter.
    var queryValidUntil: Date? { get }
    /// The revocation status of the credential that can be used as a query parameter.
    var queryRevoked: Bool? { get }
    /// The available claims in the credential that can be used as a query parameter.
    var queryAvailableClaims: [String] { get }
}

public extension Credential {
    /// A Boolean value indicating whether the credential is storable.
    var isStorable: Bool { self is StorableCredential }

    /// Returns the storable representation of the credential.
    var storable: StorableCredential? { self as? StorableCredential }
}
