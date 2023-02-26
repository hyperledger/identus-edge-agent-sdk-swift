import Foundation

/// Represents a public key with a specific key curve and value.
public struct PublicKey {
    /// The key curve used for the public key.
    public let curve: String

    /// The value of the public key as raw data.
    public let value: Data

    public init(curve: String, value: Data) {
        self.curve = curve
        self.value = value
    }
}

/// Represents a compressed public key and its uncompressed version.
public struct CompressedPublicKey {
    /// The uncompressed version of the public key.
    public let uncompressed: PublicKey

    /// The compressed version of the public key as raw data.
    public let value: Data

    public init(uncompressed: PublicKey, value: Data) {
        self.uncompressed = uncompressed
        self.value = value
    }
}
