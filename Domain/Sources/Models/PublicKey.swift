import Foundation

public struct PublicKey {
    public let curve: String
    public let value: Data

    public init(curve: String, value: Data) {
        self.curve = curve
        self.value = value
    }
}

public struct CompressedPublicKey {
    public let uncompressed: PublicKey
    public let value: Data

    public init(uncompressed: PublicKey, value: Data) {
        self.uncompressed = uncompressed
        self.value = value
    }
}
