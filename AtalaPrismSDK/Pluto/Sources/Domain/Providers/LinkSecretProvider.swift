import Combine
import Domain
import Foundation

protocol LinkSecretProvider {
    func getAll() -> AnyPublisher<[StorableKey], Error>
}
