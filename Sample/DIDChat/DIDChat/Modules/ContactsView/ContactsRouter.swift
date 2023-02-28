import Domain
import Foundation
import SwiftUI

struct ContactsListRouterImpl: ContactsListRouter {
    var viewModel: ContactsViewModelImpl

    func routeToContact(pair: DIDPair) -> some View {
        ChatView(viewModel: ChatViewModelImpl(
            conervsationPair: pair,
            agent: viewModel.agent)
        )
    }

    func routeToDIDs() -> some View {
        DIDManagerView(
            viewModel: DIDManagerViewModelImpl(
                agent: viewModel.agent
            )
        )
    }
}
