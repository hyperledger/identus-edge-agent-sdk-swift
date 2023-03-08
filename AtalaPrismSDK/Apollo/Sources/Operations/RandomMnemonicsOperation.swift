import Core
import Foundation

struct RandomMnemonicsOperation {
    let logger: PrismLogger

    func compute() -> [String] {
        (try? Mnemonic.generate(strength: .veryHigh)) ?? []
    }
}
