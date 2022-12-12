import SwiftUI
import PrismAgent

struct HomeComponent {
    let agent: PrismAgent
}

struct HomeBuilder: Builder {
    func build(component: HomeComponent) -> some View {
        let viewModel = HomeViewModelImpl(
            agent: component.agent
        )

        return HomeView(viewModel: viewModel, router: HomeRouterImpl())
    }
}
