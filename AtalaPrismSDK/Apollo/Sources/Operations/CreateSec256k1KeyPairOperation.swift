import Core
import Domain
import Foundation

struct CreateSec256k1KeyPairOperation {
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
    let seed: Seed
    let keyPath: KeyPath

    init(logger: PrismLogger = PrismLogger(category: .apollo), seed: Seed, keyPath: KeyPath) {
        self.logger = logger
        self.seed = seed
        self.keyPath = keyPath
    }

    func compute() throws -> KeyPair {
        let derivedKey = try HDKeychain(seed: seed.value).derivedKey(path: keyPath.keyPathString())

        return .init(
            privateKey: .init(
                curve: .secp256k1(index: keyPath.index),
                value: derivedKey.privateKey().data
            ),
            publicKey: .init(
                curve: KeyCurve.secp256k1(index: keyPath.index).name,
                value: derivedKey.extendedPublicKey().publicKey().data
            )
        )
    }
}
