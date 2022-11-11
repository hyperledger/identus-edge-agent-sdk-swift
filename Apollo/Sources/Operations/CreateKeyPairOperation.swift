import Foundation
import Domain
import PrismAPI
import Core

struct CreateKeyPairOperation {
    
    struct KeyPath {
        let index: Int

        /// Initializes a KeyPath by giving it an Index
        init(index: Int) {
            self.index = index
        }
        
        func keyPathString() -> String {
            return "m/\(index)'/0'/0'"
        }
    }
    
    let logger: PrismLogger
    let keyDerivation = KeyDerivation()
    let seed: Seed
    let keyPath: KeyPath
    
    init(logger: PrismLogger, seed: Seed, keyPath: KeyPath) {
        self.logger = logger
        self.seed = seed
        self.keyPath = keyPath
    }

    func compute() -> KeyPair {
        let newDerivationPath = DerivationPath.Companion().fromPath(path: keyPath.keyPathString())
        logger.debug(message: "New Derivation path from \(keyPath.keyPathString())")
        let newKey = keyDerivation.deriveKey(seed: seed.value.toKotlinByteArray(), path: newDerivationPath)
        logger.debug(message: "KeyPair created", metadata: [
            .privateMetadataByLevel(
                key: "privateKey",
                value: newKey.privateKey().getEncoded().toData().description,
                level: .debug
            ),
            .privateMetadataByLevel(
                key: "publicKey",
                value: newKey.privateKey().getEncoded().toData().description,
                level: .debug
            )
        ])
        
        return KeyPair(
            index: keyPath.index,
            privateKey: PrivateKey(fromEC: newKey.keyPair().privateKey),
            publicKey: PublicKey(fromEC: newKey.keyPair().publicKey)
        )
    }
}
