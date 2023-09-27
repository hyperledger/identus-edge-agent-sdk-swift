import Domain
import Foundation
import Security

struct KeychainDAO {
    let accessGroup: String?
}

extension KeychainDAO: KeychainProvider {
    func getKey(
        service: String,
        account: String,
        tag: String?,
        algorithm: KeychainStorableKeyProperties.KeyAlgorithm,
        type: KeychainStorableKeyProperties.KeyType
    ) throws -> Data {
        switch algorithm {
        case .genericPassword:
            var attributes: [CFString: Any] = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecReturnData: true
            ]
            accessGroup.map { attributes[kSecAttrAccessGroup] = $0 }
            var item: CFTypeRef?
            let status = SecItemCopyMatching(attributes as CFDictionary, &item)
            switch status {
            case errSecSuccess:
                guard let data = item as? Data else {
                    throw PlutoError.errorRetrievingKeyDataInvalid
                }
                return data
            case errSecItemNotFound:
                throw PlutoError.errorRetrivingKeyFromKeychainKeyNotFound(service: service, account: account)
            default:
                throw PlutoError.errorRetrivingKeyFromKeychainWithStatus(status)
            }
        case .rawKey:
            var attributes: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationLabel: (service + account).data(using: .utf8)!,
                kSecReturnData: true
            ]
            accessGroup.map { attributes[kSecAttrAccessGroup] = $0 }
            var item: CFTypeRef?
            let status = SecItemCopyMatching(attributes as CFDictionary, &item)
            switch status {
            case errSecSuccess:
                guard let data = item as? Data else {
                    throw PlutoError.errorRetrievingKeyDataInvalid
                }
                return data
            case errSecItemNotFound:
                throw PlutoError.errorRetrivingKeyFromKeychainKeyNotFound(applicationLabel: service + account)
            default:
                throw PlutoError.errorRetrivingKeyFromKeychainWithStatus(status)
            }
        default:
            var attributes: [CFString: Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationLabel: service + account,
                kSecReturnRef: true
            ]
            accessGroup.map { attributes[kSecAttrAccessGroup] = $0 }
            var item: CFTypeRef?
            let status = SecItemCopyMatching(attributes as CFDictionary, &item)
            switch status {
            case errSecSuccess:
                guard let item else {
                    throw PlutoError.errorRetrivingKeyFromKeychainKeyNotFound(applicationLabel: service + account)
                }
                let secKey = item as! SecKey
                var error: Unmanaged<CFError>?
                guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
                    throw PlutoError.errorCouldNotRetrieveDataFromSecKeyObject(applicationLabel: service + account)
                }
                return data
            case errSecItemNotFound:
                throw PlutoError.errorRetrivingKeyFromKeychainKeyNotFound(applicationLabel: service + account)
            default:
                throw PlutoError.errorRetrivingKeyFromKeychainWithStatus(status)
            }
        }
    }
}

extension KeychainDAO: KeychainStore {
    func addKey(_ key: KeychainStorableKey, service: String, account: String) throws {
        let status = SecItemAdd(
            try key.getSecKeyAddItemDictionary(service: service, account: account, accessGroup: accessGroup),
            nil
        )
        guard status == errSecSuccess else {
            throw PlutoError.errorSavingKeyOnKeychainWithStatus(status)
        }
    }
}

