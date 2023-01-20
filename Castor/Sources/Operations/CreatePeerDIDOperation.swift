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
    let autenticationKeyPair: KeyPair
    let agreementKeyPair: KeyPair
    let services: [DIDDocument.Service]

    func compute() throws -> DID {
        return try createPeerDID(
            encryptionKeys: [try keyAgreementFromKeyPair(keyPair: agreementKeyPair)],
            signingKeys: [try authenticationFromKeyPair(keyPair: autenticationKeyPair)],
            services: services
        ).did
    }

    func computeEcnumbasis(did: DID, keyPair: KeyPair) throws -> String {
        switch keyPair.curve {
        case .x25519:
            let material = try keyAgreementFromKeyPair(keyPair: keyPair)
            let multibaseEcnumbasis = try createMultibaseEncnumbasis(material: material)
            return String(multibaseEcnumbasis.dropFirst())
        case .ed25519:
            let material = try authenticationFromKeyPair(keyPair: keyPair)
            let multibaseEcnumbasis = try createMultibaseEncnumbasis(material: material)
            return String(multibaseEcnumbasis.dropFirst())
        default:
            throw CommonError.somethingWentWrongError
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

    private func keyAgreementFromKeyPair(keyPair: KeyPair) throws -> VerificationMaterialAgreement {
        let octet = octetPublicKey(keyPair: keyPair)
        guard
            keyPair.curve == .x25519,
            let octetString = String(data: try JSONEncoder.didComm().encode(octet), encoding: .utf8)
        else { throw CastorError.invalidPublicKeyEncoding }
        return .init(
            format: .jwk,
            value: octetString,
            type: .jsonWebKey2020
        )
    }

    private func authenticationFromKeyPair(keyPair: KeyPair) throws -> VerificationMaterialAuthentication {
        let octet = octetPublicKey(keyPair: keyPair)
        guard
            keyPair.curve == .ed25519,
            let octetString = String(data: try JSONEncoder.didComm().encode(octet), encoding: .utf8)
        else { throw CastorError.invalidPublicKeyEncoding }
        return .init(
            format: .jwk,
            value: octetString,
            type: .jsonWebKey2020
        )
    }

    private func octetPublicKey(keyPair: KeyPair) -> OctetPublicKey {
        OctetPublicKey(
            crv: keyPair.curve.name,
            key: keyPair.publicKey.value.base64UrlEncodedString()
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
        guard let decodedKey else { throw CastorError.invalidKeyError }
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
        guard let decodedKey else { throw CastorError.invalidKeyError }
        try validateRawKeyLength(key: decodedKey)
        let multiCodec = Multicodec(value: decodedKey, keyType: .authenticate).value
        return toBase58Multibase(value: multiCodec)
    }

    private func encodeService(services: [DIDDocument.Service]) throws -> String {
        let peerDidServices: [PeerDID.Service] = services.compactMap {
            guard let type = $0.type.first else { return nil }
            return PeerDID.Service(
                type: type,
                serviceEndpoint: $0.serviceEndpoint.uri,
                routingKeys: $0.serviceEndpoint.routingKeys,
                accept: $0.serviceEndpoint.accept
            )
        }
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
        guard key.count == 32 else { throw CastorError.invalidKeyError }
    }
}
