import Combine
import Foundation
import Domain

extension CDKeyDAO: KeyProvider {
    func getAll() -> AnyPublisher<[StorableKey], Error> {
        fetchController(context: readContext)
            .tryMap {
                try $0.map { try $0.parseToStorableKey(keychain: self.keychainDao.keychain) }
            }
            .eraseToAnyPublisher()
    }

    func getKeyById(id: String) -> AnyPublisher<StorableKey?, Error> {
        fetchByIDsPublisher(id, context: readContext)
            .tryMap {
                try $0?.parseToStorableKey(keychain: self.keychainDao.keychain)
            }
            .eraseToAnyPublisher()
    }
}
