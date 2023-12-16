import Combine
import CoreData
import Domain
import CryptoKit

extension CDDIDPrivateKeyDAO: DIDPrivateKeyStore {
    func addDID(did: DID, privateKeys: [StorableKey], alias: String?) -> AnyPublisher<Void, Error> {
        updateOrCreate(did.string, context: writeContext) { cdobj, context in
            cdobj.parseFrom(did: did, alias: alias)
            let keys = try privateKeys.map {
                switch $0 {
                case let keychainKey as KeychainStorableKey:
                    let identifier = computeStorableKeyIdentifier(keychainKey, did: did.string)
                    try storeKeychainKey(
                        did: did,
                        keychainKey: keychainKey,
                        service: self.keyDao.keychainService,
                        account: identifier,
                        keychain: self.keyDao.keychain
                    )
                    let cdkey = CDKeychainKey(entity: CDKeychainKey.entity(), insertInto: context)
                    cdkey.parseFromStorableKey(
                        keychainKey,
                        did: cdobj,
                        identifier: identifier,
                        service: self.keyDao.keychainService
                    )
                    return cdkey as CDKey
                default:
                    let cdkey = CDDatabaseKey(entity: CDDatabaseKey.entity(), insertInto: context)
                    cdkey.parseFromStorableKey(
                        $0,
                        did: cdobj,
                        identifier: computeStorableKeyIdentifier($0, did: did.string)
                    )
                    return cdkey as CDKey
                }
            }
            cdobj.keys = Set(keys)
        }
        .map { _ in }
        .eraseToAnyPublisher()
    }
    func removeDID(did: DID) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([did.string], context: writeContext)
    }

    func removeAll() -> AnyPublisher<Void, Error> {
        deleteAllPublisher(context: writeContext)
    }
}

private func storeKeychainKey(
    did: DID,
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

private func computeStorableKeyIdentifier(_ key: StorableKey, did: String) -> String {
    var returnData = Data()
    returnData += did.data(using: .utf8) ?? Data()
    returnData += key.restorationIdentifier.data(using: .utf8) ?? Data()
    returnData += key.storableData.base64EncodedData()
    return SHA256.hash(data: returnData).string
}

private extension CDDIDPrivateKey {
    func parseFrom(did: DID, alias: String?) {
        self.alias = alias
        self.did = did.string
        self.schema = did.schema
        self.method = did.method
        self.methodId = did.methodId
        self.keys = Set()
    }
}

private extension CDDatabaseKey {
    func parseFromStorableKey(
        _ key: StorableKey,
        did: CDDIDPrivateKey,
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
        did: CDDIDPrivateKey,
        identifier: String,
        service: String
    ) {
        self.identifier = identifier
        self.restorationIdentifier = key.restorationIdentifier
        self.index = key.index.map { NSNumber(integerLiteral: $0) }
        self.type = key.keyClass.rawValue
        self.algorithm = key.type.rawValue
        self.service = service
        self.did = did
    }
}

extension SHA256Digest {
    var string: String {
        self.compactMap { String(format: "%02x", $0) }.joined()
    }
}
