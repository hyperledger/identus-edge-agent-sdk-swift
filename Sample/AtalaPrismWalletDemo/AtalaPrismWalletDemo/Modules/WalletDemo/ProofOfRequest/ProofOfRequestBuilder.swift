import Combine
import Foundation
import PrismAgent
import SwiftUI

struct ProofOfRequestComponent: ComponentContainer {
    let proofOfRequest: RequestPresentation
    let container: DIContainer
}

struct ProofOfRequestBuilder: Builder {
    func build(component: ProofOfRequestComponent) -> some View {
        let viewModel = getViewModel(component: component) {
            ProofOfRequestViewModelImpl(
                proofOfRequest: component.proofOfRequest,
                agent: component.container.resolve(type: PrismAgent.self)!
            )
        }
        return ProofOfRequestView<ProofOfRequestViewModelImpl>(viewModel: viewModel)
            .onDisappear {
                component.container.unregister(type: ProofOfRequestViewModelImpl.self)
            }
    }
}
