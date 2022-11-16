import Core
import Foundation
import PrismAPI

struct RandomMnemonicsOperation {
    let keyDerivation = KeyDerivation()
    let logger: PrismLogger

    func compute() -> [String] {
        keyDerivation.randomMnemonicCode().words
    }
}
