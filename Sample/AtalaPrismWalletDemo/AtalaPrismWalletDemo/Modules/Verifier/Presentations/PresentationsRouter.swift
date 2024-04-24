import Domain
import PrismAgent
import SwiftUI

struct PresentationsViewRouterImpl: PresentationsViewRouter {
    let container: DIContainer

    func routeToCreate() -> some View {
        let viewModel = CreatePresentationViewModelImpl(prismAgent: container.resolve(type: PrismAgent.self)!)

        return CreatePresentationView(viewModel: viewModel)
    }

    func routeToDetail(id: String) -> some View {
        let viewModel = PresentationDetailViewModelImpl(
            id: id,
            agent: container.resolve(type: PrismAgent.self)!,
            pluto: container.resolve(type: Pluto.self)!
        )

        return PresentationDetailView(viewModel: viewModel)
    }
}
