import ApolloLibrary
import Core
import Foundation

struct RandomMnemonicsOperation {
    let logger: PrismLogger

    func compute() -> [String] {
        ApolloLibrary.Mnemonic.companion.createRandomMnemonics()
    }
}
