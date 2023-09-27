import Combine
import Core
import CoreData
import Domain

extension CDDIDPrivateKeyDAO: DIDPrivateKeyProvider {
    func getAll() -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error> {
        fetchController(context: readContext)
            .tryMap {
                try $0.map {
                    (
                        DID(from: $0),
                        try $0.keys.map { try $0.parseToStorableKey(keychain: self.keychain) },
                        $0.alias
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func getDIDInfo(did: DID) -> AnyPublisher<(did: DID, privateKeys: [StorableKey], alias: String?)?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .tryMap {
                try $0.map {
                    (
                        DID(from: $0),
                        try $0.keys.map { try $0.parseToStorableKey(keychain: self.keychain) },
                        $0.alias
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func getDIDInfo(alias: String) -> AnyPublisher<[(did: DID, privateKeys: [StorableKey], alias: String?)], Error> {
        fetchController(
            predicate: NSPredicate(format: "alias == %@", alias),
            context: readContext
        )
        .tryMap {
            try $0.map {
                (
                    DID(from: $0),
                    try $0.keys.map { try $0.parseToStorableKey(keychain: self.keychain) },
                    $0.alias
                )
            }
        }
        .eraseToAnyPublisher()
    }

    func getPrivateKeys(did: DID) -> AnyPublisher<[StorableKey]?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .tryMap {
                try $0?.keys.map { try $0.parseToStorableKey(keychain: self.keychain) }
            }
            .eraseToAnyPublisher()
    }
}

extension CDKey {
    func parseToStorableKey(keychain: KeychainProvider) throws -> StorableKey {
        switch self {
        case let keychainKey as CDKeychainKey:
            guard
                let algortihm = KeychainStorableKeyProperties.KeyAlgorithm(rawValue: keychainKey.algorithm),
                let keyType = KeychainStorableKeyProperties.KeyType(rawValue: keychainKey.type)
            else {
                // TODO: Update this error
                throw PlutoError.algorithmOrKeyTypeNotValid(algorithm: keychainKey.algorithm, keyType: keychainKey.type)
            }
            let keyData = try keychain.getKey(
                service: keychainKey.service,
                account: keychainKey.identifier,
                tag: keychainKey.tag,
                algorithm: algortihm,
                type: keyType
            )

            return StorableKeyModel(
                restorationIdentifier: keychainKey.restorationIdentifier,
                storableData: keyData
            )
        case let databaseKey as CDDatabaseKey:
            return StorableKeyModel(
                restorationIdentifier: databaseKey.restorationIdentifier,
                storableData: databaseKey.storableData
            )
        default:
            throw UnknownError.somethingWentWrongError(
                customMessage: "This should never happen it a key always have a type of CDKeychainKey or CDDatabaseKey",
                underlyingErrors: nil
            )
        }
    }
}
