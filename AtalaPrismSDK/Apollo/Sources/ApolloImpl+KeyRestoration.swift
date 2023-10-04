import Domain
import Foundation

extension ApolloImpl: KeyRestoration {
    public func isPrivateKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("priv")
    }

    public func isPublicKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("pub")
    }

    public func restorePrivateKey(_ key: StorableKey) throws -> PrivateKey {
        switch  key.restorationIdentifier {
        case "secp256k1+priv":
            return Secp256k1PrivateKey(
                lockedPrivateKey: .init(data: key.storableData),
                derivationPath: key.index.map { DerivationPath(index: $0) } ?? DerivationPath(index: 0)
            )
        case "x25519+priv":
            return X25519PrivateKey(appleCurve: try .init(rawRepresentation: key.storableData))
        case "ed25519+priv":
            return Ed25519PrivateKey(appleCurve: try .init(rawRepresentation: key.storableData))
        default:
            throw ApolloError.restoratonFailedNoIdentifierOrInvalid
        }
    }

    public func restorePublicKey(_ key: StorableKey) throws -> PublicKey {
        switch key.restorationIdentifier {
        case "secp256k1+pub":
            return Secp256k1PublicKey(lockedPublicKey: .init(bytes: key.storableData))
        case "x25519+pub":
            return X25519PublicKey(appleCurve: try .init(rawRepresentation: key.storableData))
        case "ed25519+pub":
            return Ed25519PublicKey(appleCurve: try .init(rawRepresentation: key.storableData))
        default:
            throw ApolloError.restoratonFailedNoIdentifierOrInvalid
        }
    }
}
