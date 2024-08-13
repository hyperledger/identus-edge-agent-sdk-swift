import Builders
import Combine
import Domain
import EdgeAgent
import SwiftUI

final class MainVerifierRouterImpl: MainVerifierViewRouter {
    let container: DIContainer = DIContainerImpl()

    init() {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder().build()
        let pollux = PolluxBuilder(pluto: pluto, castor: castor).build()
        let mercury = MercuryBuilder(
            castor: castor,
            secretsStream: createSecretsStream(
                keyRestoration: apollo,
                pluto: pluto,
                castor: castor
            )
        ).build()
        let edgeAgent = EdgeAgent(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux
        )
        let didcommAgent = DIDCommAgent(edgeAgent: edgeAgent, mercury: mercury)
        let oidcAgent = OIDCAgent(edgeAgent: edgeAgent)
        container.register(type: Apollo.self, component: apollo)
        container.register(type: Castor.self, component: castor)
        container.register(type: Pluto.self, component: pluto)
        container.register(type: Pollux.self, component: pollux)
        container.register(type: Mercury.self, component: mercury)
        container.register(type: DIDCommAgent.self, component: didcommAgent)
        container.register(type: OIDCAgent.self, component: oidcAgent)
    }

    func routeToMediator() -> some View {
        let viewModel = MediatorViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: DIDCommAgent.self)!
        )
        return MediatorPageView(viewModel: viewModel)
    }

    func routeToDids() -> some View {
        let viewModel = DIDListViewModelImpl(
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: DIDCommAgent.self)!
        )

        return DIDListView(viewModel: viewModel)
    }

    func routeToConnections() -> some View {
        let viewModel = ConnectionsListViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: DIDCommAgent.self)!
        )

        return ConnectionsListView(
            router: ConnectionsListRouterImpl(container: container), 
            viewModel: viewModel
        )
    }

    func routeToMessages() -> some View {
        let viewModel = MessagesListViewModelImpl(
            agent: container.resolve(type: DIDCommAgent.self)!
        )

        return MessagesListView(
            viewModel: viewModel,
            router: MessageListRouterImpl(container: container)
        )
    }

    func routeToPresentations() -> some View {
        let viewModel = PresentationsViewModelImpl(
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: EdgeAgent.self)!
        )

        return PresentationsView(viewModel: viewModel, router: PresentationsViewRouterImpl(container: container))
    }

    func routeToCredentials() -> some View {
        let viewModel = CredentialListViewModelImpl(
            agent: container.resolve(type: DIDCommAgent.self)!,
            apollo: container.resolve(type: Apollo.self)! as! Apollo & KeyRestoration,
            pluto: container.resolve(type: Pluto.self)!
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
    pluto.getAllKeys()
        .first()
        .flatMap { keys in
            Future {
                let privateKeys = await keys.asyncMap {
                    try? await keyRestoration.restorePrivateKey($0)
                }.compactMap { $0 }
                return try parsePrivateKeys(
                    privateKeys: privateKeys,
                    castor: castor
                )
            }
        }
        .eraseToAnyPublisher()
}

private func parsePrivateKeys(
    privateKeys: [PrivateKey],
    castor: Castor
) throws -> [Domain.Secret] {
    return try privateKeys
        .map { $0 as? (PrivateKey & ExportableKey & StorableKey) }
        .compactMap { $0 }
        .map { privateKey in
        return privateKey
    }
    .map { privateKey in
        try parseToSecret(
            privateKey: privateKey,
            identifier: privateKey.identifier
        )
    }
}

private func parseToSecret(privateKey: PrivateKey & ExportableKey, identifier: String) throws -> Domain.Secret {
    let jwk = privateKey.jwk
    guard
        let dataJson = try? JSONEncoder().encode(jwk),
        let stringJson = String(data: dataJson, encoding: .utf8)
    else {
        throw CommonError.invalidCoding(message: "Could not encode privateKey.jwk")
    }
    return .init(
        id: identifier,
        type: .jsonWebKey2020,
        secretMaterial: .jwk(value: stringJson)
    )
}
