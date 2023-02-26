import Foundation

/// Represents a private key with a specific key curve and value.
public struct PrivateKey {
    /// The key curve used for the private key.
    public let curve: KeyCurve

    /// The value of the private key as raw data.
    public let value: Data

    public init(curve: KeyCurve, value: Data) {
        self.curve = curve
        self.value = value
    }
}
