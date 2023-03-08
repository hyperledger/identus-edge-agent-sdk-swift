import Core
import Domain
import Foundation

struct CreateSeedOperation {
    let logger: PrismLogger
    let words: [String]
    let passphrase: String

    init(
        logger: PrismLogger = .init(category: .apollo),
        words: [String],
        passphrase: String = ""
    ) throws {
        self.logger = logger
        self.words = words
        self.passphrase = passphrase
        let validWords = Mnemonic.wordList(for: .english)
        let invalidWords = Set(words).subtracting(Set(validWords))
        guard invalidWords.isEmpty else {
            logger.error(
                message: "Invalid mnemonic word",
                metadata: invalidWords
                    .enumerated()
                    .map {
                        .publicMetadata(key: "word\($0)", value: $1)
                    }
            )
            throw ApolloError.invalidMnemonicWord(invalidWords: Array(invalidWords))
        }
    }

    func compute() throws -> Seed {
        Seed(value: try Mnemonic.seed(
            mnemonic: words,
            passphrase: passphrase
        ))
    }
}
