import Core
import CryptoKit
import Domain
import Foundation

struct CreateEd25519KeyPairOperation {
    let logger: PrismLogger

    func compute() -> KeyPair {
        let privateKey = Curve25519.Signing.PrivateKey()
        let publicKey = privateKey.publicKey
        return KeyPair(
            curve: .ed25519,
            privateKey: .init(curve: "Ed25519", value: privateKey.rawRepresentation),
            publicKey: .init(curve: "Ed25519", value: publicKey.rawRepresentation)
        )
    }
}
