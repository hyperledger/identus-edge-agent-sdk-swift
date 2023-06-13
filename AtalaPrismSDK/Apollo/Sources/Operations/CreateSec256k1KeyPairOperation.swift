import Core
import Domain
import Foundation

struct CreateSec256k1KeyPairOperation {
    let logger: PrismLogger
    let seed: Seed
    let keyPath: DerivationPath

    init(logger: PrismLogger = PrismLogger(category: .apollo), seed: Seed, keyPath: DerivationPath) {
        self.logger = logger
        self.seed = seed
        self.keyPath = keyPath
    }

    func compute() throws -> PrivateKey {
        let derivedKey = try HDKeychain(seed: seed.value).derivedKey(path: keyPath.keyPathString())

        return Secp256k1PrivateKey(lockedPrivateKey: derivedKey.privateKey())
    }
}
