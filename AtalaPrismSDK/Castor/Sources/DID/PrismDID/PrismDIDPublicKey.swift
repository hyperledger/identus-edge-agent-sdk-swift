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
    let keyData: PublicKeyD

    init(apollo: Apollo, id: String, usage: Usage, keyData: PublicKeyD) {
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
        case let .ecKeyData(value):
            keyData = apollo.publicKeyFrom(x: value.x, y: value.y)
        case let .compressedEcKeyData(value):
            keyData = apollo.uncompressedPublicKey(compressedData: value.data)
        default:
            throw CastorError.invalidPublicKeyCoding(didMethod: "prism", curve: "secp256k1")
        }
    }

    func toProto() throws -> Io_Iohk_Atala_Prism_Protos_PublicKey {
        var protoKey = Io_Iohk_Atala_Prism_Protos_PublicKey()
        protoKey.id = id
        protoKey.usage = usage.toProto()
        guard
            let pointXStr = keyData.getProperty(.curvePointX),
            let pointYStr = keyData.getProperty(.curvePointY),
            let pointX = Data(base64URLEncoded: pointXStr),
            let pointY = Data(base64URLEncoded: pointYStr)
        else {
            throw UnknownError.somethingWentWrongError()
        }
        var protoEC = Io_Iohk_Atala_Prism_Protos_ECKeyData()
        protoEC.x = pointX
        protoEC.y = pointY
        protoEC.curve = "secp256k1"
        protoKey.keyData = .ecKeyData(protoEC)
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

//private extension CompressedPublicKey {
//    func toProto() -> Io_Iohk_Atala_Prism_Protos_CompressedECKeyData {
//        var proto = Io_Iohk_Atala_Prism_Protos_CompressedECKeyData()
//        proto.curve = uncompressed.curve
//        proto.data = value
//        return proto
//    }
//}
