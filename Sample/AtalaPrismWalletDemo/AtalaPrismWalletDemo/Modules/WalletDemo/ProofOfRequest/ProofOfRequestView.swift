import SwiftUI

protocol ProofOfRequestViewModel: ProofOfRequestCheckViewModel {
    var flowStep: ProofOfRequestState.FlowStep { get }
    var dismiss: Bool { get }
    func viewDidAppear()
    func confirmDismiss()
}

struct ProofOfRequestView<ViewModel: ProofOfRequestViewModel>: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            switch viewModel.flowStep {
            case .loading:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle()
                    )
                    .onAppear(perform: {
                        self.viewModel.viewDidAppear()
                    })
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .commitDisablePreference()
                    .disabled(true)
            case .shareCredentials:
                ProofOfRequestCheckView<ViewModel>()
                    .environmentObject(viewModel)
                    .commitDisablePreference()
                    .disabled(viewModel.loading)
            case .confirm:
                VStack(spacing: 20) {
                    Image("img_success")
                    VStack(spacing: 5) {
                        Text("credentials_detail_share_success_title".localize())
                            .font(.caption)
                            .fontWeight(.light)
                        Text("credentials_detail_share_success".localize())
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                    }

                    Divider()

                    AtalaButton {
                        self.viewModel.confirmDismiss()
                    } label: {
                        Text("ok".localize())
                    }
                }
                .padding(24)
                .commitDisablePreference()
                .disabled(viewModel.loading)
            case let .error(error):
                ErrorDialogView(error: .constant(error)) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .animation(.default)
        .onChange(of: viewModel.dismiss, perform: { value in
            if value {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
    }
}
