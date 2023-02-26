import Foundation

public protocol Pollux {
    func parseVerifiableCredential(jwtString: String) throws -> VerifiableCredential
}
