import Combine
import Domain
import Foundation

protocol KeyProvider {
    func getAll() -> AnyPublisher<[StorableKey], Error>
    func getKeyById(id: String) -> AnyPublisher<StorableKey?, Error>
}
