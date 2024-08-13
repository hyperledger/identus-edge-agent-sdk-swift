import ApolloLibrary
import Core
import Domain
import Foundation

struct CreateEd25519KeyPairOperation {
    let logger: SDKLogger

    func compute(identifier: String = UUID().uuidString) -> PrivateKey {
        let privateKey = KMMEdKeyPair.Companion().generateKeyPair().privateKey
        return Ed25519PrivateKey(identifier: identifier, internalKey: privateKey)

    }

    func compute(
        identifier: String = UUID().uuidString,
        fromPrivateKey: Data,
        derivationPath: Domain.DerivationPath? = nil
    ) throws -> PrivateKey {
        return Ed25519PrivateKey(
            identifier: identifier,
            internalKey: KMMEdPrivateKey(raw: fromPrivateKey.toKotlinByteArray()),
            derivationPath: derivationPath
        )
    }

    func compute(identifier: String, seed: Seed, keyPath: Domain.DerivationPath) throws -> PrivateKey {
        let derivedHdKey = ApolloLibrary
            .EdHDKey
            .companion
            .doInitFromSeed(seed: seed.value.toKotlinByteArray())
            .derive(path: keyPath.keyPathString()
        )

        return Ed25519PrivateKey(
            identifier: identifier,
            internalKey: .init(raw: derivedHdKey.privateKey),
            derivationPath: keyPath
        )
    }
}
