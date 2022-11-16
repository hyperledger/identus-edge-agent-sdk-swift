import Core
import Domain
import Foundation
import PrismAPI

struct CreateSeedOperation {
    let keyDerivation = KeyDerivation()
    let logger: PrismLogger
    let words: [String]
    let passphrase: String

    init(logger: PrismLogger, words: [String], passphrase: String = "") throws {
        self.logger = logger
        self.words = words
        self.passphrase = passphrase
        guard
            words.allSatisfy({
                if !keyDerivation.isValidMnemonicWord(word: $0) {
                    logger.error(
                        message: "Invalid mnemonic word",
                        metadata: [.publicMetadata(key: "word", value: $0)]
                    )
                    return false
                }
                return true
            })
        else { throw ApolloError.invalidMnemonicWord }
    }

    func compute() -> Seed {
        Seed(value: keyDerivation
            .binarySeed(
                seed: MnemonicCode(words: words),
                passphrase: passphrase
            ).toData()
        )
    }
}
