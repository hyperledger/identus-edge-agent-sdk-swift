import SwiftUI

protocol MessageDetailViewModel: ObservableObject {
    var state: MessageDetailViewState { get }
    var loading: Bool { get }
    var dismiss: Bool { get }

    func accept()
    func refuse()
}

struct MessageDetailView<ViewModel: MessageDetailViewModel>: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ID:")
                    .font(.headline)
                Text(viewModel.state.common.id)
                    .font(.subheadline)
                Spacer()
            }

            HStack {
                Text("Type:")
                    .font(.headline)
                Text(viewModel.state.common.type)
                    .font(.subheadline)
                Spacer()
            }

            HStack {
                Text("Title:")
                    .font(.headline)
                Text(viewModel.state.common.title)
                    .font(.subheadline)
                Spacer()
            }

            if let from = viewModel.state.common.from {
                HStack {
                    Text("From:")
                        .font(.headline)
                    Text(from)
                        .font(.subheadline)
                    Spacer()
                }
            }

            if let to = viewModel.state.common.to {
                HStack {
                    Text("To:")
                        .font(.headline)
                    Text(to)
                        .font(.subheadline)
                    Spacer()
                }
            }

            if let bodyString = viewModel.state.common.bodyString {
                HStack {
                    Text("Body:")
                        .font(.headline)
                    Text(bodyString)
                        .font(.subheadline)
                    Spacer()
                }
            }

            if let thid = viewModel.state.common.thid {
                HStack {
                    Text("THID:")
                        .font(.headline)
                    Text(thid)
                        .font(.subheadline)
                    Spacer()
                }
            }

            specificView(state: viewModel.state.specific)
        }
        .onChange(of: viewModel.dismiss, perform: { newValue in
            if newValue {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
        .disabled(viewModel.dismiss)
        .padding()
        .navigationBarTitle(Text("Message Details"))
    }

    @ViewBuilder
    func specificView(state: MessageDetailViewState.SpecificDetail) -> some View {
        switch viewModel.state.specific {
        case let .credentialDomainChallenge(domain, challenge):
            HStack {
                Text("DOMAIN:")
                    .font(.headline)
                Text(domain)
                    .font(.subheadline)
                Spacer()
            }
            HStack {
                Text("CHALLENGE:")
                    .font(.headline)
                Text(challenge)
                    .font(.subheadline)
                Spacer()
            }
            HStack {
                Button {
                    viewModel.accept()
                } label: {
                    Text("Accept")
                }
                Button {
                    viewModel.refuse()
                } label: {
                    Text("Refuse")
                }
            }
        case .acceptRefuse:
            HStack {
                Button {
                    viewModel.accept()
                } label: {
                    Text("Accept")
                }
                Button {
                    viewModel.refuse()
                } label: {
                    Text("Refuse")
                }
            }
        default:
            EmptyView()
        }
    }
}
