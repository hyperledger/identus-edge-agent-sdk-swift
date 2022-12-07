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
            privateKey: .init(curve: "X25519", value: privateKey.rawRepresentation),
            publicKey: .init(curve: "X25519", value: publicKey.rawRepresentation)
        )
    }
}
