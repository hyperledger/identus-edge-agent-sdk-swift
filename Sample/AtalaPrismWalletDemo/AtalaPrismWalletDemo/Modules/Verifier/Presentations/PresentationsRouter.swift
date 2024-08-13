import Domain
import EdgeAgent
import SwiftUI

struct PresentationsViewRouterImpl: PresentationsViewRouter {
    let container: DIContainer

    func routeToCreate() -> some View {
        let viewModel = CreatePresentationViewModelImpl(edgeAgent: container.resolve(type: DIDCommAgent.self)!)

        return CreatePresentationView(viewModel: viewModel)
    }

    func routeToDetail(id: String) -> some View {
        let viewModel = PresentationDetailViewModelImpl(
            id: id,
            agent: container.resolve(type: DIDCommAgent.self)!,
            pluto: container.resolve(type: Pluto.self)!
        )

        return PresentationDetailView(viewModel: viewModel)
    }
}
