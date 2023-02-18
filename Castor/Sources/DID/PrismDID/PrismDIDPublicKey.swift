import Domain
import Foundation

struct PrismDIDPublicKey {
    enum Usage: String {
        case masterKey
        case issuingKey
        case keyAgreementKey
        case capabilityDelegationKey
        case capabilityInvocationKey
        case authenticationKey
        case revocationKey
        case unknownKey

        var defaultId: String {
            id(index: 0)
        }

        func toProto() -> Io_Iohk_Atala_Prism_Protos_KeyUsage {
            switch self {
            case .masterKey:
                return .masterKey
            case .issuingKey:
                return .issuingKey
            case .capabilityInvocationKey:
                return .capabilityInvocationKey
            case .capabilityDelegationKey:
                return .capabilityDelegationKey
            case .authenticationKey:
                return .authenticationKey
            case .revocationKey:
                return .revocationKey
            case .keyAgreementKey:
                return .keyAgreementKey
            case .unknownKey:
                return .unknownKey
            }
        }

        func id(index: Int) -> String {
            switch self {
            case .masterKey:
                return "master\(index)"
            case .issuingKey:
                return "issuing\(index)"
            case .capabilityDelegationKey:
                return "capabilityDelegationKey\(index)"
            case .capabilityInvocationKey:
                return "capabilityInvocationKey\(index)"
            case .authenticationKey:
                return "authentication\(index)"
            case .revocationKey:
                return "revocation\(index)"
            case .keyAgreementKey:
                return "keyAgreement\(index)"
            case .unknownKey:
                return "unknown\(index)"
            }
        }
    }

    let apollo: Apollo
    let id: String
    let usage: Usage
    let keyData: PublicKey

    init(apollo: Apollo, id: String, usage: Usage, keyData: PublicKey) {
        self.apollo = apollo
        self.id = id
        self.usage = usage
        self.keyData = keyData
    }

    init(apollo: Apollo, proto: Io_Iohk_Atala_Prism_Protos_PublicKey) throws {
        self.apollo = apollo
        id = proto.id
        usage = proto.usage.fromProto()
        switch proto.keyData {
        case let .compressedEcKeyData(value):
            keyData = apollo.compressedPublicKey(compressedData: value.data).uncompressed
        default:
            throw CastorError.invalidPublicKeyEncoding
        }
    }

    func toProto() -> Io_Iohk_Atala_Prism_Protos_PublicKey {
        var protoKey = Io_Iohk_Atala_Prism_Protos_PublicKey()
        protoKey.id = id
        protoKey.usage = usage.toProto()
        let compressed = apollo.compressedPublicKey(publicKey: keyData)
        protoKey.keyData = .compressedEcKeyData(compressed.toProto())
        return protoKey
    }
}

private extension Io_Iohk_Atala_Prism_Protos_KeyUsage {
    func fromProto() -> PrismDIDPublicKey.Usage {
        switch self {
        case .masterKey:
            return .masterKey
        case .unknownKey:
            return .unknownKey
        case .issuingKey:
            return .issuingKey
        case .capabilityInvocationKey:
            return .capabilityInvocationKey
        case .capabilityDelegationKey:
            return .capabilityDelegationKey
        case .authenticationKey:
            return .authenticationKey
        case .revocationKey:
            return .revocationKey
        case .keyAgreementKey:
            return .keyAgreementKey
        case .UNRECOGNIZED:
            return .unknownKey
        }
    }
}

private extension CompressedPublicKey {
    func toProto() -> Io_Iohk_Atala_Prism_Protos_CompressedECKeyData {
        var proto = Io_Iohk_Atala_Prism_Protos_CompressedECKeyData()
        proto.curve = uncompressed.curve
        proto.data = value
        return proto
    }
}
