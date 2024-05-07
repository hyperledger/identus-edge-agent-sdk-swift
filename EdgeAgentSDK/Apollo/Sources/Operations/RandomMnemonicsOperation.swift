import ApolloLibrary
import Core
import Foundation

struct RandomMnemonicsOperation {
    let logger: SDKLogger

    func compute() -> [String] {
        ApolloLibrary.Mnemonic.companion.createRandomMnemonics()
    }
}
