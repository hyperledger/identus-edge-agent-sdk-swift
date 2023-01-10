import Foundation

/// Represents a seed used for key generation.
public struct Seed {
    /// The value of the seed as raw data.
    public let value: Data

    public init(value: Data) {
        self.value = value
    }
}
