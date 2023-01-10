import Combine
import Domain
import Foundation

// MARK: Verifiable credentials functionalities
public extension PrismAgent {
    /// This function returns the verifiable credentials stored in pluto database
    ///
    /// - Returns:  A publisher that emits an array of `VerifiableCredential` and completes when all the
    ///              credentials are emitted or terminates with an error if any occurs
    func verifiableCredentials() -> AnyPublisher<[VerifiableCredential], Error> {
        pluto.getAllCredentials()
    }
}
