import Domain
import Foundation

extension ApolloImpl: KeyRestoration {
    public func isPrivateKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("priv")
    }

    public func isPublicKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("pub")
    }

    public func restorePrivateKey(identifier: String?, data: Data) throws -> PrivateKey {
        guard let identifier else { throw UnknownError.somethingWentWrongError() }
        switch identifier {
        case "secp256k1+priv":
            return Secp256k1PrivateKey(lockedPrivateKey: .init(data: data))
        case "x25519+priv":
            return X25519PrivateKey(appleCurve: try .init(rawRepresentation: data))
        case "ed25519+priv":
            return Ed25519PrivateKey(appleCurve: try .init(rawRepresentation: data))
        default:
            throw UnknownError.somethingWentWrongError()
        }
    }

    public func restorePublicKey(identifier: String?, data: Data) throws -> PublicKey {
        guard let identifier else { throw UnknownError.somethingWentWrongError() }
        switch identifier {
        case "secp256k1+pub":
            return Secp256k1PublicKey(lockedPublicKey: .init(bytes: data))
        case "x25519+pub":
            return X25519PublicKey(appleCurve: try .init(rawRepresentation: data))
        case "ed25519+pub":
            return Ed25519PublicKey(appleCurve: try .init(rawRepresentation: data))
        default:
            throw UnknownError.somethingWentWrongError()
        }
    }
}
