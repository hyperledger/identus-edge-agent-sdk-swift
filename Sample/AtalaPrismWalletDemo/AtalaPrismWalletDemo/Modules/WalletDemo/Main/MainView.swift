import SwiftUI

protocol MainViewModel: ObservableObject {
    var routeToDashboard: Bool { get set }
    var didString: String { get set }
    var oobString: String { get set }
    var toast: FancyToast? { get set }
    func startWithMediatorDID()
    func startWithMediatorOOB()
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
            TextField(text: $viewModel.oobString) {
                Text("Mediator OOB")
            }
            Button("Start with mediator OOB") {
                Task {
                    viewModel.startWithMediatorOOB()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .tint(.white)
            .clipShape(Capsule(style: .continuous))
            TextField(text: $viewModel.didString) {
                Text("Mediator DID")
            }
            Button("Start with mediator DID") {
                Task {
                    viewModel.startWithMediatorDID()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .tint(.white)
            .clipShape(Capsule(style: .continuous))
            EmptyNavigationLink(isActive: $viewModel.routeToDashboard) {
                LazyView {
                    self.router.routeToDashboard()
                }
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
