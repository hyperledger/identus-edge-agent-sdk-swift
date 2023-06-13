import Core
import CryptoKit
import Domain
import Foundation

struct CreateX25519KeyPairOperation {
    let logger: PrismLogger

    func compute() -> PrivateKey {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        return X25519PrivateKey(appleCurve: privateKey)
    }

    func compute(fromPrivateKey: Data) throws -> PrivateKey {
        let privateKey = try Curve25519
            .KeyAgreement
            .PrivateKey(rawRepresentation: fromPrivateKey)
        return X25519PrivateKey(appleCurve: privateKey)
    }
}
