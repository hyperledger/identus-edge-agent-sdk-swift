import Builders
import Combine
import Domain
import PrismAgent
import SwiftUI

final class Main2RouterImpl: Main2ViewRouter {
    let container: DIContainer = DIContainerImpl()

    init() {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder().build()
        let pollux = PolluxBuilder().build()
        let mercury = MercuryBuilder(
            castor: castor,
            secretsStream: createSecretsStream(
                keyRestoration: apollo,
                pluto: pluto,
                castor: castor
            )
        ).build()
        let agent = PrismAgent(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux,
            mercury: mercury
        )
        container.register(type: Apollo.self, component: apollo)
        container.register(type: Castor.self, component: castor)
        container.register(type: Pluto.self, component: pluto)
        container.register(type: Pollux.self, component: pollux)
        container.register(type: Mercury.self, component: mercury)
        container.register(type: PrismAgent.self, component: agent)
    }

    func routeToMediator() -> some View {
        let viewModel = MediatorViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )
        return MediatorPageView(viewModel: viewModel)
    }

    func routeToDids() -> some View {
        let viewModel = DIDListViewModelImpl(
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )

        return DIDListView(viewModel: viewModel)
    }

    func routeToConnections() -> some View {
        let viewModel = ConnectionsListViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )

        return ConnectionsListView(viewModel: viewModel)
    }

    func routeToMessages() -> some View {
        let viewModel = MessagesListViewModelImpl(
            agent: container.resolve(type: PrismAgent.self)!
        )

        return MessagesListView(
            viewModel: viewModel,
            router: MessageListRouterImpl(container: container)
        )
    }

    func routeToCredentials() -> some View {
        let viewModel = CredentialListViewModelImpl(
            agent: container.resolve(type: PrismAgent.self)!
        )

        return CredentialListView(
            viewModel: viewModel,
            router: CredentialListRouterImpl(container: container)
        )
    }
}

private func createSecretsStream(
    keyRestoration: KeyRestoration,
    pluto: Pluto,
    castor: Castor
) -> AnyPublisher<[Secret], Error> {
    pluto.getAllPeerDIDs()
        .first()
        .flatMap { array in
            Future {
                try await array.asyncMap { did, privateKeys, _ in
                    let privateKeys = try await privateKeys.asyncMap {
                        try await keyRestoration.restorePrivateKey(
                            identifier: $0.restorationIdentifier,
                            data: $0.storableData
                        )
                    }
                    let secrets = try parsePrivateKeys(
                        did: did,
                        privateKeys: privateKeys,
                        castor: castor
                    )

                    return secrets
                }
            }
        }
        .map {
            $0.compactMap {
                $0
            }.flatMap {
                $0
            } }
        .eraseToAnyPublisher()
}

private func parsePrivateKeys(
    did: DID,
    privateKeys: [PrivateKey],
    castor: Castor
) throws -> [Domain.Secret] {
    return try privateKeys
        .map { $0 as? (PrivateKey & ExportableKey) }
        .compactMap { $0 }
        .map { privateKey in
        let ecnumbasis = try castor.getEcnumbasis(did: did, publicKey: privateKey.publicKey())
        return (did, privateKey, ecnumbasis)
    }
    .map { did, privateKey, ecnumbasis in
        try parseToSecret(
            did: did,
            privateKey: privateKey,
            ecnumbasis: ecnumbasis
        )
    }
}

private func parseToSecret(did: DID, privateKey: PrivateKey & ExportableKey, ecnumbasis: String) throws -> Domain.Secret {
    let id = did.string + "#" + ecnumbasis
    let jwk = privateKey.jwk
    guard
        let dataJson = try? JSONEncoder().encode(jwk),
        let stringJson = String(data: dataJson, encoding: .utf8)
    else {
        throw CommonError.invalidCoding(message: "Could not encode privateKey.jwk")
    }
    return .init(
        id: id,
        type: .jsonWebKey2020,
        secretMaterial: .jwk(value: stringJson)
    )
}
