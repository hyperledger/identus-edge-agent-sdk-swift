import Combine
import Domain
import Foundation
import PrismAgent

final class MainViewModelImpl: MainViewModel {
    @Published var didString: String = "did:peer:2.Ez6LShi7LMpR9aGFpyTqT6f5bZNFVdjspH61WPneaMEEhNZxh.Vz6MkhSEtgAWDcpL33sZiQsVr2bJG7Z7HbLoF5Ta7R8Tbk8G9.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19"
    @Published var toast: FancyToast?
    @Published var routeToDashboard = false
    private let router: MainViewRouterImpl
    private var cancellables = [AnyCancellable]()

    init(router: MainViewRouterImpl) {
        self.router = router
    }

    func start() {
        do {
            let did = try DID(string: didString)
            self.router.didOnUse = did
            self.routeToDashboard = true
        } catch {
            self.didString = ""
            self.toast = .init(type: .error, title: "Invalid DID", message: didString)
        }
    }
}
