import PrismAgent
import SwiftUI
import UIKit

struct DashboardComponent: ComponentContainer {
    let container: DIContainer
}

struct DashboardBuilder: Builder {
    func build(component: DashboardComponent) -> some View {
        let viewModel = DashboardViewModelImpl(agent: component.container.resolve(type: PrismAgent.self)!)

        let view = DashboardView(
            router: DashboardRouterImpl(
                container: component.container,
                agent: component.container.resolve(type: PrismAgent.self)!
            ),
            viewModel: viewModel
        )

        return view
    }
}
