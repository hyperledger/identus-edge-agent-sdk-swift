import Foundation

/// The `SecurityLevel` enumeration represents different levels of security that can be associated with a `StorableKey`.
public enum SecurityLevel {
    /// The 'high' case represents a high level of security.
    case high

    /// The 'low' case represents a low level of security.
    case low
}

/// The `StorableKey` protocol defines a cryptographic key that can be stored persistently.
public protocol StorableKey {
    /// The security level of the key, represented as a `SecurityLevel` enumeration value.
    var securityLevel: SecurityLevel { get }

    /// An identifier used for restoring the key.
    var restorationIdentifier: String { get }

    /// The raw data representation of the key, suitable for storage.
    var storableData: Data { get }
}

/// Extension of the `Key` protocol to provide additional functionality related to storage.
public extension Key {
    /// A boolean value indicating whether the key can be stored persistently.
    var isStorable: Bool { self is StorableKey }

    /// Returns this key as a `StorableKey`, or `nil` if the key cannot be stored.
    var storable: StorableKey? { self as? StorableKey }
}
