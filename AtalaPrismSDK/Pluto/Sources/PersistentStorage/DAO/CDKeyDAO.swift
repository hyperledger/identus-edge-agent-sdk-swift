import Combine
import CoreData
import Domain

struct CDKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDKey
    let keychain: KeychainStore & KeychainProvider
    let keychainService: String
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "identifier"
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
                storableData: keyData,
                index: keychainKey.index?.intValue
            )
        case let databaseKey as CDDatabaseKey:
            return StorableKeyModel(
                restorationIdentifier: databaseKey.restorationIdentifier,
                storableData: databaseKey.storableData,
                index: databaseKey.index?.intValue
            )
        default:
            throw UnknownError.somethingWentWrongError(
                customMessage: "This should never happen it a key always have a type of CDKeychainKey or CDDatabaseKey",
                underlyingErrors: nil
            )
        }
    }
}