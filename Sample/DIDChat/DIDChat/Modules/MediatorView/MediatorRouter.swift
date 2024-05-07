import Foundation
import SwiftUI

struct MediatorRouterImpl: MediatorRouter {
    let viewModel: MediatorViewModelImpl

    func routeToContactsList() -> some View {
        LazyView {
            let model = ContactsViewModelImpl(edgeAgent: viewModel.agent!)
            return ContactList(
                viewModel: model,
                router: ContactsListRouterImpl(viewModel: model)
            )
        }
    }
}
