import Foundation

public struct PrivateKey {
    public let curve: String
    public let value: Data

    public init(curve: String, value: Data) {
        self.curve = curve
        self.value = value
    }
}
