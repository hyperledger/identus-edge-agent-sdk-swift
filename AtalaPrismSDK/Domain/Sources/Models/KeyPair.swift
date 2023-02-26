import Foundation

/// Enumeration representing supported key curves for key generation.
public enum KeyCurve: Equatable {
    /// The x25519 key curve.
    case x25519

    /// The ed25519 key curve.
    case ed25519

    /// The secp256k1 key curve with an optional index.
    case secp256k1(index: Int = 0)

    /// Returns the name of the key curve as a string.
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

/// Represents a pair of private and public keys for a specific key curve.
public struct KeyPair {
    /// The key curve used for the key pair.
    public let curve: KeyCurve

    /// The private key of the key pair.
    public let privateKey: PrivateKey

    /// The public key of the key pair.
    public let publicKey: PublicKey

    public init(curve: KeyCurve = .secp256k1(), privateKey: PrivateKey, publicKey: PublicKey) {
        self.curve = curve
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}
