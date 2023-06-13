import Domain
import Foundation

struct MockKeyRestoration: KeyRestoration {
    func isPrivateKeyData(identifier: String, data: Data) throws -> Bool {
        identifier == "MockPrivate"
    }

    func isPublicKeyData(identifier: String, data: Data) throws -> Bool {
        identifier == "MockPublic"
    }

    func restorePrivateKey(identifier: String?, data: Data) throws -> PrivateKey {
        MockPrivateKey(raw: data)
    }

    func restorePublicKey(identifier: String?, data: Data) throws -> PublicKey {
        MockPublicKey(raw: data)
    }
}
