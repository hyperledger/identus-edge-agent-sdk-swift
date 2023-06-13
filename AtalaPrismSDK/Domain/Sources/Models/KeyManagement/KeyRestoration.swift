import Foundation

public protocol KeyRestoration {
    func isPrivateKeyData(identifier: String, data: Data) throws -> Bool
    func isPublicKeyData(identifier: String, data: Data) throws -> Bool
    func restorePrivateKey(identifier: String?, data: Data) async throws -> PrivateKey
    func restorePublicKey(identifier: String?, data: Data) async throws -> PublicKey
}

public extension KeyRestoration {
    func restorePrivateKey(data: Data) async throws -> PrivateKey {
        try await restorePrivateKey(identifier: nil, data: data)
    }

    func restorePublicKey(data: Data) async throws -> PublicKey {
        try await restorePublicKey(identifier: nil, data: data)
    }
}
