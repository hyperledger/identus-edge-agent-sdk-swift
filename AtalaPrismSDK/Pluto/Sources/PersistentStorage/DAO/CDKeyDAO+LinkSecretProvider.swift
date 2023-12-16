import Combine
import Foundation
import Domain

extension CDKeyDAO: LinkSecretProvider {
    func getAll() -> AnyPublisher<[StorableKey], Error> {
        fetchController(context: readContext)
            .tryMap { try $0.map { try $0.parseToStorableKey(keychain: self.keychain) } }
            .eraseToAnyPublisher()
    }
}
