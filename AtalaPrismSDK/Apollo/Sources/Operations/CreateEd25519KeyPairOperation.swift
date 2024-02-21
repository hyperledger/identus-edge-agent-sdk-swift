import ApolloLibrary
import Core
import Domain
import Foundation

struct CreateEd25519KeyPairOperation {
    let logger: PrismLogger

    func compute() -> PrivateKey {
        let privateKey = KMMEdKeyPair.Companion().generateKeyPair().privateKey
        return Ed25519PrivateKey(internalKey: privateKey)

    }

    func compute(identifier: String = UUID().uuidString, fromPrivateKey: Data) throws -> PrivateKey {
        return Ed25519PrivateKey(
            identifier: identifier,
            internalKey: KMMEdPrivateKey(raw: fromPrivateKey.toKotlinByteArray())
        )
    }
}
