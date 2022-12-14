import SwiftUI
import PrismAgent

struct HomeComponent {
    let container: DIContainer
}

struct HomeBuilder: Builder {
    func build(component: HomeComponent) -> some View {
        let viewModel = HomeViewModelImpl(
            agent: component.container.resolve(type: PrismAgent.self)!
        )

        return HomeView(viewModel: viewModel, router: HomeRouterImpl())
    }
}
