import Core
import Domain
import Foundation
import Multibase

struct CreatePeerDIDOperation {
    enum Numalgo2Prefix: String {
        case authentication = "V"
        case keyAgreement = "E"
        case service = "S"
    }

    struct OctetPublicKey: Codable {
        enum CodingKeys: String, CodingKey {
            case kty
            case crv
            case key = "x"
        }

        let kty = "OKP"
        let crv: String
        let key: String
    }

    private let method: DIDMethod = "peer"
    let autenticationPublicKey: PublicKeyD
    let agreementPublicKey: PublicKeyD
    let services: [DIDDocument.Service]

    func compute() throws -> DID {
        return try createPeerDID(
            encryptionKeys: [try keyAgreementFromPublicKey(publicKey: agreementPublicKey)],
            signingKeys: [try authenticationFromPublicKey(publicKey: autenticationPublicKey)],
            services: services
        ).did
    }

    func computeEcnumbasis(did: DID, publicKey: PublicKeyD) throws -> String {
        guard
            let curve = publicKey.getProperty(.curve)?.lowercased()
        else { throw UnknownError.somethingWentWrongError() }
        switch curve {
        case KnownKeyCurves.x25519.rawValue:
            let material = try keyAgreementFromPublicKey(publicKey: agreementPublicKey)
            let multibaseEcnumbasis = try createMultibaseEncnumbasis(material: material)
            return String(multibaseEcnumbasis.dropFirst())
        case KnownKeyCurves.ed25519.rawValue:
            let material = try authenticationFromPublicKey(publicKey: autenticationPublicKey)
            let multibaseEcnumbasis = try createMultibaseEncnumbasis(material: material)
            return String(multibaseEcnumbasis.dropFirst())
        default:
            throw CastorError.keyCurveNotSupported(curve: curve)
        }
    }

    private func createPeerDID(
        encryptionKeys: [VerificationMaterialAgreement],
        signingKeys: [VerificationMaterialAuthentication],
        services: [DIDDocument.Service]
    ) throws -> PeerDID {
        let encodedEncryptionKeysStr = try encryptionKeys
            .map { try createMultibaseEncnumbasis(material: $0) }
            .map {
                ".\(Numalgo2Prefix.keyAgreement.rawValue)\($0)"
            }
            .joined()
        let encodedSigningKeysStr = try signingKeys
            .map { try createMultibaseEncnumbasis(material: $0) }
            .map {
                ".\(Numalgo2Prefix.authentication.rawValue)\($0)"
            }
            .joined()
        let encodedService = try encodeService(services: services)

        return try PeerDID(did: .init(
            method: "peer",
            methodId: "2"
            + encodedEncryptionKeysStr
            + encodedSigningKeysStr
            + "."
            + Numalgo2Prefix.service.rawValue
            + encodedService
        ))
    }

    private func keyAgreementFromPublicKey(publicKey: PublicKeyD) throws -> VerificationMaterialAgreement {
        guard
            let exportable = publicKey.exporting,
            publicKey.getProperty(.curve)?.lowercased() == KnownKeyCurves.x25519.rawValue,
            let jwkString = String(data: try JSONEncoder.didComm().encode(exportable.jwk), encoding: .utf8)
        else { throw CastorError.invalidPublicKeyCoding(didMethod: "peer", curve: KnownKeyCurves.x25519.rawValue) }
        return .init(
            format: .jwk,
            value: jwkString,
            type: .jsonWebKey2020
        )
    }

    private func authenticationFromPublicKey(publicKey: PublicKeyD) throws -> VerificationMaterialAuthentication {
        guard
            let exportable = publicKey.exporting,
            publicKey.getProperty(.curve)?.lowercased() == KnownKeyCurves.ed25519.rawValue,
            let jwkString = String(data: try JSONEncoder.didComm().encode(exportable.jwk), encoding: .utf8)
        else { throw CastorError.invalidPublicKeyCoding(didMethod: "peer", curve: KnownKeyCurves.ed25519.rawValue) }
        return .init(
            format: .jwk,
            value: jwkString,
            type: .jsonWebKey2020
        )
    }

    private func toBase58Multibase(value: Data) -> String {
        value.asString(base: .base58btc, withMultibasePrefix: true)
    }

    private func createMultibaseEncnumbasis(material: VerificationMaterialAgreement) throws -> String {
        let decodedKey: Data?
        switch material.format {
        case .jwk:
            decodedKey = try JWKHelper().fromJWK(material: material)
        }
        guard let decodedKey else { throw CastorError.invalidJWKError }
        try validateRawKeyLength(key: decodedKey)
        let multiCodec = Multicodec(value: decodedKey, keyType: .agreement).value
        return toBase58Multibase(value: multiCodec)
    }

    private func createMultibaseEncnumbasis(material: VerificationMaterialAuthentication) throws -> String {
        let decodedKey: Data?
        switch material.format {
        case .jwk:
            decodedKey = try JWKHelper().fromJWK(material: material)
        }
        guard let decodedKey else { throw CastorError.invalidJWKError }
        try validateRawKeyLength(key: decodedKey)
        let multiCodec = Multicodec(value: decodedKey, keyType: .authenticate).value
        return toBase58Multibase(value: multiCodec)
    }

    private func encodeService(services: [DIDDocument.Service]) throws -> String {
        let peerDidServices: [PeerDID.Service] = services.map { service in
            guard
                let type = service.type.first,
                let endpoint = service.serviceEndpoint.first
            else { return nil }
            return PeerDID.Service(
                type: type,
                serviceEndpoint: endpoint.uri,
                routingKeys: endpoint.routingKeys,
                accept: endpoint.accept
            )
        }.compactMap { $0 }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        if
            peerDidServices.count == 1,
            let peerDidService = peerDidServices.first
        {
            return try encoder.encode(peerDidService).base64UrlEncodedString()
        } else {
            return try encoder.encode(peerDidServices).base64UrlEncodedString()
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
