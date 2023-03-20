import SwiftUI

protocol MediatorPageViewModel: ObservableObject {
    var mediator: MediatorPageStateView.Mediator? { get }
    var agentRunning: Bool { get }
    var loading: Bool { get }
    var error: FancyToast? { get }

    func startAgent(mediatorDID: String)
    func stopAgent()
}

struct MediatorPageView<ViewModel: MediatorPageViewModel>: View {
    @StateObject var viewModel: ViewModel
    @State var didInput = "did:peer:2.Ez6LSms555YhFthn1WV8ciDBpZm86hK9tp83WojJUmxPGk1hZ.Vz6MkmdBjMyB4TS5UbbQw54szm8yvMMf1ftGV2sQVYAxaeWhE.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwczovL21lZGlhdG9yLnJvb3RzaWQuY2xvdWQiLCJhIjpbImRpZGNvbW0vdjIiXX0"

    var body: some View {
        NavigationStack {
            VStack {
                if let mediator = viewModel.mediator {
                    VStack(spacing: 16) {
                        Text("Mediator DID:")
                        Text(mediator.mediatorDID)
                        Text("Routing DID:")
                        Text(mediator.routingDID)
                        Text("State of agent: \(viewModel.agentRunning ? "Running" : "Stoped")")
                        Button {
                            if viewModel.agentRunning {
                                viewModel.stopAgent()
                            } else {
                                viewModel.startAgent(mediatorDID: mediator.mediatorDID)
                            }
                        } label: {
                            Text(viewModel.agentRunning ? "Stop" : "Start")
                        }
                        .disabled(viewModel.loading)
                    }
                } else {
                    VStack(spacing: 16) {
                        TextField("Mediator DID", text: $didInput)
                        Button {
                            viewModel.startAgent(mediatorDID: didInput)
                        } label: {
                            Text("Start")
                        }
                    }
                    .disabled(viewModel.loading)
                }
            }
            .padding()
        }
    }
}
