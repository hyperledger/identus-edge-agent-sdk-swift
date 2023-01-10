import Foundation

/// Represents a digital signature.
public struct Signature {
    /// The value of the signature as raw data.
    public let value: Data

    public init(value: Data) {
        self.value = value
    }
}
