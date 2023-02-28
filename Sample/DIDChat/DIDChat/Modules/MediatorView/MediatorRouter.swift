import Foundation
import SwiftUI

struct MediatorRouterImpl: MediatorRouter {
    let viewModel: MediatorViewModelImpl

    func routeToContactsList() -> some View {
        LazyView {
            let model = ContactsViewModelImpl(prismAgent: viewModel.agent!)
            return ContactList(
                viewModel: model,
                router: ContactsListRouterImpl(viewModel: model)
            )
        }
    }
}
