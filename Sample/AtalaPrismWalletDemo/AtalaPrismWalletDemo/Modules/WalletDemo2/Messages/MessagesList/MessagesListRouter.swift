import SwiftUI
import Domain
import EdgeAgent

struct MessageListRouterImpl: MessageListRouter {
    let container: DIContainer

    func routeToMessageDetail(messageId: String) -> some View {
        let viewModel = MessageDetailViewModelImpl(
            messageId: messageId,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: DIDCommAgent.self)!
        )

        return MessageDetailView(viewModel: viewModel)
    }
}
