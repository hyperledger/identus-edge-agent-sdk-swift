import Foundation

public struct PrivateKey {
    public let curve: KeyCurve
    public let value: Data

    public init(curve: KeyCurve, value: Data) {
        self.curve = curve
        self.value = value
    }
}
