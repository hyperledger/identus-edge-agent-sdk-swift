import SwiftUI

protocol AddNewContactViewModel: ObservableObject {
    var flowStep: AddNewContactState.AddContacFlowStep { get }
    var contactInfo: AddNewContactState.Contact? { get }
    var loading: Bool { get }
    var dismiss: Bool { get }
    var dismissRoot: Bool { get }
    var code: String { get set }
    var url: URL? { get }
    var hasUrl: Bool { get set }
    func isContactAlreadyAdded()
    func addContact()
    func handleLinkCallback(url: URL) async throws
}

struct AddNewContactView<ViewModel: AddNewContactViewModel>: View {
    @State var shouldDismissWebView = false
    @State var deepLinkUrl: URL?
    @StateObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.rootPresentationMode) var modalPresentation

    var body: some View {
        VStack {
            switch viewModel.flowStep {
            case .getCode:
                InsertCodeView(
                    textField: $viewModel.code,
                    loading: viewModel.loading
                ) {
                    self.viewModel.isContactAlreadyAdded()
                } cancelAction: {
                    self.presentationMode.wrappedValue.dismiss()
                }
                .commitDisablePreference()
                .disabled(viewModel.loading)
            case .checkDuplication:
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle()
                    )
                    .onAppear(perform: {
                        viewModel.isContactAlreadyAdded()
                    })
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .commitDisablePreference()
                    .disabled(true)
            case .alreadyConnected:
                if let contact = viewModel.contactInfo {
                    AlreadyConnectedView(
                        name: contact.text
                    ) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .commitDisablePreference()
                    .disabled(viewModel.loading)
                }

            case .confirmConnection:
                if let contact = viewModel.contactInfo {
                    ConfirmConnectionView(
                        name: contact.text,
                        loading: viewModel.loading
                    ) {
                        self.viewModel.addContact()
                    } cancelAction: {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .commitDisablePreference()
                    .disabled(viewModel.loading)
                }
            case let .error(error):
                ErrorDialogView(
                    error: .constant(error)
                ) {
                    self.presentationMode.wrappedValue.dismiss()
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
        .onChange(of: viewModel.dismissRoot, perform: { value in
            self.modalPresentation.wrappedValue = value
        })
        .sheet(
            isPresented: $viewModel.hasUrl,
            onDismiss: {
                if let deepLinkUrl {
                    Task {
                        try await self.viewModel.handleLinkCallback(url: deepLinkUrl)
                    }
                }
            },
            content: {
                DeepLinkWebView(
                    url: viewModel.url!,
                    deepLinkUrl: $deepLinkUrl,
                    shouldDismiss: $viewModel.hasUrl
                )
        })
        .onOpenURL(perform: { url in
            Task {
                print("App was opened via URL: \(url)")
                try await self.viewModel.handleLinkCallback(url: url)
            }
        })
    }
}

struct AddNewContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewContactView<MockViewModel>(viewModel: MockViewModel())
    }
}

private class MockViewModel: AddNewContactViewModel {
    var url: URL? = nil
    var hasUrl: Bool = false
    
    func handleLinkCallback(url: URL) async throws {}
    var contactInfo: AddNewContactState.Contact?
    var flowStep: AddNewContactState.AddContacFlowStep = .getCode
    var loading = false
    var dismiss = false
    var dismissRoot = false
    var code = ""
    func isContactAlreadyAdded() {
    }

    func addContact() {
        dismiss = true
    }
}
