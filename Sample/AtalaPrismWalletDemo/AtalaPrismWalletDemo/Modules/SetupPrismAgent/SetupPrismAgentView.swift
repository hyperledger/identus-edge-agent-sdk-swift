import SwiftUI

protocol SetupPrismAgentViewModel: ObservableObject {
    var status: String { get }
    var error: String? { get }
    func start() async throws
    func updateKeyList() async throws
}

struct SetupPrismAgentView<ViewModel: SetupPrismAgentViewModel>: View {

    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 16) {
            if !viewModel.status.isEmpty {
                Text("Agent Status")
                Text(viewModel.status)
            }

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

            Button("Create a connection") {
                Task {
                    try await viewModel.updateKeyList()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .tint(.white)
            .clipShape(Capsule(style: .continuous))

            if let error = viewModel.error {
                Text("Error").foregroundColor(.red)
                Text(error)
            }
        }.padding()
    }
}

struct SetupPrismAgentView_Previews: PreviewProvider {
    static var previews: some View {
        SetupPrismAgentView(viewModel: ViewModel())
    }
}

private class ViewModel: SetupPrismAgentViewModel {
    var status: String = ""
    var error: String?
    func start() {}
    func updateKeyList() async throws {}
}
