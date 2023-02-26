import Combine
import Domain
import Foundation

protocol VerifiableCredentialStore {
    func addCredentials(credentials: [VerifiableCredential]) -> AnyPublisher<Void, Error>
    func addCredential(credential: VerifiableCredential) -> AnyPublisher<Void, Error>
    func removeCredential(id: String) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}
