import Builders
import Domain
import PrismAgent
import SwiftUI

final class Main2RouterImpl: Main2ViewRouter {
    let container: DIContainer = DIContainerImpl()

    init() {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder(keyRestoration: apollo).build()
        let pollux = PolluxBuilder(apollo: apollo, castor: castor).build()
        let mercury = MercuryBuilder(apollo: apollo, castor: castor, pluto: pluto).build()
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
