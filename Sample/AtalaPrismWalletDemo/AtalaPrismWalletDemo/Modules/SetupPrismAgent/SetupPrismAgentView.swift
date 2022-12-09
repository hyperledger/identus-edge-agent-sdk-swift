import SwiftUI

protocol SetupPrismAgentViewModel: ObservableObject {
    var status: String { get }
    var mediatorRoutingId: String { get }
    func start() async throws
}

struct SetupPrismAgentView<ViewModel: SetupPrismAgentViewModel>: View {

    @StateObject var viewModel: ViewModel

    var body: some View {
        Button("Start Prism Agent") {
            Task {
                try await viewModel.start()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .tint(.white)
        .clipShape(Capsule(style: .continuous))
        if !viewModel.status.isEmpty {
            Text("Agent Status")
            Text(viewModel.status)
        }
        if !viewModel.mediatorRoutingId.isEmpty {
            Text("Mediator Routing DID")
            Text(viewModel.mediatorRoutingId)
        }
    }
}

struct SetupPrismAgentView_Previews: PreviewProvider {
    static var previews: some View {
        SetupPrismAgentView(viewModel: ViewModel())
    }
}

private class ViewModel: SetupPrismAgentViewModel {
    var status: String = ""
    var mediatorRoutingId: String = ""
    func start() {}
}
