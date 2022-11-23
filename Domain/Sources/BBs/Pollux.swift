import Foundation

public protocol Pollux {
    func parseVerifiableCredential(jsonString: String) throws -> VerifiableCredential
}
