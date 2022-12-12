import SwiftUI

protocol MainViewRouter {
    associatedtype DashboardV: View

    func routeToDashboard() -> DashboardV
}

struct MainView<Router: MainViewRouter>: View {
    let router: Router

    var body: some View {
        router.routeToDashboard()
    }
}

struct MainView_Previews: PreviewProvider {
    struct Router: MainViewRouter {
        func routeToDashboard() -> some View {
            Text("Dashboard")
        }
    }
    static var previews: some View {
        MainView(router: Router())
    }
}
