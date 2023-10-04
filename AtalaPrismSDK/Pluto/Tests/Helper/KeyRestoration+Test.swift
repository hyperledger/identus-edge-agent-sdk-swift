import Domain
import Foundation

struct MockKeyRestoration: KeyRestoration {
    func isPrivateKeyData(identifier: String, data: Data) throws -> Bool {
        identifier == "MockPrivate"
    }

    func isPublicKeyData(identifier: String, data: Data) throws -> Bool {
        identifier == "MockPublic"
    }

    func restorePrivateKey(_ key: Domain.StorableKey) throws -> PrivateKey {
        MockPrivateKey(raw: key.storableData)
    }

    func restorePublicKey(_ key: Domain.StorableKey) throws -> PublicKey {
        MockPublicKey(raw: key.storableData)
    }
}