extension KeychainStorableKey {
    func getSecKeyAddItemDictionary(service: String, account: String, accessGroup: String?) throws -> CFDictionary {
        switch type {
        case .genericPassword:
            var attributes: [CFString : Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
                kSecAttrApplicationLabel: account,
                kSecUseDataProtectionKeychain: true,
                kSecAttrSynchronizable: self.secSynchronizable,
                kSecValueData: self.storableData as CFData,
                kSecReturnData: true
            ]
            
            accessGroup.map { attributes[kSecAttrAccessGroup] = $0 }
            self.accessiblity.map { attributes[kSecAttrAccessible] = $0.secAccessible }
            return attributes as CFDictionary
        case .rawKey:
            var attributes: [CFString : Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationLabel: (service + account).data(using: .utf8)!,
                kSecAttrKeySizeInBits: self.storableData.count * 8,
                kSecAttrSynchronizable: self.secSynchronizable,
                kSecUseDataProtectionKeychain: true,
                kSecValueData: self.storableData as CFData,
                kSecReturnData: true
            ]

            accessGroup.map { attributes[kSecAttrAccessGroup] = $0 }
            self.accessiblity.map { attributes[kSecAttrAccessible] = $0.secAccessible }
            return attributes as CFDictionary
        default:
            var attributes: [CFString : Any] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationLabel: (service + account).data(using: .utf8)!,
                kSecAttrSynchronizable: self.secSynchronizable,
                kSecUseDataProtectionKeychain: true,
                kSecValueRef: try getSecKeyDictionary()
            ]

            accessGroup.map { attributes[kSecAttrAccessGroup] = $0 }
            self.accessiblity.map { attributes[kSecAttrAccessible] = $0.secAccessible }
            return attributes as CFDictionary
        }
    }

    func getSecKeyDictionary() throws -> SecKey {
        let attributes = [
            kSecAttrKeyType: self.type.secAttrKeyType,
            kSecAttrKeyClass: self.keyClass.secAttrKeyClass
        ] as CFDictionary

        guard let secKey = SecKeyCreateWithData(
            self.storableData as CFData,
            attributes,
            nil
        ) else { throw PlutoError.errorCreatingSecKey(keyType: self.type.rawValue, keyClass: self.keyClass.rawValue) }

        return secKey
    }
}

extension KeychainStorableKey {

    var secSynchronizable: Bool {
        switch self.accessiblity {
        case .none:
            return synchronizable
        case .firstUnlock(let deviceOnly), .unlocked(let deviceOnly):
            guard !deviceOnly else { return false } // It cannot be syncable when deviceOnly is true
            return synchronizable
        case .passwordSet:
            return false
        }
    }
}

extension KeychainStorableKeyProperties.KeyAlgorithm {

    var secAttrKeyType: CFString {
#if os(OSX)
        switch self {
        case .rsa:
            return kSecAttrKeyTypeRSA
        case .dsa:
            return kSecAttrKeyTypeDSA
        case .aes:
            return kSecAttrKeyTypeAES
        case .des:
            return kSecAttrKeyTypeDES
        case ._3des:
            return kSecAttrKeyType3DES
        case .rc4:
            return kSecAttrKeyTypeRC4
        case .rc2:
            return kSecAttrKeyTypeRC2
        case .cast:
            return kSecAttrKeyTypeCAST
        case .ec:
            return kSecAttrKeyTypeECSECPrimeRandom
        case .rawKey, .genericPassword:
            assertionFailure("This should never happen, if it got to this point some logic before failed")
            return "" as CFString
        }
#else
        switch self {
        case .rsa:
            return kSecAttrKeyTypeRSA
        case .ec:
            return kSecAttrKeyTypeECSECPrimeRandom
        case .dsa, .aes, .des, ._3des, .rc4, .rc2, .cast:
            assertionFailure("This type is only available in OSX")
            return "" as CFString
        default:
            assertionFailure("This should never happen, if it got to this point some logic before failed")
            return "" as CFString
        }
#endif
    }
}

extension KeychainStorableKeyProperties.KeyType {
    var secAttrKeyClass: CFString {
        switch self {
        case .privateKey:
            return kSecAttrKeyClassPrivate
        case .publicKey:
            return kSecAttrKeyClassPublic
        }
    }
}

extension KeychainStorableKeyProperties.Accessability {
    var secAccessible: CFString {
        switch self {
        case .firstUnlock(let deviceOnly):
            return deviceOnly ? kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly : kSecAttrAccessibleAfterFirstUnlock
        case .unlocked(let deviceOnly):
            return deviceOnly ? kSecAttrAccessibleWhenUnlockedThisDeviceOnly : kSecAttrAccessibleWhenUnlocked
        case .passwordSet:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
