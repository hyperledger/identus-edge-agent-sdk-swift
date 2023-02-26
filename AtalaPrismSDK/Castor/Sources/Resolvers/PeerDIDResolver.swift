import Core
import Domain
import Foundation
import Multibase

struct PeerDIDResolver: DIDResolverDomain {
    var method = "peer"

    func resolve(did: DID) async throws -> DIDDocument {
        guard
            did.method == "peer",
            did.methodId.prefix(1) == "2"
        else { throw CastorError.notPossibleToResolveDID(
            did: did.string,
            reason: "Method or method id are invalid"
        )}

        return try buildDIDDocumentAlgo2(did: did, format: .jwk)
    }

    private func buildDIDDocumentAlgo2(
        did: DID,
        format: VerificationMaterialFormatPeerDID
    ) throws -> DIDDocument {
        let composition = did.methodId.components(separatedBy: ".").dropFirst()
        var authenticationMethods = [DIDDocument.VerificationMethod]()
        var keyAgreementMethods = [DIDDocument.VerificationMethod]()
        var services = [DIDDocument.Service]()
        try composition.forEach {
            switch $0.prefix(1) {
            case CreatePeerDIDOperation.Numalgo2Prefix.authentication.rawValue:
                let decoded = try decodeMultibaseEncnumbasisAuth(
                    did: did,
                    multibase: String($0.dropFirst()),
                    format: .jwk
                )
                authenticationMethods.append(try getVerificationMethod(did: did, decodedEncumbasis: decoded))
            case CreatePeerDIDOperation.Numalgo2Prefix.keyAgreement.rawValue:
                let decoded = try decodeMultibaseEncnumbasisAgreement(
                    did: did,
                    multibase: String($0.dropFirst()),
                    format: .jwk
                )
                keyAgreementMethods.append(try getVerificationMethod(did: did, decodedEncumbasis: decoded))
            case CreatePeerDIDOperation.Numalgo2Prefix.service.rawValue:
                services.append(contentsOf: try decodeService(
                    did: did,
                    encodedString: String($0.dropFirst())
                ))
            default:
                break
            }
        }

        return DIDDocument(
            id: did,
            coreProperties: [
                DIDDocument.VerificationMethods(
                    values: authenticationMethods + keyAgreementMethods
                ),
                DIDDocument.Authentication(
                    urls: authenticationMethods.map { $0.id.string },
                    verificationMethods: []
                ),
                DIDDocument.KeyAgreement(
                    urls: keyAgreementMethods.map { $0.id.string },
                    verificationMethods: []
                ),
                DIDDocument.Services(values: services)
            ]
        )
    }

    func decodeMultibaseEncnumbasisAuth(
        did: DID,
        multibase: String,
        format: VerificationMaterialFormatPeerDID
    ) throws -> (String, VerificationMaterialAuthentication) {
        let (decoded, verMaterial) = try decodeMultibaseEncnumbasis(
            multibase: multibase,
            format: format, defaultCodec: .ed25519
        )
        guard let material = verMaterial.authentication else {
            throw CastorError.notPossibleToResolveDID(
                did: did.string,
                reason: "Could not decode authentication multibase"
            )
        }
        return (decoded, material)
    }

    private func decodeMultibaseEncnumbasisAgreement(
        did: DID,
        multibase: String,
        format: VerificationMaterialFormatPeerDID
    ) throws -> (String, VerificationMaterialAgreement) {
        let (decoded, verMaterial) = try decodeMultibaseEncnumbasis(
            multibase: multibase,
            format: format, defaultCodec: .x25519
        )
        guard let material = verMaterial.agreement else {
            throw CastorError.notPossibleToResolveDID(
                did: did.string,
                reason: "Could not decode key agreement multibase"
        )}

        return (decoded, material)
    }

    private func decodeMultibaseEncnumbasis(
        multibase: String,
        format: VerificationMaterialFormatPeerDID,
        defaultCodec: Multicodec.Codec
    ) throws -> (String, VerificationMaterialPeerDID) {
        let (encnum, encnumData) = try fromBase58Multibase(multibase: multibase)
        let (codec, decodedEncnum) = try Multicodec(value: encnumData).decode()
        try validateRawKeyLength(key: decodedEncnum)
        switch format {
        case .jwk:
            switch codec {
            case .x25519:
                guard let jwkJsonString = try JWKHelper().toJWK(
                    publicKey: decodedEncnum,
                    material: VerificationMethodTypeAgreement.jsonWebKey2020
                ) else { throw CastorError.invalidJWKError }

                return (encnum, VerificationMaterialAgreement(
                    format: format,
                    value: jwkJsonString,
                    type: .jsonWebKey2020
                ))
            case .ed25519:
                guard let jwkJsonString = try JWKHelper().toJWK(
                    publicKey: decodedEncnum,
                    material: VerificationMethodTypeAuthentication.jsonWebKey2020
                ) else { throw CastorError.invalidJWKError }

                return  (encnum, VerificationMaterialAuthentication(
                    format: format,
                    value: jwkJsonString,
                    type: .jsonWebKey2020
                ))
            }
        }
    }

    private func fromBase58Multibase(multibase: String) throws -> (String, Data) {
        let multibaseDecoding = try BaseEncoding.decode(multibase)
        return (String(multibase.dropFirst()), multibaseDecoding.data)
    }

    private func getVerificationMethod(
        did: DID,
        decodedEncumbasis: (String, VerificationMaterialPeerDID)
    ) throws -> DIDDocument.VerificationMethod {
        var jsonDic = try convertToDictionary(string: decodedEncumbasis.1.value)
        jsonDic?["kid"] = did.string + "#" + decodedEncumbasis.0
        return .init(
            id: .init(did: did, fragment: decodedEncumbasis.0),
            controller: did,
            type: decodedEncumbasis.1.keyType.value,
            publicKeyJwk: jsonDic
        )
    }

    private func decodeService(did: DID, encodedString: String) throws -> [DIDDocument.Service] {
        guard let jsonData = Data(fromBase64URL: encodedString) else {
            throw CastorError.notPossibleToResolveDID(
                did: did.string,
                reason: "Could not parse Service JSON"
            )
        }
        let services = try jsonDecoderForServicePeerDIDService(jsonData: jsonData)
        return services.enumerated().map {
            DIDDocument.Service(
                id: did.string + $0.element.type.lowercased() + "-\($0.offset)",
                type: [$0.element.type],
                serviceEndpoint: [.init(
                    uri: $0.element.serviceEndpoint,
                    accept: $0.element.accept,
                    routingKeys: $0.element.routingKeys
                )]
            )
        }
    }

    private func jsonDecoderForServicePeerDIDService(jsonData: Data) throws -> [PeerDID.Service] {
        do {
            return try JSONDecoder().decode([PeerDID.Service].self, from: jsonData)
        } catch {
            let decoded = try JSONDecoder().decode(PeerDID.Service.self, from: jsonData)
            return [decoded]
        }
    }

    private func validateRawKeyLength(key: Data) throws {
        guard key.count == 32 else {
            throw UnknownError.somethingWentWrongError(
                customMessage: "Invalid secp256k1 key size of 32 bytes",
                underlyingErrors: nil
            )
        }
    }
}
