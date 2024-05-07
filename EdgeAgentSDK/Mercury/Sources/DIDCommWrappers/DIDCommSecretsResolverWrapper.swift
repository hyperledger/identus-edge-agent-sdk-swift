import Combine
import Core
import DIDCommSwift
import DIDCore
import Domain
import Foundation

// TODO: Find a way to take out the apollo, pluto and castor dependencies

class DIDCommSecretsResolverWrapper {
    let castor: Castor
    let logger: SDKLogger
    let secretsStream: AnyPublisher<[Domain.Secret], Error>

    init(
        secretsStream: AnyPublisher<[Domain.Secret], Error>,
        castor: Castor,
        logger: SDKLogger
    ) {
        self.secretsStream = secretsStream
        self.castor = castor
        self.logger = logger
    }

    fileprivate func getListOfAllSecrets() async throws -> [Domain.Secret] {
        try await secretsStream
            .first()
            .await()
    }
}

extension DIDCommSecretsResolverWrapper: DIDCommSwift.SecretResolver {
    func findKey(kid: String) async throws -> DIDCommSwift.Secret? {
        guard 
            let secret = try? await getListOfAllSecrets()
                .first(where: {
                    $0.id == kid
                }) 
        else {
            let error = MercuryError.didcommError(
                msg: "Could not find secret \(kid)",
                underlyingErrors: nil
            )
            logger.error(error: error)
            throw error
        }
        return try .init(from: secret)
        
    }
    func findKeys(kids: Set<String>) async throws -> Set<String> {
        let secretidsaux = kids.map { $0.replacingOccurrences(of: "/#", with: "#") }
        let secrets = try await getListOfAllSecrets()
            .filter { secretidsaux.contains($0.id) }
            .map { $0.id }
        let secretsSet = Set(secretidsaux)
        let resultsSet = Set(secrets)
        let missingSecrets = secretsSet.subtracting(resultsSet)
        if !missingSecrets.isEmpty {
            let mercuryError = MercuryError.didcommError(
                msg: "Could not find secrets \(missingSecrets.joined(separator: "\n"))",
                underlyingErrors: nil
            )
            logger.error(error: mercuryError)
        }
        return kids
    }
}

extension DIDCommSwift.Secret {
    init(from: Domain.Secret) throws {
        let type: KnownVerificationMaterialType
        let material: VerificationMaterial
        let jwkData: Data
        switch from.secretMaterial {
        case .jwk(let value):
            jwkData = try value.tryToData()
        }
        
        let jwk = try JSONDecoder().decode(DIDCore.JWK.self, from: jwkData)
        
        switch (from.type, jwk.crv?.lowercased()) {
        case (.jsonWebKey2020, "x25519"):
            type = .agreement(.jsonWebKey2020)
        case (.jsonWebKey2020, "ed25519"):
            type = .authentication(.jsonWebKey2020)
        default:
            type = .authentication(.jsonWebKey2020)
        }

        switch from.secretMaterial {
        case let .jwk(value):
            material = try .fromJWK(jwk: jwk)
        }
        self.init(
            kid: from.id,
            type: type,
            verificationMaterial: material
        )
    }
}
