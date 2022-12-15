import SwiftUI

protocol ProofOfRequestCheckViewModel: ObservableObject {
    var contact: ProofOfRequestState.Contact { get }
    var credential: [ProofOfRequestState.Credential] { get }
    var checks: [Bool] { get set }
    var loading: Bool { get }

    func share()
}

struct ProofOfRequestCheckView<ViewModel: ProofOfRequestCheckViewModel>: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 21) {
                Text(viewModel.contact.text)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 16) {
                Text("proof_request_description_first".localize())
                    .foregroundColor(.black)
                VStack(alignment: .leading, spacing: 8) {
                    Text("")
//                    ForEach(Array(viewModel.contact.credentialsRequested.enumerated()), id: \.offset) {
//                        switch $0.element {
//                        case .idCredential:
//                            Text("proof_request_id_credential".localize())
//                                .bold()
//                        case .universityDegree:
//                            Text("proof_request_university_credential".localize())
//                                .bold()
//                        case .proofOfEmployment:
//                            Text("proof_request_employment_credential".localize())
//                                .bold()
//                        case .insurance:
//                            Text("proof_request_insurance_credential".localize())
//                                .bold()
//                        case let .custom(text):
//                            Text(text)
//                                .bold()
//                        }
//                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("proof_request_select_credentials".localize())
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                VStack(spacing: 12) {
                    ForEach(viewModel.credential.zipped(), id: \.0) { idx, credential in
                        HStack {
                            Text(credential.text)
                                .bold()
                            Spacer()
                            CheckButton(isSelected: $viewModel.checks[idx])
                        }
                    }
                }
            }

            Divider()

            HStack {
                AtalaButton(configuration: .secondary) {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("cancel".localize())
                }

                AtalaButton(loading: viewModel.loading) {
                    self.viewModel.share()
                } label: {
                    Text("proof_request_share".localize())
                }
            }
        }
        .padding(24)
    }
}
