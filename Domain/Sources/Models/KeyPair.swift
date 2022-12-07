import Foundation

public enum KeyCurve: Equatable {
    case x25519
    case ed25519
    case secp256k1(index: Int = 0)

    public var name: String {
        switch self {
        case .x25519:
            return "X25519"
        case .ed25519:
            return "Ed25519"
        case .secp256k1:
            return "secp256k1"
        }
    }
}

public struct KeyPair {
    public let curve: KeyCurve
    public let privateKey: PrivateKey
    public let publicKey: PublicKey

    public init(curve: KeyCurve = .secp256k1(), privateKey: PrivateKey, publicKey: PublicKey) {
        self.curve = curve
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
