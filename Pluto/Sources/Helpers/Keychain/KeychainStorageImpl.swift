import Foundation
import LocalAuthentication

struct KeychainStorageImpl: KeychainStorage {
    let service: String
    let accessGroup: String?

    func set(_ value: Data, forKey key: String) throws {
        guard
            let encodedIdentifier = key.data(using: String.Encoding.utf8)
        else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: encodedIdentifier,
            kSecAttrAccount as String: encodedIdentifier,
            kSecAttrService as String: service
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: value
        ]

        do {
            try createItem(query: query.merging(attributes, uniquingKeysWith: { _, new in
                new
            }))
        } catch KeychainWrapperError.itemDuplicated {
            try updateItem(query: query, attributes: attributes)
        } catch {
            throw error
        }
    }

    func set(
        _ value: Data,
        forKey key: String,
        security: SecurityTypeDomain
    ) throws {
        guard
            let encodedIdentifier = key.data(using: String.Encoding.utf8)
        else { return }

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: encodedIdentifier,
            kSecAttrAccount as String: encodedIdentifier,
            kSecAttrService as String: service
        ]

        switch security {
        case .none:
            break
        case let .password(password):
            let context = LAContext()
            context.setCredential(password.data(using: .utf8), type: .applicationPassword)
            query[kSecAttrAccessControl as String] = try getPwSecAccessControl()
            query[kSecUseAuthenticationContext as String] = context
        case .biometric:
            query[kSecAttrAccessControl as String] = try getBiometricsSecAccessControl()
        }

        let attributes: [String: Any] = [
            kSecValueData as String: value
        ]

        do {
            try createItem(query: query.merging(attributes, uniquingKeysWith: { _, new in
                new
            }))
        } catch KeychainWrapperError.itemDuplicated {
            try updateItem(query: query, attributes: attributes)
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }

    func get(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard
                let existingItem = item as? [String: Any],
                let value = existingItem[kSecValueData as String] as? Data
            else { throw KeychainWrapperError.wrongType }

            return value
        case errSecItemNotFound:
            throw KeychainWrapperError.itemNotFound
        case errSecAuthFailed:
            throw KeychainWrapperError.authFailed
        default:
            throw KeychainWrapperError.serviceError(status: status)
        }
    }

    func get(
        key: String,
        security: SecurityTypeDomain
    ) throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]

        switch security {
        case .none:
            break
        case .biometric:
            query[kSecAttrAccessControl as String] = try getBiometricsSecAccessControl()
        case let .password(password):
            let context = LAContext()
            context.setCredential(password.data(using: .utf8), type: .applicationPassword)
            query[kSecAttrAccessControl as String] = try getPwSecAccessControl()
            query[kSecUseAuthenticationContext as String] = context
        }

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard
                let existingItem = item as? [String: Any],
                let value = existingItem[kSecValueData as String] as? Data
            else { throw KeychainWrapperError.wrongType }

            return value
        case errSecItemNotFound:
            throw KeychainWrapperError.itemNotFound
        case errSecAuthFailed:
            throw KeychainWrapperError.authFailed
        default:
            throw KeychainWrapperError.serviceError(status: status)
        }
    }

    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainWrapperError.serviceError(status: status)
        }
    }

    func delete(key: String, security: SecurityTypeDomain) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]

        switch security {
        case .none:
            break
        case let .password(password):
            let context = LAContext()
            context.setCredential(password.data(using: .utf8), type: .applicationPassword)
            query[kSecAttrAccessControl as String] = try getPwSecAccessControl()
            query[kSecUseAuthenticationContext as String] = context
        case .biometric:
            query[kSecAttrAccessControl as String] = try getBiometricsSecAccessControl()
        }

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainWrapperError.serviceError(status: status)
        }
    }

    private func createItem(query: [String: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            throw KeychainWrapperError.itemDuplicated
        case errSecAuthFailed:
            throw KeychainWrapperError.authFailed
        case errSecParam:
            throw KeychainWrapperError.serviceError(status: status)
        default:
            throw KeychainWrapperError.serviceError(status: status)
        }
    }

    private func updateItem(query: [String: Any], attributes: [String: Any]) throws {
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        switch status {
        case errSecSuccess:
            return
        case errSecItemNotFound:
            throw KeychainWrapperError.itemNotFound
        case errSecAuthFailed:
            throw KeychainWrapperError.authFailed
        default:
            throw KeychainWrapperError.serviceError(status: status)
        }
    }

    private func getPwSecAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        guard
            let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.applicationPassword],
                &error
            )
        else {
            throw KeychainWrapperError.pwAccessCreationError
        }

        return access
    }

    private func getBiometricsSecAccessControl() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        guard
            let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                [.userPresence],
                &error
            )
        else {
            throw KeychainWrapperError.pwAccessCreationError
        }

        return access
    }
}
