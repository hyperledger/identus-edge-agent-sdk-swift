import Core
import DIDCore
import Domain
import Foundation
import Multibase
import PeerDID

struct CreatePeerDIDOperation {
    private let method: DIDMethod = "peer"
    let autenticationPublicKey: PublicKey
    let agreementPublicKey: PublicKey
    let services: [Domain.DIDDocument.Service]

    func compute() throws -> Domain.DID {
        let did = try PeerDIDHelper.createAlgo2(
            authenticationKeys: [authenticationFromPublicKey(publicKey: autenticationPublicKey)],
            agreementKeys: [keyAgreementFromPublicKey(publicKey: agreementPublicKey)],
            services: services.flatMap { service in
                service.serviceEndpoint.map {
                    AnyCodable(dictionaryLiteral:
                        ("id", service.id),
                        ("type", service.type.first ?? ""),
                        ("serviceEndpoint", [
                            "uri" : $0.uri,
                            "accept" : $0.accept,
                            "routing_keys" : $0.routingKeys
                        ])
                    )
                }
            }
        )
        return try .init(string: did.string)
    }

    private func keyAgreementFromPublicKey(publicKey: PublicKey) throws -> PeerDIDVerificationMaterial {
        guard
            publicKey.getProperty(.curve)?.lowercased() == KnownKeyCurves.x25519.rawValue
        else { throw CastorError.invalidPublicKeyCoding(didMethod: "peer", curve: KnownKeyCurves.x25519.rawValue) }
        return try .init(
            format: .jwk,
            key: publicKey.raw,
            type: .agreement(.jsonWebKey2020)
        )
    }

    private func authenticationFromPublicKey(publicKey: PublicKey) throws -> PeerDIDVerificationMaterial {
        guard
            publicKey.getProperty(.curve)?.lowercased() == KnownKeyCurves.ed25519.rawValue
        else {
            throw CastorError.invalidPublicKeyCoding(
                didMethod: "peer",
                curve: KnownKeyCurves.ed25519.rawValue
            )
        }

        return try .init(
            format: .jwk,
            key: publicKey.raw,
            type: .authentication(.jsonWebKey2020)
        )
    }
}
