import AnoncredsSwift
import Foundation

struct CreateLinkSecretOperation {
    func create() throws -> String {
        try Prover().createLinkSecret().getValue()
    }
}
