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
        let invalidWords = words.filter { !keyDerivation.isValidMnemonicWord(word: $0) }
        guard invalidWords.isEmpty else {
            logger.error(
                message: "Invalid mnemonic word",
                metadata: invalidWords
                    .enumerated()
                    .map {
                        .publicMetadata(key: "word\($0)", value: $1)
                    }
            )
            throw ApolloError.invalidMnemonicWord(invalidWords: invalidWords)
        }
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
