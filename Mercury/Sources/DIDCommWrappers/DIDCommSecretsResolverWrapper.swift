import Combine
import Core
import DIDCommxSwift
import Domain
import Foundation

// TODO: Find a way to take out the apollo, pluto and castor dependencies

class DIDCommSecretsResolverWrapper {
    let apollo: Apollo
    let pluto: Pluto
    let castor: Castor
    let logger: PrismLogger
    @Published var availableSecrets = [Domain.Secret]()
    var cancellables = [AnyCancellable]()

    init(apollo: Apollo, pluto: Pluto, castor: Castor, logger: PrismLogger) {
        self.apollo = apollo
        self.pluto = pluto
        self.castor = castor
        self.logger = logger

        startUpdating()
    }

    private func startUpdating() {
        pluto
            .getAllPeerDIDs()
            .tryMap { [weak self] in
                try $0.map { did, privateKeys in
                    try self?.parsePrivateKeys(did: did, privateKeys: privateKeys)
                }
            }
            .map { $0.compactMap { $0 }.flatMap { $0 } }
            .replaceError(with: [])
            .assign(to: &$availableSecrets)
    }

    private func parsePrivateKeys(
        did: DID,
        privateKeys: [PrivateKey]
    ) throws -> [Domain.Secret] {
        return try privateKeys.map { privateKey in
            let keyPair = try apollo.createKeyPair(
                seed: Seed(value: Data()), // We dont need seed for peer did
                privateKey: privateKey
            )
            let ecnumbasis = try castor.getEcnumbasis(did: did, keyPair: keyPair)
            return (did, keyPair, ecnumbasis)
        }
        .map { did, keyPair, ecnumbasis in
            try parseToSecret(did: did, keyPair: keyPair, ecnumbasis: ecnumbasis)
        }
    }

    private func parseToSecret(did: DID, keyPair: KeyPair, ecnumbasis: String) throws -> Domain.Secret {
        let id = did.string + "#" + ecnumbasis
        return .init(
            id: id,
            type: .jsonWebKey2020,
            secretMaterial: .jwk(value: try apollo.getPrivateJWKJson(id: id, keyPair: keyPair))
        )
    }
}

extension DIDCommSecretsResolverWrapper: SecretsResolver {
    func getSecret(
        secretid: String,
        cb: OnGetSecretResult
    ) -> ErrorCode {
        $availableSecrets
            .first()
            .map { $0.first { $0.id == secretid } }
            .sink { [weak self] in
                do {
                    try cb.success(result: $0.map { DIDCommxSwift.Secret(from: $0) })
                } catch {
                    self?.logger.error(message: "Could not find secret", metadata: [
                        .publicMetadata(key: "SecretId", value: secretid),
                        .publicMetadata(key: "Error", value: error.localizedDescription)
                    ])
                }
            }
            .store(in: &cancellables)
        return .success
    }

    func findSecrets(
        secretids: [String],
        cb: OnFindSecretsResult
    ) -> ErrorCode {
        $availableSecrets
            .first()
            .map {
                $0
                .filter { secretids.contains($0.id) }
                .map { $0.id }
            }
            .sink { [weak self] in
                do {
                    try cb.success(result: $0)
                } catch {
                    self?.logger.error(message: "Could not find secrets", metadata: [
                        .publicMetadata(key: "SecretsIds", value: secretids.description),
                        .publicMetadata(key: "Error", value: error.localizedDescription)
                    ])
                }
            }
            .store(in: &cancellables)
        return .success
    }
}

extension DIDCommxSwift.Secret {
    init(from: Domain.Secret) {
        let type: SecretType
        let material: SecretMaterial
        switch from.type {
        case .jsonWebKey2020:
            type = .jsonWebKey2020
        }

        switch from.secretMaterial {
        case let .jwk(value):
            material = .jwk(value: value)
        }
        self.init(
            id: from.id,
            type: type,
            secretMaterial: material
        )
    }
}
