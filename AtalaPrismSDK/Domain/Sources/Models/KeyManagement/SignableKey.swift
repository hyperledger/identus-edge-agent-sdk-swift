import Foundation

public protocol SignableKey {
    var algorithm: String { get }
    func sign(data: Data) async throws -> Signature
}

public struct Signature {
    public let algorithm: String
    public let signatureSpecifications: [String: Any]
    public let raw: Data

    public init(algorithm: String, signatureSpecifications: [String : Any], raw: Data) {
        self.algorithm = algorithm
        self.signatureSpecifications = signatureSpecifications
        self.raw = raw
    }
}

public extension Key {
    var isSignable: Bool { self is SignableKey }
    var signing: SignableKey? { self as? SignableKey }
}
