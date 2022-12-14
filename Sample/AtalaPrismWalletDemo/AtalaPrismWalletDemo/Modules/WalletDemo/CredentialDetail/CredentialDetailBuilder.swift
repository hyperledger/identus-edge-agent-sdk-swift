import Foundation
import PrismAgent
import SwiftUI

struct CredentialDetailComponent {
    let credentialId: String
    let container: DIContainer
}

struct CredentialDetailBuilder {
    func build(component: CredentialDetailComponent) -> some View {
        let viewModel = CredentialDetailViewModelImpl(
            credentialId: component.credentialId,
            agent: component.container.resolve(type: PrismAgent.self)!
        )

        return CredentialDetailNeoView(
            viewModel: viewModel
        )
    }
}
