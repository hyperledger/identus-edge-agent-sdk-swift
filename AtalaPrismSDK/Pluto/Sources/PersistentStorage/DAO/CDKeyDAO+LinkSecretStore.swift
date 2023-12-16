import Combine
import CoreData
import Domain

extension CDKeyDAO: LinkSecretStore {
    func addLinkSecret(_ linkSecret: StorableKey) -> AnyPublisher<Void, Error> {
        updateOrCreate("linkSecret", context: writeContext) { cdobj, context in
            switch linkSecret {
            case let keychainKey as KeychainStorableKey:
                try storeKeychainKey(
                    keychainKey: keychainKey,
                    service: self.keychainService,
                    account: "linkSecret",
                    keychain: self.keychain
                )
                let cdkey = CDKeychainKey(entity: CDKeychainKey.entity(), insertInto: context)
                cdkey.parseFromStorableKey(
                    keychainKey,
                    identifier: "linkSecret",
                    service: self.keychainService
                )
            default:
                let cdkey = CDDatabaseKey(entity: CDDatabaseKey.entity(), insertInto: context)
                cdkey.parseFromStorableKey(
                    linkSecret,
                    identifier: "linkSecret"
                )
            }
        }
        .map { _ in }
        .eraseToAnyPublisher()
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
