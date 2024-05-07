import SwiftUI

struct FuncionalitiesList: View {
    @State var presentWallet2 = false
    @State var presentVerifier = false
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Seed Funcionalities", destination: SeedFuncionalitiesView(model: .init()))
                NavigationLink("DID Funcionalities", destination: DIDFuncionalitiesView(model: .init()))
                NavigationLink("Signing/Verification Funcionalities", destination: SigningVerificationView(model: .init()))
                NavigationLink("Setup Prism Agent", destination: SetupEdgeAgentView(viewModel: SetupEdgeAgentViewModelImpl())
                )
                Button {
                    self.presentWallet2 = true
                } label: {
                    Text("Wallet Demo")
                }
                Button {
                    self.presentVerifier = true
                } label: {
                    Text("Verifier")
                }
            }
            .buttonStyle(.plain)
            .fullScreenCover(isPresented: $presentWallet2) {
                Main2View(router: Main2RouterImpl())
            }
            .fullScreenCover(isPresented: $presentVerifier) {
                MainVerifierView(router: MainVerifierRouterImpl())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FuncionalitiesList()
    }
}
