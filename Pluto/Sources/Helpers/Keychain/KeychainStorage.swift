import Foundation

enum KeychainWrapperError: Error {
    case serviceError(status: OSStatus)
    case wrongType
    case itemNotFound
    case itemDuplicated
    case pwAccessCreationError
    case authFailed
}

enum SecurityTypeDomain {
    case none
    case password(String)
    case biometric
}

protocol KeychainStorage {
    func set(_ value: Data, forKey key: String) throws
    func set(
        _ value: Data,
        forKey key: String,
        security: SecurityTypeDomain
    ) throws

    func get(key: String) throws -> Data
    func get(
        key: String,
        security: SecurityTypeDomain
    ) throws -> Data

    func delete(key: String) throws
    func delete(
        key: String,
        security: SecurityTypeDomain
    ) throws
}
