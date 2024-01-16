import Combine
import Foundation
import Domain

extension CDKeyDAO: LinkSecretProvider {
    func getLinkSecret() -> AnyPublisher<StorableKey?, Error> {
        fetchByIDsPublisher("linkSecret", context: readContext)
            .tryMap {
                try $0?.parseToStorableKey(keychain: self.keychainDao.keychain)
            }
            .eraseToAnyPublisher()
    }
}
