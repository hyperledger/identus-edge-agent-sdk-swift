import Core
import CryptoKit
import Domain
import Foundation

struct CreateX25519KeyPairOperation {
    let logger: PrismLogger

    func compute() -> KeyPair {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        return KeyPair(
            curve: .x25519,
            privateKey: .init(curve: .x25519, value: privateKey.rawRepresentation),
            publicKey: .init(curve: "X25519", value: publicKey.rawRepresentation)
        )
    }

    func compute(fromPrivateKey: PrivateKey) throws -> KeyPair {
        let privateKey = try Curve25519
            .KeyAgreement
            .PrivateKey(rawRepresentation: fromPrivateKey.value)
        return KeyPair(
            curve: fromPrivateKey.curve,
            privateKey: fromPrivateKey,
            publicKey: .init(curve: "X25519", value: privateKey.publicKey.rawRepresentation)
        )
    }
}
