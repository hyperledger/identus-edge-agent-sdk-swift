import Core
import CryptoKit
import Domain
import Foundation

struct CreateEd25519KeyPairOperation {
    let logger: PrismLogger

    func compute() -> PrivateKey {
        let privateKey = Curve25519.Signing.PrivateKey()
        return Ed25519PrivateKey(appleCurve: privateKey)
    }

    func compute(fromPrivateKey: Data) throws -> PrivateKey {
        let privateKey = try Curve25519
            .Signing
            .PrivateKey(rawRepresentation: fromPrivateKey)
        return Ed25519PrivateKey(appleCurve: privateKey)
    }
}
