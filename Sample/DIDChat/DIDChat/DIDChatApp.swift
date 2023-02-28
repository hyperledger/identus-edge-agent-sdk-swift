import SwiftUI

@main
struct DIDChatApp: App {
    @StateObject var viewModel = MediatorViewModelImpl()

    var body: some Scene {
        WindowGroup {
            MediatorView(viewModel: viewModel, router: MediatorRouterImpl(viewModel: viewModel))
        }
    }
}
