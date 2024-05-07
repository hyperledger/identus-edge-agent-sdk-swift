import Domain
import EdgeAgent
import SwiftUI

struct SettingsViewRouterImpl: SettingsViewRouter {
    let container: DIContainer

    func routeToDIDs() -> some View {
        let viewModel = DIDListViewModelImpl(
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: EdgeAgent.self)!
        )

        return DIDListView(viewModel: viewModel)
    }

    func routeToMediator() -> some View {
        let viewModel = MediatorViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: EdgeAgent.self)!
        )
        return MediatorPageView(viewModel: viewModel)
    }
}
