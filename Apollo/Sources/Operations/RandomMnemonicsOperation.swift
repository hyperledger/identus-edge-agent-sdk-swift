import Foundation
import PrismAPI
import Core

struct RandomMnemonicsOperation {
    let keyDerivation = KeyDerivation()
    let logger: PrismLogger
    
    func compute() -> [String] {
        keyDerivation.randomMnemonicCode().words
    }
}
