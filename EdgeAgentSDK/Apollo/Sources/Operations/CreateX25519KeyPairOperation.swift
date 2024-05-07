import ApolloLibrary
import CryptoKit
import Core
import Domain
import Foundation

struct CreateX25519KeyPairOperation {
    let logger: SDKLogger

    func compute() -> PrivateKey {
        let privateKey = KMMX25519KeyPair.Companion().generateKeyPair().privateKey
        return X25519PrivateKey(internalKey: privateKey)

    }

    func compute(identifier: String = UUID().uuidString, fromPrivateKey: Data) throws -> PrivateKey {
        let privateKey = KMMX25519PrivateKey(raw: fromPrivateKey.toKotlinByteArray())
        return X25519PrivateKey(
            identifier: identifier,
            internalKey: privateKey
        )
    }
}
