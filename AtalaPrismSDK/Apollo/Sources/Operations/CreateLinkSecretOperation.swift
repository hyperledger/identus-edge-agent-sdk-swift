import AnoncredsSwift
import Foundation

struct CreateLinkSecretOperation {
    func create() -> String {
        Prover().createLinkSecret().getBigNumber()
    }
}
