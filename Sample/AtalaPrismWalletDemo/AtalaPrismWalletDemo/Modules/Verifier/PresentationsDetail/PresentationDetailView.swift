import SwiftUI

protocol PresentationDetailViewModel: ObservableObject {
    @MainActor var presentation: PresentationDetailViewState.Presentation { get }
    @MainActor var receivedPresentations: [PresentationDetailViewState.ReceivedPresentation] { get set }
    @MainActor var isVerified: Bool { get }
}

struct PresentationDetailView<ViewModel: PresentationDetailViewModel>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("To DID: \(viewModel.presentation.to)")
                    .font(.headline)

                Text("Status: \(viewModel.isVerified ? "✅ Verified" : "❌ Not Verified")")
                    .font(.headline)

                Divider()

                Text("Requested inputs")
                    .font(.title2)

                ForEach(viewModel.presentation.claims, id: \.name) { claim in
                    VStack(alignment: .leading) {
                        Text(claim.name).bold()
                        Text("Type: \(claim.type)")
                        Text("Value: \(claim.value)")
                    }
                    .padding(.bottom, 5)
                }

                Divider()

                Text("Received Presentations")
                    .font(.title2)

                ForEach(viewModel.receivedPresentations, id: \.id) { received in
                    VStack(alignment: .leading) {
                        Text("ID: \(received.id)")
                        Text("Status: \(received.isVerified ? "✅ Verified" : "❌ Failed")")
                        if !received.isVerified {
                            Text("Error: \(received.error.joined(separator: ", "))")
                                .foregroundColor(.red)
                        }
                        Divider()
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Presentation Detail", displayMode: .inline)
    }
}
