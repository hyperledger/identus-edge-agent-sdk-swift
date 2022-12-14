import SwiftUI

struct FuncionalitiesList: View {
    let mainRouter = MainViewRouterImpl()
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
                NavigationLink("Wallet Demo", destination: MainView(viewModel: MainViewModelImpl(router: mainRouter), router: mainRouter))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FuncionalitiesList()
    }
}
