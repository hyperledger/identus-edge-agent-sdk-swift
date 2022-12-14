import SwiftUI

protocol MainViewModel: ObservableObject {
    var routeToDashboard: Bool { get set }
    var didString: String { get set }
    var toast: FancyToast? { get set }
    func start()
}

protocol MainViewRouter {
    associatedtype DashboardV: View

    func routeToDashboard() -> DashboardV
}

struct MainView<ViewModel: MainViewModel, Router: MainViewRouter>: View {
    @StateObject var viewModel: ViewModel
    let router: Router

    var body: some View {
        VStack(spacing: 20) {
            TextField(text: $viewModel.didString) {
                Text("Mediator DID")
            }
            Button("Create a connection") {
                Task {
                    viewModel.start()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .tint(.white)
            .clipShape(Capsule(style: .continuous))
            EmptyNavigationLink(isActive: $viewModel.routeToDashboard) {
                self.router.routeToDashboard()
            }
        }
        .padding()
    }
}

//struct MainView_Previews: PreviewProvider {
//    struct Router: MainViewRouter {
//        func routeToDashboard() -> some View {
//            Text("Dashboard")
//        }
//    }
//    static var previews: some View {
//        MainView(viewModel: MainViewModelImpl(router: Router), router: Router())
//    }
//}
