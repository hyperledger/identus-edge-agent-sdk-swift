import SwiftUI

struct FuncionalitiesList: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Seed Funcionalities", destination: SeedFuncionalitiesView(model: .init()))
                NavigationLink("DID Funcionalities", destination: DIDFuncionalitiesView(model: .init()))
                NavigationLink("Signing/Verification Funcionalities", destination: SigningVerificationView(model: .init()))
                NavigationLink("Authenticate Wallet Side", destination: AuthenticateWalletView(viewModel: AuthenticateWalletViewModelImpl())
                )
                NavigationLink("Setup Prism Agent", destination: SetupPrismAgentView(viewModel: SetupPrismAgentViewModelImpl())
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FuncionalitiesList()
    }
}
