import Combine
import Domain
import Foundation

protocol CredentialStore {
    func addCredentials(credentials: [StorableCredential]) -> AnyPublisher<Void, Error>
    func addCredential(credential: StorableCredential) -> AnyPublisher<Void, Error>
    func removeCredential(id: String) -> AnyPublisher<Void, Error>
    func removeAll() -> AnyPublisher<Void, Error>
}
