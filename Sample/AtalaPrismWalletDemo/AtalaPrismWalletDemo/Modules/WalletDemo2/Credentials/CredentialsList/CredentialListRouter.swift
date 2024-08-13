import EdgeAgent
import SwiftUI

struct CredentialListRouterImpl: CredentialListRouter {
    let container: DIContainer

    func routeToCredentialDetail(id: String) -> some View {
        CredentialDetailView(viewModel: CredentialDetailViewModelImpl(
            agent: container.resolve(type: DIDCommAgent.self)!,
            credentialId: id
        ))
    }
}
