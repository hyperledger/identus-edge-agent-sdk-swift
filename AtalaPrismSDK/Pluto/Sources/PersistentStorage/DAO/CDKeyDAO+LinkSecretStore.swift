import Combine
import CoreData
import Domain

extension CDKeyDAO: LinkSecretStore {
    func addLinkSecret(_ linkSecret: StorableKey) -> AnyPublisher<Void, Error> {
        switch linkSecret {
        case let keychainKey as KeychainStorableKey:
            return keychainDao.updateOrCreate(linkSecret.identifier, context: writeContext) { cdobj, context in
                try storeKeychainKey(
                    keychainKey: keychainKey,
                    service: self.keychainDao.keychainService,
                    account: linkSecret.identifier,
                    keychain: self.keychainDao.keychain
                )
                cdobj.parseFromStorableKey(
                    keychainKey,
                    identifier: linkSecret.identifier,
                    service: self.keychainDao.keychainService
                )
            }
            .map { _ in }
            .eraseToAnyPublisher()
        default:
            return databaseDAO.updateOrCreate(linkSecret.identifier, context: writeContext) { cdobj, context in
                cdobj.parseFromStorableKey(
                    linkSecret,
                    identifier: linkSecret.identifier
                )
            }
            .map { _ in }
            .eraseToAnyPublisher()
        }
    }
}

private func storeKeychainKey(
    keychainKey: KeychainStorableKey,
    service: String,
    account: String,
    keychain: KeychainStore
) throws {
    try keychain.addKey(
        keychainKey,
        service: service,
        account: account
    )
}

private extension CDDatabaseKey {
    func parseFromStorableKey(
        _ key: StorableKey,
        identifier: String
    ) {
        self.identifier = identifier
        self.storableData = key.storableData
        self.index = key.index.map { NSNumber(integerLiteral: $0) }
        self.restorationIdentifier = key.restorationIdentifier
    }
}

private extension CDKeychainKey {
    func parseFromStorableKey(
        _ key: KeychainStorableKey,
        identifier: String,
        service: String
    ) {
        self.identifier = identifier
        self.restorationIdentifier = key.restorationIdentifier
        self.index = key.index.map { NSNumber(integerLiteral: $0) }
        self.type = key.keyClass.rawValue
        self.algorithm = key.type.rawValue
        self.service = service
    }
}
