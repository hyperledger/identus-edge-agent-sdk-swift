import Domain
import PrismAgent
import SwiftUI

struct SettingsViewRouterImpl: SettingsViewRouter {
    let container: DIContainer

    func routeToDIDs() -> some View {
        let viewModel = DIDListViewModelImpl(
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )

        return DIDListView(viewModel: viewModel)
    }

    func routeToMediator() -> some View {
        let viewModel = MediatorViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )
        return MediatorPageView(viewModel: viewModel)
    }
}
