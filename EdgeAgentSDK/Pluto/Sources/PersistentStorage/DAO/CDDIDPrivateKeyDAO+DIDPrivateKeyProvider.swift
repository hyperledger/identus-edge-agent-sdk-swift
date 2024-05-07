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
                        try $0.keys.map { try $0.parseToStorableKey(keychain: self.keyDao.keychainDao.keychain) },
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
                        try $0.keys.map { try $0.parseToStorableKey(keychain: self.keyDao.keychainDao.keychain) },
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
                    try $0.keys.map { try $0.parseToStorableKey(keychain: self.keyDao.keychainDao.keychain) },
                    $0.alias
                )
            }
        }
        .eraseToAnyPublisher()
    }

    func getPrivateKeys(did: DID) -> AnyPublisher<[StorableKey]?, Error> {
        fetchByIDsPublisher(did.string, context: readContext)
            .tryMap {
                try $0?.keys.map { try $0.parseToStorableKey(keychain: self.keyDao.keychainDao.keychain) }
            }
            .eraseToAnyPublisher()
    }
    
    func getLastKeyIndex() -> AnyPublisher<Int, Error> {
        keyDao.fetchController(
            sorting: NSSortDescriptor(key: "index", ascending: true),
            context: readContext
        )
        .map {
            $0.first.map { $0.index?.intValue ?? 0 } ?? 0
        }
        .eraseToAnyPublisher()
    }
}
